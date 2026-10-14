"""Catalog update pipeline: collect -> normalize -> compare -> proposal.

  python -I tools/catalog_sync/catalog_sync.py collect heineken [--work DIR] [--delay 3]
  python -I tools/catalog_sync/catalog_sync.py import-off JSONL [--work DIR]
  python -I tools/catalog_sync/catalog_sync.py compare [--work DIR]
  python -I tools/catalog_sync/catalog_sync.py selftest

Nothing here writes assets/catalog/catalog_v1.json. `compare` only writes into the
work directory (default tools/catalog_sync/work/, git-ignored):

  proposal.json      every candidate field classified (see CLASSES)
  proposal.md        the same, for reading
  research_safe.json what can be applied with scripts/catalog_tool.py merge

Review proposal.md, then (optionally) apply the safe part:

  python -I scripts/catalog_tool.py merge work/research_safe.json          # dry run
  python -I scripts/catalog_tool.py merge --write work/research_safe.json

Rules enforced by the code (see README.md):
- Existing values are never overwritten and divergences are never averaged.
- A source that only states an upper limit ("no maximo 0,05%") is never an exact ABV.
- A size is an `documented` presentation only when the source names it for that
  product; suggestions are not collected.
- Candidates from a source whose reuse terms are not cleared (`licenseHold`) are
  classified but kept out of research_safe.json.
- Fields the source does not state stay unknown (absent), never guessed.
"""
import argparse
import hashlib
import html
import json
import os
import re
import sys
import time
import unicodedata
import urllib.error
import urllib.request
from datetime import datetime, timezone

HERE = os.path.dirname(os.path.abspath(__file__))
CATALOG = os.path.join(HERE, '..', '..', 'assets', 'catalog', 'catalog_v1.json')
DEFAULT_WORK = os.path.join(HERE, 'work')
UA = 'BebometroCatalogSync/1.0 (lucksrei@proton.me)'
CLASSES = ('new_product', 'filled', 'same', 'conflict', 'possible_duplicate', 'uncertain')
KIND_WORDS = {'lata': 'can', 'garrafa': 'bottle', 'long neck': 'longNeck', 'longneck': 'longNeck'}
LIMIT_WORDS = re.compile(r'(no m[aá]ximo|at[eé] |m[aá]x\.?|menos de|inferior a|<)', re.I)


def today():
    return datetime.now(timezone.utc).strftime('%Y-%m-%d')


def norm(s):
    s = unicodedata.normalize('NFKD', s or '')
    return ''.join(c for c in s if not unicodedata.combining(c)).lower().strip()


def load_json(path):
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def write_json(path, obj):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(obj, f, ensure_ascii=False, indent=1)
        f.write('\n')


# --------------------------------------------------------------------------- parsing

def page_text(raw_html):
    s = re.sub(r'<script.*?</script>|<style.*?</style>|<noscript.*?</noscript>', '', raw_html, flags=re.S)
    return re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]+>', ' ', s)))


def product_block(text):
    """The part of the page after the sign-up form (age gate/login boilerplate)."""
    i = text.find('Cadastrar Você precisa preencher')
    return text[i:] if i >= 0 else text


def parse_abv(text):
    """Returns {value, unit, exactness, quote} or None. A limit is exactness=max."""
    m = re.search(r'((?:[ÁA]lcool|Teor alc[oó]{1,2}lico|Grad\. alc[oó]{1,2}lica)[^0-9]{0,20}'
                  r'(\d+(?:[,.]\d+)?) ?%(?: ?(?:vol\.?|ABV))?)', text, flags=re.I)
    if not m:
        return None
    before = text[max(0, m.start() - 24):m.start()]
    exact = 'max' if LIMIT_WORDS.search(before + m.group(1)[:30]) else 'exact'
    return {'value': float(m.group(2).replace(',', '.')), 'unit': '%vol', 'exactness': exact,
            'quote': m.group(1).strip()}


def parse_ingredients(text):
    m = re.search(r'Ingredientes\s+(.{5,200}?)(?: Al[ée]rgicos| Sabor| Sobre| Onde|$)', text)
    if not m:
        return None
    raw = m.group(1).strip().rstrip('.')
    parts = [p.strip() for p in re.split(r',| e ', raw) if p.strip()]
    return {'value': [p[:1].upper() + p[1:] for p in parts], 'quote': m.group(0)[:120].strip()}


def parse_presentations(text, title):
    out = {}
    for kind_word, ml in re.findall(r'(Lata|Garrafa|Long ?neck)\s+(\d{3,4})\b', text, flags=re.I):
        out[int(ml)] = KIND_WORDS[kind_word.lower()]
    named = set(int(x) for x in re.findall(r'\b(\d{3,4}) ?ml\b', (title or '') + ' ' + text, flags=re.I))
    named.discard(100)  # "A cada 100 ml" is the nutrition table base, not a package
    if re.search(r'\b1 ?litro\b', (title or '') + ' ' + text, flags=re.I):
        named.add(1000)
    for ml in named:
        out.setdefault(ml, None)
    return [{'ml': ml, 'kind': out[ml], 'documented': True} for ml in sorted(out)]


def parse_style(text):
    m = re.search(r'Estilo: ([^:]{3,40}?)(?: Copo| Amargor)', text)
    return {'value': m.group(1).strip(), 'quote': m.group(0)[:80]} if m else None


def parse_page(raw_html):
    t = page_text(raw_html)
    body = product_block(t)
    mt = re.search(r'<meta property="og:title" content="([^"]*)"', raw_html)
    h1 = re.search(r'<h1[^>]*>(.*?)</h1>', raw_html, flags=re.S)
    title = html.unescape(re.sub(r'<[^>]+>', '', h1.group(1))).strip() if h1 else (mt.group(1) if mt else '')
    fields = {}
    for name, val in (('abv', parse_abv(body)), ('ingredients', parse_ingredients(body)),
                      ('style', parse_style(body))):
        if val:
            fields[name] = val
    pres = parse_presentations(body, title)
    if pres:
        fields['presentations'] = pres
    return title, fields


# --------------------------------------------------------------------------- collect

def fetch(url, work, delay, last):
    key = hashlib.sha256(url.encode()).hexdigest()[:16]
    path = os.path.join(work, 'raw', key + '.html')
    if os.path.exists(path):
        return open(path, 'rb').read(), 'cache'
    os.makedirs(os.path.dirname(path), exist_ok=True)
    for attempt in (1, 2):
        wait = delay - (time.time() - last[0])
        if wait > 0:
            time.sleep(wait)
        last[0] = time.time()
        try:
            req = urllib.request.Request(url, headers={'User-Agent': UA})
            with urllib.request.urlopen(req, timeout=30) as r:
                body = r.read()
            with open(path, 'wb') as f:
                f.write(body)
            return body, 'live'
        except urllib.error.HTTPError as e:
            ra = e.headers.get('Retry-After')
            if e.code in (429, 503) and attempt == 1:
                time.sleep(min(int(ra) if ra and ra.isdigit() else 30, 60))
                continue
            return None, f'http-{e.code}'
        except Exception as e:  # network, TLS...
            return None, type(e).__name__
    return None, 'failed'


def cmd_collect(args):
    if args.source != 'heineken':
        raise SystemExit('unknown source (only: heineken)')
    smap = load_json(os.path.join(HERE, 'maps', 'heineken_brands.json'))
    last = [0.0]
    out, log = [], []
    for page in smap['pages']:
        raw, how = fetch(page['url'], args.work, args.delay, last)
        if raw is None:
            log.append({'url': page['url'], 'status': how})
            print('FAILED', page['url'], how)
            continue
        title, fields = parse_page(raw.decode('utf-8', errors='replace'))
        sha = hashlib.sha256(raw).hexdigest()
        for key in list(fields):
            if key in page.get('ignoreFields', []):
                del fields[key]
        cand = {
            'id': 'heineken:' + hashlib.sha256(page['url'].encode()).hexdigest()[:10],
            'source': {'kind': 'manufacturer', 'name': page['label'], 'url': page['url'],
                       'retrieved': today(), 'market': smap['market'], 'htmlSha256': sha,
                       'manufacturer': smap['manufacturer'], 'reuse': smap['reuse']},
            'licenseHold': bool(smap['reuse'].get('hold')),
            'match': {'catalogId': page.get('catalogId'), 'how': 'explicit-map' if page.get('catalogId') else 'none'},
            'brand': page['brand'], 'name': title, 'variant': page.get('variant'),
            'fields': fields,
        }
        out.append(cand)
        log.append({'url': page['url'], 'status': how, 'fields': sorted(fields)})
        print(how, page['url'], sorted(fields))
    write_jsonl(os.path.join(args.work, 'candidates', 'heineken.jsonl'), out)
    write_json(os.path.join(args.work, 'candidates', 'heineken.log.json'), log)


def write_jsonl(path, rows):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        for r in rows:
            f.write(json.dumps(r, ensure_ascii=False) + '\n')


def read_jsonl(path):
    with open(path, encoding='utf-8') as f:
        return [json.loads(line) for line in f if line.strip()]


# --------------------------------------------------------------------------- Open Food Facts (cache only)

def cmd_import_off(args):
    """Normalizes an Open Food Facts collector output (JSONL) into candidates. No network.

    Open Food Facts data is ODbL: reuse in the published catalog needs attribution and
    share-alike analysis, so these candidates are kept on `licenseHold`.
    """
    omap = load_json(os.path.join(HERE, 'maps', 'off_curated.json'))
    rows = {}
    for r in read_jsonl(args.jsonl):
        rows[(r.get('gtin') or '').lstrip('0')] = r
    out = []
    for cid, entry in omap['products'].items():
        for gtin in entry['gtins']:
            r = rows.get(gtin.lstrip('0'))
            if r is None:
                continue
            f = {}
            abv = (r.get('abv_percent') or {}).get('value')
            if abv is not None:
                # alcohol_100g/alcohol_value unit is not guaranteed to be % vol in OFF
                f['abv'] = {'value': abv, 'unit': 'unspecified (OFF nutriment)', 'exactness': 'approx',
                            'quote': (r['abv_percent'] or {}).get('from')}
            ing = (r.get('ingredients') or {}).get('value')
            if ing:
                f['ingredients'] = {'value': [p.strip() for p in ing.split(',') if p.strip()], 'quote': ing[:120],
                                    'rawText': True}
            ml = (r.get('volume_ml') or {}).get('value')
            if ml:
                f['presentations'] = [{'ml': int(ml), 'kind': None, 'documented': True}]
            prov = r['name']
            out.append({
                'id': 'off:' + gtin,
                'source': {'kind': 'collaborative', 'name': 'Open Food Facts', 'url': prov.get('product_url'),
                           'retrieved': (prov.get('retrieved_at') or today())[:10], 'market': 'BR (country tag)',
                           'reuse': omap['reuse'], 'gtin': gtin},
                'licenseHold': True,
                'match': {'catalogId': cid, 'how': 'curated-map'},
                'brand': (r.get('brand') or {}).get('value'), 'name': prov.get('value'), 'variant': None,
                'fields': f,
            })
    write_jsonl(os.path.join(args.work, 'candidates', 'off.jsonl'), out)
    print(len(out), 'Open Food Facts candidates (licenseHold)')


# --------------------------------------------------------------------------- compare

def core(p):
    s = norm(f"{p.get('brand')} {p.get('name')}")
    s = re.sub(r'\b(cerveja|beer|lata|garrafa|long ?neck|\d+ ?ml)\b', ' ', s)
    return re.sub(r'[^a-z0-9]+', '', s)


def classify_candidate(cand, prod, others_by_field):
    """Returns a list of field results for one candidate against one catalog product."""
    res = []
    f = cand['fields']
    src_urls = {}
    for field, entries in (prod.get('fieldSources') or {}).items():
        src_urls[field] = {e.get('url') for e in entries}
    covered_by_source = lambda field: cand['source']['url'] in src_urls.get(field, set())

    if 'abv' in f:
        a = f['abv']
        cur = prod.get('abv')
        variants = [v.get('value') for v in (prod.get('abvVariants') or [])]
        if a['exactness'] != 'exact':
            res.append(('abv', 'uncertain', f"source gives {a['exactness']} value {a['value']} ({a['unit']}); not usable as exact ABV"))
        elif cur is None and not variants:
            res.append(('abv', 'filled', f"catalog empty; source says {a['value']} %vol"))
        elif cur is not None and abs(cur - a['value']) < 0.05 or a['value'] in variants:
            res.append(('abv', 'same', f"{a['value']} %vol equals catalog" + ('' if covered_by_source('abv') else ' (field has no source entry for this URL)')))
        else:
            res.append(('abv', 'conflict', f"catalog {cur if cur is not None else variants}, source {a['value']} %vol; kept both, nothing averaged"))
    if 'ingredients' in f:
        cur = prod.get('ingredients') or []
        new = f['ingredients']['value']
        if f['ingredients'].get('rawText'):
            res.append(('ingredients', 'uncertain', 'free text from collaborative base; list not verified against the label'))
        elif not cur:
            res.append(('ingredients', 'filled', 'catalog empty; ' + ', '.join(new)))
        elif [norm(x) for x in cur] == [norm(x) for x in new]:
            res.append(('ingredients', 'same', 'same list'))
        else:
            res.append(('ingredients', 'conflict', f'catalog {cur}, source {new}'))
    if 'presentations' in f:
        have = {x['ml']: x.get('kind') for x in prod.get('presentations') or []}
        for pr in f['presentations']:
            if not pr.get('documented'):
                continue  # suggestions never enter
            ml = pr['ml']
            if ml not in have:
                res.append(('presentations', 'filled', f"{ml} ml{' ' + pr['kind'] if pr.get('kind') else ''} not in catalog", pr))
            elif pr.get('kind') and have[ml] and pr['kind'] != have[ml]:
                res.append(('presentations', 'conflict', f"{ml} ml: catalog {have[ml]}, source {pr['kind']}", pr))
            else:
                res.append(('presentations', 'same', f'{ml} ml already documented', pr))
    if 'style' in f:
        cur = prod.get('style')
        new = f['style']['value']
        if not cur:
            res.append(('style', 'filled', f'catalog empty; source says {new}'))
        elif norm(cur) == norm(new):
            res.append(('style', 'same', 'same style'))
        else:
            res.append(('style', 'conflict', f'catalog {cur!r}, source {new!r}'))
    return res


def build_source_entry(cand, field, quote=True):
    """Source entry for catalog `fieldSources`. quote=False keeps the page's wording out."""
    s = cand['source']
    text = None
    f = cand['fields'].get(field)
    if quote and field == 'abv' and f:
        text = f['quote']
    elif quote and field == 'ingredients' and f:
        text = ', '.join(f['value'])
    quote = text
    entry = {'url': s['url'], 'label': f"{s['name']}" + (f': "{quote}"' if quote else ''),
             'retrieved': s['retrieved'], 'market': 'BR', 'evidence': 'primary' if s['kind'] == 'manufacturer' else 'secondary',
             'type': 'official' if s['kind'] == 'manufacturer' else 'secondary'}
    if field == 'presentations':
        sizes = [p for p in cand['fields'].get('presentations', []) if p.get('documented')]
        entry['variant'] = ', '.join(f"{(p['kind'] + ' ') if p.get('kind') else ''}{p['ml']} ml" for p in sizes)
        entry['label'] = f"{s['name']}: " + ', '.join(f"{p['ml']} ml" for p in sizes)
    return entry


def cmd_compare(args):
    doc = load_json(CATALOG)
    byid = {p['id']: p for p in doc['products']}
    cores = {}
    for p in doc['products']:
        cores.setdefault(core(p), []).append(p['id'])
    cands = []
    cdir = os.path.join(args.work, 'candidates')
    for fn in sorted(os.listdir(cdir)) if os.path.isdir(cdir) else []:
        if fn.endswith('.jsonl'):
            cands += read_jsonl(os.path.join(cdir, fn))
    if not cands:
        raise SystemExit('no candidates: run collect / import-off first')
    items, safe_patches, safe_corr = [], {}, {}
    # candidates that disagree with each other about the same product
    seen = {}
    for c in cands:
        cid = (c.get('match') or {}).get('catalogId')
        if cid and 'abv' in c['fields'] and c['fields']['abv']['exactness'] == 'exact':
            seen.setdefault(cid, []).append((c['id'], c['fields']['abv']['value']))
    clash = {cid: v for cid, v in seen.items() if len({x[1] for x in v}) > 1}
    for c in cands:
        cid = (c.get('match') or {}).get('catalogId')
        rec = {'candidate': c['id'], 'source': c['source']['name'], 'url': c['source']['url'],
               'licenseHold': c['licenseHold'], 'catalogId': cid, 'results': []}
        if not cid or cid not in byid:
            near = cores.get(core(c))
            if near:
                rec['results'].append({'field': '*', 'class': 'possible_duplicate',
                                       'detail': f'no explicit match, but brand+name resembles {near}'})
            elif c['fields'].get('abv') or any(p.get('documented') for p in c['fields'].get('presentations', [])):
                rec['results'].append({'field': '*', 'class': 'new_product',
                                       'detail': 'unmatched product with usable data; needs human review before any add'})
            else:
                rec['results'].append({'field': '*', 'class': 'uncertain',
                                       'detail': 'unmatched and no usable field; ignored (no empty products)'})
            items.append(rec)
            continue
        prod = byid[cid]
        if cid in clash:
            rec['results'].append({'field': 'abv', 'class': 'conflict',
                                   'detail': f'candidates disagree on ABV: {clash[cid]}'})
        patch_pres = []
        for r in classify_candidate(c, prod, None):
            field, klass, detail = r[0], r[1], r[2]
            rec['results'].append({'field': field, 'class': klass, 'detail': detail})
            # licence hold: nothing new may enter; if the terms still allow citing a
            # source for a value the catalog already has, only the citation is proposed
            citation_only = c['licenseHold'] and c['source'].get('reuse', {}).get('citationOnly')
            if c['licenseHold'] and not (citation_only and klass == 'same'):
                continue
            if klass == 'filled':
                if field == 'presentations':
                    patch_pres.append(r[3])
                else:
                    value = c['fields'][field]['value']
                    p = safe_patches.setdefault(cid, {'id': cid, 'retrieved': c['source']['retrieved'], 'fieldSources': {}})
                    p[field] = value
                    p['fieldSources'].setdefault(field, []).append(build_source_entry(c, field))
            elif klass == 'same':
                has = {e.get('url') for e in (prod.get('fieldSources') or {}).get(field, [])}
                if c['source']['url'] not in has:
                    entry = build_source_entry(c, field, quote=not c['licenseHold'])
                    safe_corr.setdefault(cid, [])
                    if not any(e['url'] == entry['url'] and e['field'] == field for e in safe_corr[cid]):
                        safe_corr[cid].append(dict(entry, field=field))
        if patch_pres:
            p = safe_patches.setdefault(cid, {'id': cid, 'retrieved': c['source']['retrieved'], 'fieldSources': {}})
            p['presentations'] = [{k: v for k, v in x.items() if k != 'documented' and v is not None} for x in patch_pres]
            p['fieldSources'].setdefault('presentations', []).append(build_source_entry(c, 'presentations'))
        items.append(rec)
    # product-level duplicate check inside the catalog (informational)
    dups = {k: v for k, v in cores.items() if len(v) > 1}
    counts = {k: 0 for k in CLASSES}
    for it in items:
        for r in it['results']:
            counts[r['class']] += 1
    held = sum(1 for it in items if it['licenseHold'])
    proposal = {'generated': today(), 'catalogVersion': doc['version'], 'products': len(doc['products']),
                'counts': counts, 'candidates': len(cands), 'candidatesOnLicenseHold': held,
                'catalogCoreDuplicates': dups, 'items': items}
    # a corroborate entry per (id) may carry several fields: catalog_tool accepts a list
    research = {'patches': list(safe_patches.values()),
                'corroborate': {cid: (v[0] if len(v) == 1 else v) for cid, v in safe_corr.items()},
                'new': [], 'unresolved': []}
    write_json(os.path.join(args.work, 'proposal.json'), proposal)
    write_json(os.path.join(args.work, 'research_safe.json'), research)
    with open(os.path.join(args.work, 'proposal.md'), 'w', encoding='utf-8', newline='\n') as f:
        f.write(render_md(proposal, research))
    print(json.dumps(counts), '| held:', held, '| safe patches:', len(research['patches']),
          '| safe provenance entries:', sum(len(v) for v in safe_corr.values()))


def render_md(pr, research):
    L = [f"# Catalog update proposal ({pr['generated']})", '',
         f"Catalog v{pr['catalogVersion']}, {pr['products']} products. Candidates: {pr['candidates']} "
         f"({pr['candidatesOnLicenseHold']} on licence hold, never in research_safe.json).", '',
         '| class | fields |', '|---|---|']
    for k in CLASSES:
        L.append(f"| {k} | {pr['counts'][k]} |")
    L += ['', 'Applicable now (`scripts/catalog_tool.py merge`): '
          f"{len(research['patches'])} patches filling empty fields, "
          f"{sum(len(v) if isinstance(v, list) else 1 for v in research['corroborate'].values())} provenance entries "
          '(source recorded for a value the catalog already had; the value does not change).', '']
    for it in pr['items']:
        L.append(f"## {it['catalogId'] or '(no match)'}: {it['source']}" + (' [licence hold]' if it['licenseHold'] else ''))
        L.append(it['url'] or '')
        for r in it['results']:
            L.append(f"- **{r['class']}** `{r['field']}`: {r['detail']}")
        L.append('')
    if pr['catalogCoreDuplicates']:
        L += ['## Catalog entries that look alike (informational)', '']
        for k, v in pr['catalogCoreDuplicates'].items():
            L.append(f'- {v}')
    return '\n'.join(L) + '\n'


# --------------------------------------------------------------------------- selftest

def selftest():
    fx = lambda n: open(os.path.join(HERE, 'fixtures', n), encoding='utf-8').read()
    ok = True

    def check(name, cond):
        nonlocal ok
        print(('ok   ' if cond else 'FAIL ') + name)
        ok = ok and cond
    t, f = parse_page(fx('page_can_with_ingredients.html'))
    check('abv exact with unit', f['abv'] == {'value': 4.7, 'unit': '%vol', 'exactness': 'exact', 'quote': f['abv']['quote']})
    check('ingredients list', f['ingredients']['value'] == ['Água', 'Malte', 'Milho', 'Lúpulo'])
    check('presentations with kind, 100 ml excluded',
          f['presentations'] == [{'ml': 269, 'kind': 'can', 'documented': True}, {'ml': 350, 'kind': 'can', 'documented': True}])
    t, f = parse_page(fx('page_limit_abv.html'))
    check('limit is not exact', f['abv']['exactness'] == 'max')
    t, f = parse_page(fx('page_no_abv.html'))
    check('missing abv stays absent', 'abv' not in f and 'ingredients' not in f)
    check('litro maps to 1000 ml', f['presentations'] == [{'ml': 1000, 'kind': None, 'documented': True}])
    prod = {'abv': 4.7, 'ingredients': ['Água'], 'presentations': [{'ml': 350, 'kind': 'can'}], 'style': None,
            'fieldSources': {}}
    cand = {'source': {'url': 'https://x/', 'kind': 'manufacturer', 'name': 'X', 'retrieved': '2026-01-01'},
            'fields': {'abv': {'value': 4.9, 'unit': '%vol', 'exactness': 'exact', 'quote': 'q'},
                       'ingredients': {'value': ['Água'], 'quote': 'q'},
                       'presentations': [{'ml': 473, 'kind': 'can', 'documented': True},
                                         {'ml': 350, 'kind': 'bottle', 'documented': True}],
                       'style': {'value': 'Pilsen', 'quote': 'q'}}}
    got = {(r[0], r[1]) for r in classify_candidate(cand, prod, None)}
    check('conflict kept', ('abv', 'conflict') in got)
    check('same ingredients', ('ingredients', 'same') in got)
    check('new size filled and kind conflict', ('presentations', 'filled') in got and ('presentations', 'conflict') in got)
    check('style filled', ('style', 'filled') in got)
    cand['fields']['abv']['exactness'] = 'max'
    check('max abv uncertain', ('abv', 'uncertain') in {(r[0], r[1]) for r in classify_candidate(cand, prod, None)})
    raise SystemExit(0 if ok else 1)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest='cmd', required=True)
    c = sub.add_parser('collect'); c.add_argument('source'); c.add_argument('--delay', type=float, default=3.0)
    o = sub.add_parser('import-off'); o.add_argument('jsonl')
    sub.add_parser('compare'); sub.add_parser('selftest')
    for p in (c, o, sub.choices['compare']):
        p.add_argument('--work', default=DEFAULT_WORK)
    a = ap.parse_args()
    if a.cmd == 'collect': cmd_collect(a)
    elif a.cmd == 'import-off': cmd_import_off(a)
    elif a.cmd == 'compare': cmd_compare(a)
    else: selftest()


if __name__ == '__main__':
    main()
