# Public-history cleanup — 2026-08-15

This repository's reachable Git history was rewritten on 2026-08-15 to replace
the former professional-domain author and committer address with the GitHub
noreply address used for subsequent public commits. Retired public installer
scripts were also removed from reachable history because they no longer define
the supported distribution path.

This change is intentionally disruptive for existing clones: users should
re-clone the repository or reset their local branch to the new `main` history.
Forks, local clones, third-party caches, and archival services are outside the
maintainer's control and may retain the prior history.

The pre-rewrite complete-history backup is retained privately, with a recorded
SHA-256, for recovery and audit purposes. It is not a public artifact because
it contains the retired exposure surface.

The cleanup is followed by a signed public checkpoint. The repository policy
requires future public changes to pass the `verify` workflow before merge.

GitHub's rebase operation can rewrite committer metadata. A second cleanup pass
therefore normalised the rewritten commits before the signed checkpoint was
published.
