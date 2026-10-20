"""Independent check of a Bebometro export package (bebometro-pacote.zip).

Usage: python tool/verify_export_zip.py <file.zip>

Uses only the standard library (zipfile, hashlib). Checks: valid ZIP and CRCs,
every manifest entry exists with the right size and SHA-256, nothing in the ZIP
is missing from the manifest, names are safe to extract (no absolute path, no
'..', no backslash, no drive letter), totals match, omitted photos are not in
the ZIP. Exit code 0 = everything matches.
"""
import hashlib
import json
import sys
import zipfile


def main(path):
    problems = []
    with zipfile.ZipFile(path) as z:
        bad = z.testzip()
        if bad:
            problems.append("crc error in " + bad)
        names = z.namelist()
        for n in names:
            if n.startswith("/") or ".." in n.split("/") or "\\" in n or ":" in n:
                problems.append("unsafe name: " + n)
        if len(set(names)) != len(names):
            problems.append("duplicate entries")
        manifest = json.loads(z.read("manifest.json").decode("utf-8"))
        listed = {f["path"]: f for f in manifest["files"]}
        for p, f in listed.items():
            if p not in names:
                problems.append("missing: " + p)
                continue
            data = z.read(p)
            if len(data) != f["bytes"]:
                problems.append("size differs: " + p)
            if hashlib.sha256(data).hexdigest() != f["sha256"]:
                problems.append("sha256 differs: " + p)
        extra = set(names) - set(listed) - {"manifest.json"}
        if extra:
            problems.append("not in manifest: " + ", ".join(sorted(extra)))
        t = manifest["totals"]
        photos = [p for p in listed if p.startswith("photos/")]
        if t["files"] != len(listed):
            problems.append("totals.files wrong")
        if t["photos_included"] != len(photos):
            problems.append("totals.photos_included wrong")
        if t["bytes"] != sum(f["bytes"] for f in listed.values()):
            problems.append("totals.bytes wrong")
        if t["photos_omitted"] != len(manifest["omitted"]):
            problems.append("totals.photos_omitted wrong")
        for o in manifest["omitted"]:
            if o["path"] in names:
                problems.append("omitted but present: " + o["path"])
    if problems:
        print("FAIL")
        for p in problems:
            print(" -", p)
        return 1
    print("OK: %d files, %d photos, %d omitted" % (len(listed), len(photos), len(manifest["omitted"])))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
