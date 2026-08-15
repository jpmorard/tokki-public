# Tokki public privacy boundary

Tokki is distributed as a proprietary local wheel. This repository is a public
documentation and release-evidence surface; it does not receive local prompts,
logs, repository contents, or wheel telemetry merely because it is viewed.

## Local data

Tokki can retain local evidence needed for compact receipts, recovery handles,
diagnostics, and explicitly requested reports. A handle is a local locator, not
a public identifier and not proof that persistence succeeded. The installed CLI
is the authoritative machine-readable explanation for a given release:

```sh
tokki privacy explain
tokki doctor --strict
```

On Windows, runtime configuration defaults to `%APPDATA%\tokki\runtime.json`
and logs/reports default to `%LOCALAPPDATA%\tokki\`; the environment variables
`TOKKI_RUNTIME_CONFIG`, `TOKKI_LOG_DIR`, and `TOKKI_REPORT_DIR` change those
locations. POSIX locations and any configured overrides must be inspected with
`tokki privacy explain` on the installed wheel rather than inferred from this
public repository.

## Network boundary

`tokki issue report --dry-run` creates a local redacted preview. It does not
post to GitHub. Reporting remains a separate reviewed action by the user.
`tokki issue fix` is unsupported in the protected runtime and does not execute
issue content. Do not include secrets, prompts, raw logs, customer material,
absolute paths, or private branch names in any public issue.

Tokki does not make a public claim here about encryption at rest, retention
duration, deletion guarantees, or operating-system ACLs. Those properties are
release- and deployment-specific and must be established by the installed
wheel's `privacy explain` output and the deploying organization's policy.

## Support and deletion

Before sharing a support artifact, review it locally and use the CLI's
privacy/support commands to identify its boundary. For a vulnerability, use
GitHub's private vulnerability-reporting flow described in
[SECURITY.md](SECURITY.md), not a public issue. A future version that changes
this contract must update this document and its signed release evidence.
