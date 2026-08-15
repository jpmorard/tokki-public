# Release verification

Tokki wheels remain private. Their integrity proof is public: every distributed
version must publish a signed `release-artifacts.json`, its Ed25519 signature,
and `SHA256SUMS` under `releases/<version>/`. The files bind the wheel name,
platform, byte size, SHA-256, source commit/tree identifiers, and release trust
anchor fingerprints without publishing implementation source or wheel bytes.

## Current release: 1.0.53

- [Manifest](releases/1.0.53/release-artifacts.json)
- [Signature](releases/1.0.53/release-artifacts.sig)
- [SHA-256 sums](releases/1.0.53/SHA256SUMS)
- [SPDX dependency inventory](releases/1.0.53/SBOM.spdx.json)

The manifest's Ed25519 public key is
`06e20fac36f318c68a2cd57a151973cd14122a15590646f4ead792e83c2893f5`.
Verify a received wheel's SHA-256 against `SHA256SUMS`, then verify the signed
manifest with the installed Tokki release-evidence verifier:

```sh
tokki release evidence verify \
  --manifest releases/1.0.53/release-artifacts.json \
  --public-key-hex 06e20fac36f318c68a2cd57a151973cd14122a15590646f4ead792e83c2893f5
```

The installer also verifies adjacent authenticated release evidence where that
release contract applies. A hash match alone proves bytes, not source review,
security suitability, or a support commitment.

## Publication policy

Each public version must have a signed Git tag, a GitHub Release, these three
evidence files, and a dependency SBOM before a wheel is offered externally.
The public release record is intentionally metadata-only. It is not a source
release, does not expose customer data, and does not substitute for an
independent security audit.

The `1.0.53` SPDX document is a source dependency inventory generated from the
locked Rust dependency graph. It identifies components and declared licenses;
it is not a claim that every listed component is linked into every platform
wheel.
