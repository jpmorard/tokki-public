# Tokki

<p align="center">
  <img
    src="https://raw.githubusercontent.com/jpmorard/tokki-public/main/docs/assets/tokki-logo.jpg"
    alt="Tokki logo"
    width="720"
  >
</p>

[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)

Tokki is a proprietary local developer tool distributed as compiled wheels.
It is a token killer for local developer sessions: built to cut avoidable local
agent context before it becomes prompt spend, while keeping implementation
details and local payloads private.

This public package and repository contain limited package information, license
terms, public proof figures, and security-contact guidance only.
Implementation source and detailed operational documentation are private.

## Public Report

Proof figures from the maintainer checkout (2026-06-05, local metadata only;
summary-only public evidence):

| Signal | Figure | Public evidence boundary |
|---|---:|---|
| Current-session demo | 99.0% avoidable context removed | summary-only local ledger; no prompts, raw logs, paths, or file bodies |
| Current-session net result | 4,233,059 tokens kept local | aggregate public proof, no per-event details |
| Repeatable benchmark pack | 80,485 net tokens saved | tokenizer-counted benchmark bundle; source hidden |
| Dirty-worktree context | 80,263 baseline -> 136 Tokki tokens, 590x | source-hidden repository context benchmark |
| Cost projection | $8.218 projected avoided | default demo prices; not billing evidence |
| Privacy guard | 0 strict findings | public-surface privacy scan passed |

This is a public teaser, not an operational manual. Detailed mechanisms,
commands, source paths, raw logs, and private reports stay out of this
repository.

## Tokki and Caveman Code

Caveman Code is the agent choice: a full terminal coding agent whose token
strategy is to keep its own replies terse and enforce tight tool-output budgets.

Tokki is the wrapper choice: a source-private, compiled local layer that keeps
your existing agent commands and reduces avoidable local context before it
becomes prompt spend. Public Tokki evidence remains summary-only: no prompts,
raw logs, file bodies, source paths, or implementation details.

Use Caveman Code when you want the agent itself to be the frugal surface. Use
Tokki when you want a private compiled-wheel layer around the agents you already
use. The two can complement each other: Tokki can install wrappers with
`tokki setup` without making the Tokki source public.

The private CLI also includes `tokki benchmark` for comparing report-path
timings. Its log-digest benchmark path uses the native Rust helper when
available and falls back to Python only for compatibility, while public
evidence stays summary-only.

## Install

Compiled wheel files are distributed privately to authorized users. This public
repo does not host wheel artifacts. After receiving the wheel matching your OS,
install it from a local path, then verify with `tokki --version` and
`tokki doctor --strict`.

After install, the non-destructive first-run check is:

```sh
tokki proof
tokki smoke
tokki privacy explain
```

To install available wrappers and run the same trust/adoption proof in one
flow:

```sh
tokki setup --guided
```

### macOS

Apple Silicon:

```sh
python3 -m pip install --user --upgrade --force-reinstall \
/path/to/tokki-1.0.17-py3-none-macosx_11_0_arm64.whl
export PATH="$HOME/Library/Python/3.*/bin:$HOME/.local/bin:$PATH"
tokki --version
```

Optional isolated install with `uv`:

```sh
uv tool install --force \
/path/to/tokki-1.0.17-py3-none-macosx_11_0_arm64.whl
tokki --version
```

Install wrappers after the wheel is installed:

```sh
tokki setup --guided
```

Uninstall:

```sh
python3 -m pip uninstall -y tokki
uv tool uninstall tokki 2>/dev/null || true
```

### Linux

x86_64:

```sh
python3 -m pip install --user --upgrade --force-reinstall \
/path/to/tokki-1.0.17-py3-none-manylinux_2_35_x86_64.whl
export PATH="$HOME/.local/bin:$PATH"
tokki --version
```

Optional isolated install with `pipx`:

```sh
python3 -m pipx install --force \
/path/to/tokki-1.0.17-py3-none-manylinux_2_35_x86_64.whl
tokki --version
```

Install wrappers after the wheel is installed:

```sh
tokki setup --guided
```

Uninstall:

```sh
python3 -m pip uninstall -y tokki
python3 -m pipx uninstall tokki 2>/dev/null || true
```

### Agent Wrappers On POSIX

After install, run `tokki setup` to install wrappers and check the health of the
local wrapper path. For `codex`, the health report also compares the installed
CLI version against the latest published `@openai/codex` version when both can
be parsed as real semver tokens; otherwise the version stays unknown and Tokki
does not claim an upgrade.

Tokki does not silently replace one agent command with another by default.
Cross-agent low-tier handoff, for example launching Codex from a simple Claude
one-shot prompt, is opt-in. The installer can write a small `install.env`
config that sets `TOKKI_MODEL_LOW_AGENT`, `TOKKI_MODEL_ALLOW_CROSS_AGENT_HANDOFF`,
and optionally `TOKKI_MODEL_LOW_HANDOFF_MODEL`; env vars still override that
file. Set the agent to `codex` to route to the latest GPT mini model, `claude`
to stay on Claude with the canonical low-model preset
`claude-3-5-haiku-latest`, or `ollama` with an explicit model name. Set the
agent to `local` with a command name and optional fixed args to use another
local model CLI instead of Ollama. Claude handoff model aliases are allowlisted;
stale or invalid aliases fall back to `claude-3-5-haiku-latest` and are recorded
as metadata-only invalid config events.

Tokki also honors `TOKKI_TOKEN_SAVING_MODE=aggressive`,
`TOKKI_TOKEN_SAVING_MODE=ultimate`, or `TOKKI_TOKEN_SAVING_MODE=emergency`.
Weekly-hours quota signals can escalate the mode automatically: `25%` remaining
switches to `aggressive`, `10%` to `ultimate`, and `5%` to `emergency`. The
lower modes reduce the compact-response budget, compact-trigger threshold, and
native output budgets more aggressively than the default mode. When
output overflows, Tokki emits a terse local handle receipt and keeps the full
payload recoverable with `tokki retrieve <handle>`.

### Windows

x86_64 PowerShell:

```powershell
py -m pip install --user --upgrade --force-reinstall `
C:\Path\To\tokki-1.0.17-py3-none-win_amd64.whl
tokki --version
```

Optional isolated install with `pipx`:

```powershell
py -m pip install --user pipx
py -m pipx ensurepath
pipx install --force `
C:\Path\To\tokki-1.0.17-py3-none-win_amd64.whl
tokki --version
```

Install wrappers after the wheel is installed:

```powershell
tokki setup --guided
```

Uninstall:

```powershell
py -m pip uninstall -y tokki
pipx uninstall tokki
```

Windows notes:

- The core CLI (`tokki run`, `fix`, `map`, `query`, `model-route`, ...) works
  natively in PowerShell and cmd.
- The installer and `tokki setup` install native `.exe` agent wrappers in the
  same PATH directory as `tokki.exe` when supported agent commands are present.
  Use `-NoWrappers` or `TOKKI_NO_WRAPPERS=1` for a core-CLI-only install. POSIX
  shell shims remain the Unix/WSL path.
- Tokki stores its runtime config under `%APPDATA%\tokki\runtime.json` and
  logs/reports under `%LOCALAPPDATA%\tokki\`. Set `TOKKI_RUNTIME_CONFIG`,
  `TOKKI_LOG_DIR`, or `TOKKI_REPORT_DIR` to override.

## Public Package

Current public package: `tokki 1.0.17`.

`1.0.17` provides private wheelhouse artifacts for:

- macOS arm64: `tokki-1.0.17-py3-none-macosx_11_0_arm64.whl`
- Linux x86_64: `tokki-1.0.17-py3-none-manylinux_2_35_x86_64.whl`
- Windows x86_64: `tokki-1.0.17-py3-none-win_amd64.whl`

The wheel intentionally does not include private implementation source,
repository-local tests, protected Rust source, or private development scripts.

## Support

Use GitHub issues for installation problems and public package metadata issues.
For failure reports, prefer `tokki issue report` so Tokki can send a bounded,
privacy-filtered digest with the issue. Use `tokki issue fix` to read a
`tokki-auto` issue back into a local fix bundle. Do not post secrets, prompts, command output,
private repository contents, or customer material in public issues. The
`tokki-auto` label should stay restricted to trusted triage users so untrusted
reporters cannot publish into the fix queue.

For a local trust summary before filing anything public, run
`tokki privacy explain`. It describes what Tokki stores locally, what public
reports omit, and which audit commands to run before sharing artifacts.

For installation or wrapper issues, run `tokki install doctor` first. Use
`tokki path doctor` / `tokki path repair` for PATH drift, `tokki installer-parity`
and `tokki installer-matrix` to compare POSIX, Windows, uv, pipx, and user-site
installer contracts across the private/public surfaces, and `tokki conformance`
for the composed local suite. `tokki release evidence --output tokki-evidence.json`
and `tokki release evidence verify --manifest tokki-evidence.json` write and
verify metadata-only release provenance. `tokki support-bundle --output
tokki-support.json` writes a metadata-only diagnostic bundle for support.
