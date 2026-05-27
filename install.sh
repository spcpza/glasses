#!/bin/sh
# glasses — installer
# usage:
#   curl -sSL https://raw.githubusercontent.com/spcpza/glasses/main/install.sh | sh
# or inspect first:
#   curl -sSLO https://raw.githubusercontent.com/spcpza/glasses/main/install.sh
#   less install.sh && sh install.sh

set -eu

REPO="https://raw.githubusercontent.com/spcpza/glasses/main"
URL="$REPO/GLASSES.md"
SENTINEL="## Lens 1"
START="<!-- glasses:start -->"
END="<!-- glasses:end -->"

say() { printf '%s\n' "$*"; }

fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$URL"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$URL"
  else
    say "glasses: need curl or wget" >&2
    exit 1
  fi
}

say ""
say "  source: $URL"
say ""

PAYLOAD="$(fetch)"

# sentinel check — refuse to install if payload doesn't look like glasses
if ! printf '%s' "$PAYLOAD" | grep -qF "$SENTINEL"; then
  say "  refused: fetched content missing sentinel ($SENTINEL)" >&2
  exit 1
fi

install_to() {
  target="$1"
  label="$2"
  mkdir -p "$(dirname "$target")"
  touch "$target"
  if grep -qF "$START" "$target" 2>/dev/null; then
    say "  already installed → $label"
    return
  fi
  {
    printf '\n\n%s\n' "$START"
    printf '%s\n' "$PAYLOAD"
    printf '%s\n' "$END"
  } >> "$target"
  say "  installed → $label"
}

installed=0

[ -d "${HOME:-}/.claude" ] && {
  install_to "$HOME/.claude/CLAUDE.md" "Claude Code"
  installed=1
}

[ -d "${HOME:-}/.cursor" ] && {
  install_to "$HOME/.cursor/rules/glasses.md" "Cursor"
  installed=1
}

if [ -d "${HOME:-}/.config/aider" ] || [ -f "${HOME:-}/.aider.conf.yml" ]; then
  install_to "$HOME/.config/aider/CONVENTIONS.md" "Aider"
  installed=1
fi

[ -d "${HOME:-}/.continue" ] && {
  install_to "$HOME/.continue/rules/glasses.md" "Continue"
  installed=1
}

if [ "$installed" -eq 0 ] && [ -d ".git" ]; then
  install_to "./CLAUDE.md" "this project"
  installed=1
fi

say ""

if [ "$installed" -eq 0 ]; then
  say "  no agent host detected. paste the contents of:"
  say "    $URL"
  say "  into your agent's memory file."
  exit 0
fi

say "  to remove: delete the block between $START and $END"
say ""
