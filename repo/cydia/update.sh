#!/bin/bash
set -e

REPO_URL="https://niftyuwu.github.io/repo/cydia"

# Generate package index from .deb files.
dpkg-scanpackages -m debs > Packages

# Add Cydia/Sileo depictions and icons.
python3 - <<PY
from pathlib import Path
repo_url = "${REPO_URL}"
metadata = {
    "com.niftyuwu.triplesilent": {
        "icon": "triplesilent.png",
        "depiction": "triplesilent.html",
    },
    "com.niftyuwu.ddgsearch": {
        "icon": "ddgsearch.png",
        "depiction": "ddgsearch.html",
    },
    "com.niftyuwu.slidetouwu": {
        "icon": "slidetouwu.png",
        "depiction": "slidetouwu.html",
    },
}
p = Path("Packages")
blocks = [b for b in p.read_text().strip().split("\n\n") if b.strip()]
out = []
for block in blocks:
    lines = [line for line in block.splitlines() if not (
        line.startswith("Icon:") or line.startswith("Depiction:") or line.startswith("SileoDepiction:")
    )]
    package = None
    for line in lines:
        if line.startswith("Package: "):
            package = line.split(": ", 1)[1].strip()
            break
    if package in metadata:
        data = metadata[package]
        lines.append(f"Icon: {repo_url}/icons/{data['icon']}")
        lines.append(f"Depiction: {repo_url}/depictions/{data['depiction']}")
        lines.append(f"SileoDepiction: {repo_url}/depictions/{data['depiction']}")
    out.append("\n".join(lines))
p.write_text("\n\n".join(out) + "\n")
PY

rm -f Packages.gz Packages.bz2
gzip -c9 Packages > Packages.gz
bzip2 -c9 Packages > Packages.bz2
