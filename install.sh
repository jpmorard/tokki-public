#!/bin/sh
set -eu

DEFAULT_AGENTS="codex claude aider opencode vibe caveman"
BIN_DIR=${TOKKI_INSTALL_BIN_DIR:-}
INSTALL_METHOD=${TOKKI_INSTALL_METHOD:-auto}
WITH_WRAPPERS=0
UNINSTALL=0
AGENTS=
PACKAGE_VERSION=
PYTHON=${PYTHON:-python3}
TOKKI_INSTALL_CONFIG=${TOKKI_INSTALL_CONFIG:-}
TOKKI_MODEL_LOW_AGENT=${TOKKI_MODEL_LOW_AGENT:-}
TOKKI_MODEL_ALLOW_CROSS_AGENT_HANDOFF=${TOKKI_MODEL_ALLOW_CROSS_AGENT_HANDOFF:-}
TOKKI_MODEL_LOW_HANDOFF_MODEL=${TOKKI_MODEL_LOW_HANDOFF_MODEL:-}
TOKKI_MODEL_LOW_HANDOFF_COMMAND=${TOKKI_MODEL_LOW_HANDOFF_COMMAND:-}
TOKKI_MODEL_LOW_HANDOFF_ARGS=${TOKKI_MODEL_LOW_HANDOFF_ARGS:-}
PYPI_SIMPLE_URL=${TOKKI_PYPI_SIMPLE_URL:-https://pypi.org/simple/tokki/}

usage() {
    cat <<'EOF'
usage: install.sh [--with-wrappers] [--agent NAME] [--bin-dir DIR] [--method auto|uv|pipx|user] [--version X.Y.Z] [--uninstall]

Installs the compiled Tokki package from PyPI.

Options:
  --with-wrappers       Also install Tokki shims around detected agent commands.
  --agent NAME          Install a wrapper for one agent command. May be repeated.
  --bin-dir DIR         Directory for command shims. Defaults to ~/.local/bin.
  --method METHOD       Install method: auto, uv, pipx, or user. Defaults to auto.
  --version X.Y.Z       Install a specific Tokki version instead of the latest.
  --uninstall           Remove Tokki wrappers and the Tokki package.
  -h, --help            Show this help.
EOF
}

fail() {
    printf 'tokki install: %s\n' "$1" >&2
    exit 2
}

default_install_config() {
    "$PYTHON" - <<'PY'
from pathlib import Path
import os
import sys

home = Path.home()
if sys.platform == "win32":
    base = Path(os.environ.get("APPDATA") or home / "AppData" / "Roaming") / "tokki"
elif sys.platform == "darwin":
    base = home / "Library" / "Application Support" / "tokki"
else:
    base = Path(os.environ.get("XDG_CONFIG_HOME") or home / ".config") / "tokki"
print(base / "install.env")
PY
}

prompt_low_handoff_backend() {
    if [ -n "$TOKKI_MODEL_LOW_AGENT" ]; then
        return 0
    fi
    if [ ! -t 0 ]; then
        return 0
    fi
    printf 'Enable optional low-cost Claude handoff? [y/N] '
    IFS= read -r answer || answer=
    case "$answer" in
        y|Y|yes|YES|true|TRUE|on|ON)
            ;;
        *)
            return 0
            ;;
    esac
    printf 'Backend [codex/claude/ollama/local] (default codex): '
    IFS= read -r TOKKI_MODEL_LOW_AGENT || TOKKI_MODEL_LOW_AGENT=
    TOKKI_MODEL_LOW_AGENT=${TOKKI_MODEL_LOW_AGENT:-codex}
    case "$TOKKI_MODEL_LOW_AGENT" in
        codex)
            TOKKI_MODEL_ALLOW_CROSS_AGENT_HANDOFF=1
            TOKKI_MODEL_LOW_HANDOFF_MODEL=
            TOKKI_MODEL_LOW_HANDOFF_COMMAND=
            TOKKI_MODEL_LOW_HANDOFF_ARGS=
            ;;
        claude)
            printf 'Claude model slug (default claude-3-5-haiku-latest): '
            IFS= read -r TOKKI_MODEL_LOW_HANDOFF_MODEL || TOKKI_MODEL_LOW_HANDOFF_MODEL=
            TOKKI_MODEL_LOW_HANDOFF_MODEL=${TOKKI_MODEL_LOW_HANDOFF_MODEL:-claude-3-5-haiku-latest}
            TOKKI_MODEL_ALLOW_CROSS_AGENT_HANDOFF=1
            TOKKI_MODEL_LOW_HANDOFF_COMMAND=
            TOKKI_MODEL_LOW_HANDOFF_ARGS=
            ;;
        ollama)
            printf 'Ollama model name: '
            IFS= read -r TOKKI_MODEL_LOW_HANDOFF_MODEL || TOKKI_MODEL_LOW_HANDOFF_MODEL=
            [ -n "$TOKKI_MODEL_LOW_HANDOFF_MODEL" ] || fail "ollama requires a model name"
            TOKKI_MODEL_ALLOW_CROSS_AGENT_HANDOFF=1
            TOKKI_MODEL_LOW_HANDOFF_COMMAND=
            TOKKI_MODEL_LOW_HANDOFF_ARGS=
            ;;
        local)
            printf 'Local command name: '
            IFS= read -r TOKKI_MODEL_LOW_HANDOFF_COMMAND || TOKKI_MODEL_LOW_HANDOFF_COMMAND=
            [ -n "$TOKKI_MODEL_LOW_HANDOFF_COMMAND" ] || fail "local requires a command name"
            printf 'Local command args (optional, e.g. --model): '
            IFS= read -r TOKKI_MODEL_LOW_HANDOFF_ARGS || TOKKI_MODEL_LOW_HANDOFF_ARGS=
            printf 'Model name or alias (optional): '
            IFS= read -r TOKKI_MODEL_LOW_HANDOFF_MODEL || TOKKI_MODEL_LOW_HANDOFF_MODEL=
            TOKKI_MODEL_ALLOW_CROSS_AGENT_HANDOFF=1
            ;;
        *)
            fail "low-cost backend must be codex, claude, ollama, or local"
            ;;
    esac
}

write_install_config() {
    [ -n "$TOKKI_MODEL_LOW_AGENT" ] || return 0
    case "$TOKKI_MODEL_LOW_AGENT" in
        codex|claude|ollama|local)
            ;;
        *)
            fail "low-cost backend must be codex, claude, ollama, or local"
            ;;
    esac
    if [ "$TOKKI_MODEL_LOW_AGENT" = "ollama" ] && [ -z "$TOKKI_MODEL_LOW_HANDOFF_MODEL" ]; then
        fail "ollama requires TOKKI_MODEL_LOW_HANDOFF_MODEL or an interactive model name"
    fi
    if [ "$TOKKI_MODEL_LOW_AGENT" = "local" ] && [ -z "$TOKKI_MODEL_LOW_HANDOFF_COMMAND" ]; then
        fail "local requires TOKKI_MODEL_LOW_HANDOFF_COMMAND"
    fi
    [ -n "$TOKKI_INSTALL_CONFIG" ] || TOKKI_INSTALL_CONFIG=$(default_install_config)
    mkdir -p "$(dirname "$TOKKI_INSTALL_CONFIG")"
    cat >"$TOKKI_INSTALL_CONFIG" <<EOF
# tokki install configuration
TOKKI_MODEL_LOW_AGENT=$TOKKI_MODEL_LOW_AGENT
TOKKI_MODEL_ALLOW_CROSS_AGENT_HANDOFF=${TOKKI_MODEL_ALLOW_CROSS_AGENT_HANDOFF:-1}
TOKKI_MODEL_LOW_HANDOFF_MODEL=$TOKKI_MODEL_LOW_HANDOFF_MODEL
TOKKI_MODEL_LOW_HANDOFF_COMMAND=$TOKKI_MODEL_LOW_HANDOFF_COMMAND
TOKKI_MODEL_LOW_HANDOFF_ARGS=$TOKKI_MODEL_LOW_HANDOFF_ARGS
EOF
    printf 'low-handoff: %s\n' "$TOKKI_MODEL_LOW_AGENT"
    printf 'install-config: %s\n' "$TOKKI_INSTALL_CONFIG"
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --with-wrappers)
            WITH_WRAPPERS=1
            shift
            ;;
        --agent)
            [ "$#" -ge 2 ] || fail "--agent requires a command name"
            AGENTS="${AGENTS}${AGENTS:+ }$2"
            WITH_WRAPPERS=1
            shift 2
            ;;
        --bin-dir)
            [ "$#" -ge 2 ] || fail "--bin-dir requires a directory"
            BIN_DIR=$2
            shift 2
            ;;
        --method|--install-method)
            [ "$#" -ge 2 ] || fail "--method requires auto, uv, pipx, or user"
            INSTALL_METHOD=$2
            shift 2
            ;;
        --version)
            [ "$#" -ge 2 ] || fail "--version requires a version string"
            PACKAGE_VERSION=$2
            shift 2
            ;;
        --uninstall)
            UNINSTALL=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 2
            ;;
    esac
done

case "$INSTALL_METHOD" in
    auto|uv|pipx|user)
        ;;
    *)
        fail "--method must be auto, uv, pipx, or user"
        ;;
esac

if ! command -v "$PYTHON" >/dev/null 2>&1; then
    fail "python3 is required"
fi

if ! "$PYTHON" - <<'PY' >/dev/null 2>&1
import sys
raise SystemExit(0 if sys.version_info >= (3, 8) else 1)
PY
then
    fail "python 3.8 or newer is required"
fi

if [ -z "$BIN_DIR" ]; then
    [ -n "${HOME:-}" ] || fail "HOME is not set; use --bin-dir DIR"
    BIN_DIR=$HOME/.local/bin
fi

BIN_DIR=$("$PYTHON" -c 'import pathlib, sys; print(pathlib.Path(sys.argv[1]).expanduser().resolve())' "$BIN_DIR")
mkdir -p "$BIN_DIR"

PACKAGE_SPEC=tokki
if [ -n "$PACKAGE_VERSION" ]; then
    PACKAGE_SPEC="tokki==$PACKAGE_VERSION"
fi

if [ "$UNINSTALL" = "1" ]; then
    printf 'tokki uninstall\n'
    if [ -x "$BIN_DIR/tokki" ]; then
        for agent in $DEFAULT_AGENTS; do
            PATH="$BIN_DIR:$PATH" "$BIN_DIR/tokki" agent uninstall-wrapper "$agent" --bin-dir "$BIN_DIR" >/dev/null 2>&1 || true
        done
        printf 'wrappers: removed where present\n'
    fi
    removed=0
    if command -v uv >/dev/null 2>&1 && uv tool uninstall tokki >/dev/null 2>&1; then
        removed=1
    fi
    if command -v pipx >/dev/null 2>&1 && pipx uninstall tokki >/dev/null 2>&1; then
        removed=1
    fi
    if "$PYTHON" -m pip uninstall -y tokki >/dev/null 2>&1; then
        removed=1
    fi
    if [ -L "$BIN_DIR/tokki" ] || [ -f "$BIN_DIR/tokki" ]; then
        rm -f "$BIN_DIR/tokki"
    fi
    if [ "$removed" = "1" ]; then
        printf 'package: removed\n'
    else
        printf 'package: not found by uv, pipx, or pip\n'
    fi
    exit 0
fi

pypi_preflight_installable() {
    [ "${TOKKI_SKIP_PYPI_PRECHECK:-0}" = "1" ] && return 0
    "$PYTHON" - "$PACKAGE_VERSION" "$PYPI_SIMPLE_URL" <<'PY'
from html.parser import HTMLParser
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

version = sys.argv[1]
url = sys.argv[2]
needle = f"tokki-{version}-" if version else "tokki-"


class SimpleIndexParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.installable = False

    def handle_starttag(self, tag, attrs):
        if tag.lower() != "a":
            return
        attr = {name.lower(): value or "" for name, value in attrs}
        if "data-yanked" in attr:
            return
        href = attr.get("href", "")
        if needle in href and ".whl" in href.lower():
            self.installable = True


try:
    request = Request(url, headers={"Cache-Control": "no-cache"})
    with urlopen(request, timeout=15) as response:
        body = response.read().decode("utf-8", "replace")
except HTTPError as exc:
    raise SystemExit(1 if exc.code == 404 else 0)
except (OSError, URLError):
    raise SystemExit(0)

parser = SimpleIndexParser()
parser.feed(body)
raise SystemExit(0 if parser.installable else 1)
PY
}

require_pypi_release() {
    pypi_preflight_installable && return 0
    if [ -n "$PACKAGE_VERSION" ]; then
        fail "tokki $PACKAGE_VERSION is not installable from PyPI; publish protected wheels first or choose an available version"
    fi
    fail "no installable Tokki release is available on PyPI yet; publish protected wheels first"
}

install_with_uv() {
    command -v uv >/dev/null 2>&1 || return 1
    uv tool install --force "$PACKAGE_SPEC" || return 1
    INSTALL_BACKEND=uv
}

install_with_pipx() {
    if command -v pipx >/dev/null 2>&1; then
        pipx install --force "$PACKAGE_SPEC" || return 1
        INSTALL_BACKEND=pipx
        return 0
    fi
    if "$PYTHON" -m pipx --version >/dev/null 2>&1; then
        "$PYTHON" -m pipx install --force "$PACKAGE_SPEC" || return 1
        INSTALL_BACKEND=pipx
        return 0
    fi
    return 1
}

externally_managed_python() {
    "$PYTHON" - <<'PY' >/dev/null 2>&1
import sysconfig, pathlib, sys
marker = pathlib.Path(sysconfig.get_path("stdlib")) / "EXTERNALLY-MANAGED"
raise SystemExit(0 if marker.exists() else 1)
PY
}

install_with_user_pip() {
    if externally_managed_python; then
        printf 'tokki install: this python is externally managed (PEP 668); pip --user would fail.\n' >&2
        printf 'tokki install: install uv (https://docs.astral.sh/uv/) or pipx, then rerun.\n' >&2
        return 1
    fi
    "$PYTHON" -m pip install --user --upgrade --force-reinstall "$PACKAGE_SPEC" || return 1
    INSTALL_BACKEND=user
}

require_pypi_release

INSTALL_BACKEND=
printf 'tokki install\n'
case "$INSTALL_METHOD" in
    uv)
        install_with_uv || fail "uv is not available; install uv or use --method pipx"
        ;;
    pipx)
        install_with_pipx || fail "pipx is not available; install pipx or use --method uv"
        ;;
    user)
        install_with_user_pip || fail "user-site pip install failed; install uv or pipx and retry"
        ;;
    auto)
        install_with_uv || install_with_pipx || install_with_user_pip || fail "install failed; install uv or pipx and retry"
        ;;
esac

USER_BIN=$("$PYTHON" - <<'PY'
import pathlib
import site
print(pathlib.Path(site.getuserbase(), "bin").expanduser().resolve())
PY
)

HOME_TOKKI=
if [ -n "${HOME:-}" ]; then
    HOME_TOKKI=$HOME/.local/bin/tokki
fi

TOKKI_CMD=
if [ "$INSTALL_BACKEND" = "user" ]; then
    set -- "$USER_BIN/tokki" "$BIN_DIR/tokki" "$HOME_TOKKI"
else
    set -- "$BIN_DIR/tokki" "$HOME_TOKKI" "$USER_BIN/tokki"
fi
for candidate do
    [ -n "$candidate" ] || continue
    if [ -z "$TOKKI_CMD" ] && [ -x "$candidate" ]; then
        TOKKI_CMD=$candidate
    fi
done

if [ -z "$TOKKI_CMD" ] && command -v tokki >/dev/null 2>&1; then
    TOKKI_CMD=$(command -v tokki)
fi

if [ -z "$TOKKI_CMD" ]; then
    fail "tokki command was not found after install"
fi

if [ "$TOKKI_CMD" != "$BIN_DIR/tokki" ] && [ -x "$TOKKI_CMD" ]; then
    ln -sf "$TOKKI_CMD" "$BIN_DIR/tokki"
    TOKKI_CMD=$BIN_DIR/tokki
fi

printf 'tokki: %s\n' "$TOKKI_CMD"
PATH="$BIN_DIR:$PATH" "$TOKKI_CMD" --version

case ":$PATH:" in
    *":$BIN_DIR:"*)
        ;;
    *)
        printf 'warning: %s is not on your PATH; add this to your shell profile:\n' "$BIN_DIR"
        printf '  export PATH="%s:$PATH"\n' "$BIN_DIR"
        ;;
esac

if [ "$WITH_WRAPPERS" != "1" ]; then
    printf 'wrappers: skipped; rerun with --with-wrappers to add opt-in agent shims\n'
    printf 'bin: %s\n' "$BIN_DIR"
    exit 0
fi

prompt_low_handoff_backend
write_install_config

if [ -z "$AGENTS" ]; then
    # Only attempt wrappers for agents that are actually installed.
    detected=
    skipped=
    for agent in $DEFAULT_AGENTS; do
        if command -v "$agent" >/dev/null 2>&1 || [ -x "$BIN_DIR/$agent" ]; then
            detected="${detected}${detected:+ }$agent"
        else
            skipped="${skipped}${skipped:+ }$agent"
        fi
    done
    AGENTS=$detected
    if [ -n "$skipped" ]; then
        printf 'wrappers: not detected, skipping: %s\n' "$skipped"
    fi
    if [ -z "$AGENTS" ]; then
        printf 'wrappers: no supported agent commands detected\n'
        printf 'bin: %s\n' "$BIN_DIR"
        exit 0
    fi
fi

INSTALLED=
printf 'wrappers:\n'
for agent in $AGENTS; do
    wrapper_log=$(mktemp "${TMPDIR:-/tmp}/tokki-wrapper.XXXXXX")
    if PATH="$BIN_DIR:$PATH" "$TOKKI_CMD" agent install-wrapper "$agent" --bin-dir "$BIN_DIR" >"$wrapper_log" 2>&1; then
        cat "$wrapper_log"
        INSTALLED="${INSTALLED}${INSTALLED:+ }$agent"
    else
        # Surface the real reason: "not found" and "refusing to overwrite"
        # call for different user actions.
        printf -- '- %s: skipped\n' "$agent"
        sed 's/^/  /' "$wrapper_log"
    fi
    rm -f "$wrapper_log"
done

if [ -n "$INSTALLED" ]; then
    set -- doctor --strict --bin-dir "$BIN_DIR"
    for agent in $INSTALLED; do
        set -- "$@" --agent "$agent"
    done
    if PATH="$BIN_DIR:$PATH" "$TOKKI_CMD" "$@"; then
        printf 'verify: doctor --strict passed\n'
    else
        printf 'verify: install succeeded, but doctor --strict found issues above; try `tokki doctor --repair`\n' >&2
    fi
else
    printf '%s\n' '- no agent wrappers installed'
fi

printf 'bin: %s\n' "$BIN_DIR"
