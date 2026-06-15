# Tokki

<p align="center">
  <img
    src="https://raw.githubusercontent.com/jpmorard/tokki-public/main/docs/assets/tokki-logo.jpg"
    alt="Tokki logo"
    width="720"
  >
</p>

[![PyPI](https://img.shields.io/pypi/v/tokki.svg)](https://pypi.org/project/tokki/)
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

Tokki ships as compiled wheels. Use the installer for your OS, then verify with
`tokki --version` and `tokki doctor --strict`.

After install, the non-destructive first-run check is:

```sh
tokki smoke
tokki privacy explain
```

To install available wrappers and run the same trust/adoption proof in one
flow:

```sh
tokki setup --guided
```

### macOS

Fast path:

```sh
curl -fsSL https://raw.githubusercontent.com/jpmorard/tokki-public/main/install.sh | sh
```

Optional agent wrappers for Codex, Claude, Aider, OpenCode, Vibe, and Caveman:

```sh
curl -fsSL https://raw.githubusercontent.com/jpmorard/tokki-public/main/install.sh | sh -s -- --with-wrappers
```

Manual user-site fallback:

```sh
python3 -m pip install --upgrade --force-reinstall tokki
mkdir -p "$HOME/.local/bin"
ln -sf "$(python3 -m site --user-base)/bin/tokki" "$HOME/.local/bin/tokki"
export PATH="$HOME/.local/bin:$PATH"
tokki --version
```

Uninstall:

```sh
curl -fsSL https://raw.githubusercontent.com/jpmorard/tokki-public/main/install.sh | sh -s -- --uninstall
```

### Linux

Fast path:

```sh
curl -fsSL https://raw.githubusercontent.com/jpmorard/tokki-public/main/install.sh | sh
```

Optional wrappers:

```sh
curl -fsSL https://raw.githubusercontent.com/jpmorard/tokki-public/main/install.sh | sh -s -- --with-wrappers
```

Ubuntu/Debian manual path with `pipx`:

```sh
sudo apt update
sudo apt install -y pipx
python3 -m pipx ensurepath
python3 -m pipx install --force tokki
export PATH="$HOME/.local/bin:$PATH"
tokki --version
```

Uninstall:

```sh
curl -fsSL https://raw.githubusercontent.com/jpmorard/tokki-public/main/install.sh | sh -s -- --uninstall
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

Fast path (PowerShell):

```powershell
irm https://raw.githubusercontent.com/jpmorard/tokki-public/main/install.ps1 | iex
```

To pin a version, set `TOKKI_VERSION` first (parameters cannot be passed
through `irm | iex`):

```powershell
$env:TOKKI_VERSION = "0.3.11"
irm https://raw.githubusercontent.com/jpmorard/tokki-public/main/install.ps1 | iex
```

Or download the script and run it with an explicit version:

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1 -Version 0.3.11
```

Choose an installer backend explicitly:

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1 -Method uv
powershell -ExecutionPolicy Bypass -File install.ps1 -Method pipx
powershell -ExecutionPolicy Bypass -File install.ps1 -Method user
```

If `tokki` installs but this shell cannot find it yet, rerun with `-AddToPath`
or set `TOKKI_ADD_TO_PATH=1` before the `irm | iex` command.

The installer tries `uv tool install`, then `pipx install`, then
`pip install --user` (via `python` or the `py` launcher), and prints the
directory to add to `PATH` if `tokki` is not found after install. Typical
script locations are `%USERPROFILE%\.local\bin` (uv, pipx) or
`<python user base>\Scripts` (pip `--user`).

Manual install with pipx:

```powershell
py -m pip install --user pipx
py -m pipx ensurepath
pipx install --force tokki
tokki --version
```

Uninstall:

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1 -Uninstall
```

Windows notes:

- The core CLI (`tokki run`, `fix`, `map`, `query`, `model-route`, ...) works
  natively in PowerShell and cmd.
- Agent wrappers installed by `tokki setup` use POSIX shims and are not
  supported in native Windows shells; run Tokki inside WSL (recommended) or
  Git Bash if you want wrapped agent commands. Inside WSL, use the Linux
  install path above.
- Tokki stores its runtime config under `%APPDATA%\tokki\runtime.json` and
  logs/reports under `%LOCALAPPDATA%\tokki\`. Set `TOKKI_RUNTIME_CONFIG`,
  `TOKKI_LOG_DIR`, or `TOKKI_REPORT_DIR` to override.

## Public Package

Current public package: `tokki 0.3.20`.

`0.3.20` publishes wheels for:

- macOS arm64: `tokki-0.3.20-py3-none-macosx_11_0_arm64.whl`
- Linux x86_64: `tokki-0.3.20-py3-none-manylinux_2_35_x86_64.whl`
- Windows x86_64: `tokki-0.3.20-py3-none-win_amd64.whl`

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
