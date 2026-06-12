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

install_with_uv() {
    command -v uv >/dev/null 2>&1 || return 1
    uv tool install --force "$PACKAGE_SPEC"
}

install_with_pipx() {
    if command -v pipx >/dev/null 2>&1; then
        pipx install --force "$PACKAGE_SPEC"
        return 0
    fi
    if "$PYTHON" -m pipx --version >/dev/null 2>&1; then
        "$PYTHON" -m pipx install --force "$PACKAGE_SPEC"
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
    "$PYTHON" -m pip install --user --upgrade --force-reinstall "$PACKAGE_SPEC"
}

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
for candidate in "$BIN_DIR/tokki" "$HOME_TOKKI" "$USER_BIN/tokki"; do
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
