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

## Install

Fast path:

```sh
curl -fsSL https://raw.githubusercontent.com/jpmorard/tokki-public/main/install.sh | sh
```

To install opt-in wrappers around detected agent commands:

```sh
curl -fsSL https://raw.githubusercontent.com/jpmorard/tokki-public/main/install.sh | sh -s -- --with-wrappers
```

After install, run `tokki setup` to install wrappers and check the health of the
local wrapper path.

On Ubuntu or Debian, use `pipx`:

```sh
sudo apt update
sudo apt install -y pipx
python3 -m pipx ensurepath
python3 -m pipx install --force tokki
export PATH="$HOME/.local/bin:$PATH"
tokki --version
```

On macOS, a user-site install is also supported:

```sh
python3 -m pip config set global.user true
python3 -m pip install --upgrade --force-reinstall tokki
mkdir -p "$HOME/.local/bin"
ln -sf "$(python3 -m site --user-base)/bin/tokki" "$HOME/.local/bin/tokki"
tokki --version
```

## Public Package

Current public package: `tokki 0.3.10`.

`0.3.10` publishes wheels for:

- macOS arm64: `tokki-0.3.10-py3-none-macosx_11_0_arm64.whl`
- Linux x86_64: `tokki-0.3.10-py3-none-manylinux_2_35_x86_64.whl`
- Windows x86_64: `tokki-0.3.10-py3-none-win_amd64.whl`

The wheel intentionally does not include private implementation source,
repository-local tests, protected Rust source, or private development scripts.

## Support

Use GitHub issues for installation problems and public package metadata issues.
Do not post secrets, prompts, command output, private repository contents, or
customer material in public issues.
