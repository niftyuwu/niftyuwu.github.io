#!/bin/bash
set -e

REPO_URL="https://niftyuwu.github.io/repo/cydia"

dpkg-scanpackages -m debs > Packages

# Extra metadata for package pages/icons.
python3 - <<PY
from pathlib import Path
repo_url = "${REPO_URL}"
p = Path("Packages")
text = p.read_text()
blocks = text.strip().split("\n\n")
out = []
for b in blocks:
    if b.startswith("Package: com.niftyuwu.triplesilent\n"):
        lines = b.splitlines()
        lines = [l for l in lines if not (l.startswith("Icon:") or l.startswith("Depiction:") or l.startswith("SileoDepiction:"))]
        lines.append(f"Icon: {repo_url}/icons/triplesilent.png")
        lines.append(f"Depiction: {repo_url}/depictions/triplesilent.html")
        lines.append(f"SileoDepiction: {repo_url}/depictions/triplesilent.html")
        b = "\n".join(lines)
    out.append(b)
p.write_text("\n\n".join(out) + "\n")
PY

rm -f Packages.gz Packages.bz2
gzip -c9 Packages > Packages.gz
bzip2 -c9 Packages > Packages.bz2
