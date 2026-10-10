# Release verification

Tokki wheels are distributed privately. This repository publishes their integrity
evidence: each distributed version has a signed `release-artifacts.json`, its
Ed25519 signature, `SHA256SUMS`, and a dependency SBOM under `releases/<version>/`.
The signed manifest binds the wheel name, platform, byte size, SHA-256, source
commit/tree identifiers, and release trust-anchor fingerprints without publishing
implementation source or wheel bytes.

## Current release: 1.0.68

- [Manifest](releases/1.0.68/release-artifacts.json)
- [Signature](releases/1.0.68/release-artifacts.sig)
- [SHA-256 sums](releases/1.0.68/SHA256SUMS)
- [SPDX dependency inventory](releases/1.0.68/SBOM.spdx.json)

This is a public metadata record for a privately distributed runtime. It offers
no public wheel download and does not announce a PyPI runtime release. PyPI's
inert `tokki 0.0.1` placeholder contains no runtime; public runtime-wheel
publication remains pending.

Verify a received wheel's SHA-256 against `SHA256SUMS`. Maintainers and
custodians holding the complete authorized three-platform wheel directory can
authenticate its manifest, signature, and exact wheel bytes with:

```sh
tokki release verify-artifacts /path/to/tokki-1.0.68 --json
```

The private installer verifies adjacent authenticated release evidence where
that release contract applies. A hash match alone proves bytes, not source
review, security suitability, or a support commitment.

## Archived integrity record: 1.0.63

- [Manifest](releases/1.0.63/release-artifacts.json)
- [Signature](releases/1.0.63/release-artifacts.sig)
- [SHA-256 sums](releases/1.0.63/SHA256SUMS)
- [SPDX dependency inventory](releases/1.0.63/SBOM.spdx.json)

The archived `1.0.63` manifest's Ed25519 public key is
`06e20fac36f318c68a2cd57a151973cd14122a15590646f4ead792e83c2893f5`.
The historical benchmark in [README.md](README.md#public-report) continues to
describe `1.0.63`; this newer release record does not rerun that measurement.

## Public runtime publication policy

Before any public runtime wheel is offered for download, its version must have
a signed Git tag, a GitHub Release, a signed manifest, its Ed25519 signature,
`SHA256SUMS`, and a dependency SBOM. Publishing the four metadata files for a
private distribution does not itself fulfill the signed-tag or GitHub Release
requirements and does not authorize public runtime-wheel downloads.

Public release records are intentionally metadata-only. They are not source
releases, do not expose customer data, and do not substitute for an independent
security audit.

Each SPDX document is a source dependency inventory generated from the locked
Rust dependency graph. It identifies components and declared licenses; it is
not a claim that every listed component is linked into every platform wheel.
