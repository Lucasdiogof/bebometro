"""Maintenance tool for assets/catalog/catalog_v1.json (no network, no secrets).

  python -I scripts/catalog_tool.py coverage            # data coverage report
  python -I scripts/catalog_tool.py check               # validate the file
  python -I scripts/catalog_tool.py merge a.json b.json # apply research files
  python -I scripts/catalog_tool.py merge --write ...   # ... and save

A research file is {"patches": [...], "new": [...], "unresolved": [...]}:
- corroborate {id: source} attaches a source to a field that already has a
  value (default field abv) without changing it.
- patches only FILL fields that are empty (null / [] / missing). A value that
  differs from what is already there is reported as a conflict and never
  overwrites it. Nothing is ever averaged.
- new products are skipped when the id or the brand+name already exists.
- fieldSources {field: [{url, label, retrieved, market, evidence, variant?,
  note?}]} records where each filled field came from; entries of a patch are
  appended only for the fields that patch actually filled.
Ids never change, so favorites and past records (which keep their own
snapshot) are not affected.
"""
import json
import os
import re
import sys
import unicodedata

HERE = os.path.dirname(os.path.abspath(__file__))
PATH = os.path.join(HERE, '..', 'assets', 'catalog', 'catalog_v1.json')
CATEGORIES = {'beer', 'draft', 'nonAlcoholic', 'spirit', 'wine', 'readyToDrink'}
KINDS = {'can', 'longNeck', 'bottle', 'glass', 'shot'}
EVIDENCE = {'primary', 'secondary'}
TYPES = {'official', 'label', 'packagingRegistry', 'secondary'}
SOURCED = {'abv', 'abvVariants', 'ingredients', 'presentations', 'style', 'note'}
FILL = ['style', 'abv', 'abvVariants', 'ingredients', 'presentations', 'note',
        'abvEvidence', 'abvSource', 'evidence', 'roles']


def load():
    with open(PATH, encoding='utf-8') as f:
        return json.load(f)


def save(doc):
    with open(PATH, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(doc, f, ensure_ascii=False, indent=1)
        f.write('\n')


def norm(s):
    s = unicodedata.normalize('NFKD', s or '')
    return ''.join(c for c in s if not unicodedata.combining(c)).lower().strip()


def empty(v):
    return v is None or v == [] or v == ''


def validate(p):
    errs = []
    for k in ('id', 'brand', 'name', 'category', 'source'):
        if empty(p.get(k)):
            errs.append(f'missing {k}')
    if p.get('category') not in CATEGORIES:
        errs.append(f"bad category {p.get('category')}")
    abv = p.get('abv')
    if abv is not None and not (isinstance(abv, (int, float)) and 0 <= abv <= 80):
        errs.append(f'bad abv {abv}')
    if abv is not None and p.get('abvVariants'):
        errs.append('abv and abvVariants together')
    for pr in p.get('presentations') or []:
        if not (isinstance(pr.get('ml'), int) and 10 <= pr['ml'] <= 5000):
            errs.append(f'bad ml {pr}')
        if pr.get('kind') is not None and pr['kind'] not in KINDS:
            errs.append(f"bad kind {pr.get('kind')}")
    src = p.get('source') or {}
    if not str(src.get('url', '')).startswith('http') or empty(src.get('label')):
        errs.append('bad source')
    if p.get('abvEvidence') == 'secondary' and empty(p.get('abvSource')):
        errs.append('secondary abv without abvSource')
    for field, entries in (p.get('fieldSources') or {}).items():
        if field not in SOURCED:
            errs.append(f'fieldSources.{field} unknown field')
        for e in entries:
            if not str(e.get('url', '')).startswith('http') or empty(e.get('label')):
                errs.append(f'fieldSources.{field} without url/label')
            if not re.fullmatch(r'\d{4}-\d{2}-\d{2}', str(e.get('retrieved', ''))):
                errs.append(f'fieldSources.{field} without retrieved date')
            if empty(e.get('market')):
                errs.append(f'fieldSources.{field} without market')
            if e.get('type') is not None and e['type'] not in TYPES:
                errs.append(f"fieldSources.{field} bad type {e['type']}")
            if e.get('type') == 'official' and e.get('evidence') != 'primary':
                errs.append(f'fieldSources.{field} official must be primary')
            if e.get('evidence') not in EVIDENCE:
                errs.append(f'fieldSources.{field} evidence must be primary/secondary')
    if p.get('retrieved') and not re.fullmatch(r'\d{4}-\d{2}-\d{2}', p['retrieved']):
        errs.append('bad retrieved date')
    for a in p.get('aliases') or []:
        if not isinstance(a, str) or not a.strip():
            errs.append(f'bad alias {a!r}')
    i18n = p.get('i18n') or {}
    for lang in ('en', 'es'):
        t = i18n.get(lang) or {}
        if empty(t.get('sourceLabel')):
            errs.append(f'i18n.{lang}.sourceLabel missing')
        if p.get('note') and empty(t.get('note')):
            errs.append(f'i18n.{lang}.note missing')
        if p.get('abvVariants') and len(t.get('abvVariants') or []) != len(p['abvVariants']):
            errs.append(f'i18n.{lang}.abvVariants length')
        if (p.get('abvSource') or {}).get('label') and empty(t.get('abvSourceLabel')):
            errs.append(f'i18n.{lang}.abvSourceLabel missing')
    return errs


def check(doc):
    bad = 0
    seen, names = set(), set()
    for p in doc['products']:
        errs = validate(p)
        key = (norm(p.get('brand')), norm(p.get('name')))
        if p.get('id') in seen:
            errs.append('duplicate id')
        if key in names:
            errs.append('duplicate brand+name')
        seen.add(p.get('id'))
        names.add(key)
        for e in errs:
            bad += 1
            print(f"  {p.get('id')}: {e}")
    print(f"{len(doc['products'])} products, {bad} problems")
    suspicious(doc)
    return bad


def _core(p):
    """Brand + name without packaging words, to spot the same beer twice."""
    s = norm(f"{p.get('brand')} {p.get('name')}")
    s = re.sub(r'\b(cerveja|beer|lata|garrafa|long ?neck|\d+ ?ml)\b', ' ', s)
    return re.sub(r'[^a-z0-9]+', '', s)


def suspicious(doc):
    """Warnings only: products whose brand+name collapse to the same core."""
    seen = {}
    for p in doc['products']:
        k = _core(p)
        if k in seen:
            print(f"  warning: {p['id']} looks like {seen[k]}")
        seen[k] = p['id']


def coverage(doc):
    P = doc['products']
    cats = {}
    for p in P:
        cats.setdefault(p['category'], []).append(p)

    def row(name, items):
        n = len(items)
        f = lambda fn: sum(1 for p in items if fn(p))
        print(f"{name:14}{n:5}  abv {f(lambda p: p.get('abv') is not None):3}"
              f"  abv-variants {f(lambda p: p.get('abvVariants')):3}"
              f"  ingred {f(lambda p: p.get('ingredients')):3}"
              f"  sizes {f(lambda p: p.get('presentations')):3}"
              f"  style {f(lambda p: p.get('style')):3}"
              f"  field-sourced {f(lambda p: p.get('fieldSources')):3}")
    row('TOTAL', P)
    for c in sorted(cats):
        row(c, cats[c])
    print('brands:', len({p['brand'] for p in P}))


def merge(doc, files, write):
    byid = {p['id']: p for p in doc['products']}
    names = {(norm(p['brand']), norm(p['name'])) for p in doc['products']}
    stats = dict(patched=0, filled=0, added=0, skipped=0, conflicts=0)
    for fn in files:
        with open(fn, encoding='utf-8') as f:
            r = json.load(f)
        for u in r.get('unresolved', []):
            print(f"  unresolved {u.get('id')}: {u.get('reason')}")
        for pt in r.get('patches', []):
            p = byid.get(pt['id'])
            if p is None:
                print(f"  patch for unknown id {pt['id']}")
                stats['skipped'] += 1
                continue
            changed = False
            filled = set()
            added_ml = None  # None = the whole list was filled
            for k in FILL:
                if k not in pt or empty(pt[k]):
                    continue
                if empty(p.get(k)):
                    if k == 'abvVariants' and p.get('abv') is not None:
                        print(f"  conflict {p['id']}: abvVariants vs abv {p['abv']}")
                        stats['conflicts'] += 1
                        continue
                    if k == 'abv' and p.get('abvVariants'):
                        continue
                    p[k] = pt[k]
                    changed = True
                    filled.add(k)
                    stats['filled'] += 1
                elif p[k] != pt[k]:
                    if k == 'presentations':
                        have = {(x.get('kind'), x['ml']) for x in p[k]}
                        add = [x for x in pt[k]
                               if x['ml'] not in {y['ml'] for y in p[k]}]
                        if add:
                            p[k] = p[k] + add
                            changed = True
                            filled.add(k)
                            added_ml = {x['ml'] for x in add}
                            stats['filled'] += 1
                        continue
                    print(f"  conflict {p['id']}.{k}: keep {p[k]!r}, source says {pt[k]!r}")
                    stats['conflicts'] += 1
            for lang, t in (pt.get('i18n') or {}).items():
                cur = p.setdefault('i18n', {}).setdefault(lang, {})
                for k, v in t.items():
                    if k not in cur and not empty(v):
                        cur[k] = v
                        changed = True
            for k, entries in (pt.get('fieldSources') or {}).items():
                if k not in filled:
                    continue
                have = p.setdefault('fieldSources', {}).setdefault(k, [])
                urls = {e['url'] for e in have}
                for e in entries:
                    m = re.search(r'(\d+) ml', e.get('variant') or '')
                    if (k == 'presentations' and added_ml is not None and m
                            and int(m.group(1)) not in added_ml):
                        continue  # that size was already documented
                    if e['url'] not in urls:
                        have.append(e)
            if changed:
                if pt.get('retrieved'):
                    p['retrieved'] = pt['retrieved']
                stats['patched'] += 1
        # Sources that confirm (or contradict) a value already present: only
        # the source is recorded, the value never changes.
        for pid, e in (r.get('corroborate') or {}).items():
            p = byid.get(pid)
            if p is None:
                print(f"  corroborate for unknown id {pid}")
                continue
            e = dict(e)
            field = e.pop('field', 'abv')
            have = p.setdefault('fieldSources', {}).setdefault(field, [])
            if e['url'] not in {x['url'] for x in have}:
                have.append(e)
                stats['corroborated'] = stats.get('corroborated', 0) + 1
        for n in r.get('new', []):
            key = (norm(n.get('brand')), norm(n.get('name')))
            if n.get('id') in byid or key in names:
                print(f"  skip existing {n.get('id')}")
                stats['skipped'] += 1
                continue
            errs = validate(n)
            if errs:
                print(f"  skip invalid {n.get('id')}: {errs}")
                stats['skipped'] += 1
                continue
            doc['products'].append(n)
            byid[n['id']] = n
            names.add(key)
            stats['added'] += 1
    print(stats)
    if write:
        save(doc)
        print('written')


def main(argv):
    cmd = argv[1] if len(argv) > 1 else 'coverage'
    doc = load()
    if cmd == 'coverage':
        coverage(doc)
    elif cmd == 'check':
        raise SystemExit(1 if check(doc) else 0)
    elif cmd == 'merge':
        args = argv[2:]
        write = '--write' in args
        merge(doc, [a for a in args if a != '--write'], write)
    else:
        raise SystemExit(__doc__)


if __name__ == '__main__':
    main(sys.argv)
