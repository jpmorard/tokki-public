#!/usr/bin/env python3
"""Fail closed when public Tokki claims drift from release evidence."""

from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
README = (ROOT / "README.md").read_text(encoding="utf-8")
RELEASES = (ROOT / "RELEASES.md").read_text(encoding="utf-8")
VERSION = re.search(r"Current public package: `tokki ([0-9]+\.[0-9]+\.[0-9]+)`\.", README)
if VERSION is None:
    raise SystemExit("missing canonical public package version")
version = VERSION.group(1)

runtime_versions = re.findall(
    r"current private runtime is `Tokki ([0-9]+\.[0-9]+\.[0-9]+)`", README
)
if runtime_versions != [version]:
    raise SystemExit("README private runtime version does not match the public package")
evidence_versions = re.findall(
    r"\[v([0-9]+\.[0-9]+\.[0-9]+) release evidence\]\(RELEASES\.md\)", README
)
if evidence_versions != [version]:
    raise SystemExit("README release-evidence link does not match the public package")
release_versions = re.findall(
    r"^## Current release: ([0-9]+\.[0-9]+\.[0-9]+)$", RELEASES, re.MULTILINE
)
if release_versions != [version]:
    raise SystemExit("RELEASES current version does not match the public package")
for filename in (
    "release-artifacts.json",
    "release-artifacts.sig",
    "SHA256SUMS",
    "SBOM.spdx.json",
):
    if f"releases/{version}/{filename}" not in RELEASES:
        raise SystemExit(f"RELEASES is missing current evidence link: {filename}")
if "tokki release evidence verify" in RELEASES:
    raise SystemExit("RELEASES uses the wrong verifier for release-artifacts.json")
if f"tokki release verify-artifacts /path/to/tokki-{version} --json" not in RELEASES:
    raise SystemExit("RELEASES is missing the current full-wheelhouse verification command")

release = ROOT / "releases" / version
manifest_path = release / "release-artifacts.json"
signature_path = release / "release-artifacts.sig"
sums_path = release / "SHA256SUMS"
sbom_path = release / "SBOM.spdx.json"
for path in (manifest_path, signature_path, sums_path, sbom_path):
    if not path.is_file():
        raise SystemExit(f"missing release evidence: {path.relative_to(ROOT)}")

manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
signature = json.loads(signature_path.read_text(encoding="utf-8"))
sbom = json.loads(sbom_path.read_text(encoding="utf-8"))
if manifest.get("schema") != "tokki.release_artifacts.v1" or manifest.get("version") != version:
    raise SystemExit("release manifest has an unexpected schema or version")
if signature.get("schema") != "tokki.release_artifacts_signature.v1":
    raise SystemExit("release signature has an unexpected schema")
if not re.fullmatch(r"ed25519:[0-9a-f]{128}", signature.get("signature", "")):
    raise SystemExit("release signature is not canonical Ed25519 hex")
canonical_manifest = json.dumps(manifest, separators=(",", ":")).encode("utf-8")
if signature.get("manifest_sha256") != hashlib.sha256(canonical_manifest).hexdigest():
    raise SystemExit("release signature does not bind the published manifest")
if sbom.get("spdxVersion") != "SPDX-2.3" or not sbom.get("packages"):
    raise SystemExit("release SBOM is missing SPDX-2.3 package inventory")

hashes = {}
for line in sums_path.read_text(encoding="utf-8").splitlines():
    digest, filename = line.split(maxsplit=1)
    hashes[filename.removeprefix("./")] = digest
artifacts = manifest.get("artifacts")
if not isinstance(artifacts, list) or len(artifacts) != 3:
    raise SystemExit("release manifest must describe exactly three wheels")
for artifact in artifacts:
    name = artifact.get("filename")
    digest = artifact.get("sha256")
    if not isinstance(name, str) or hashes.get(name) != digest:
        raise SystemExit(f"release hash mismatch for {name!r}")
    if name not in README:
        raise SystemExit(f"README does not document published wheel {name}")

for forbidden in (
    "@" + "thalesgroup.com",
    'export PATH="$HOME/Library/Python/3.' + '*/bin',
    "Use `tokki issue fix` to " + "read",
    "claude-3-5-" + "haiku-latest",
):
    if forbidden in README or any(
        forbidden in path.read_text(encoding="utf-8", errors="ignore")
        for path in ROOT.rglob("*")
        if path.is_file() and ".git" not in path.parts
    ):
        raise SystemExit(f"forbidden public-surface marker: {forbidden}")

if "PyPI's current inert name-retention placeholder is `tokki 0.0.1`." not in README:
    raise SystemExit("README must disclose the inert PyPI name-retention wheel")

print(f"public surface: pass ({version}, {len(artifacts)} signed artifacts)")
