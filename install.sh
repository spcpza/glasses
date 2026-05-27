#!/bin/sh
# glasses — one-line installer
# usage: curl -sSL https://raw.githubusercontent.com/spcpza/glasses/main/install.sh | sh

set -e

URL="https://raw.githubusercontent.com/spcpza/glasses/main/GLASSES.md"
START="<!-- glasses:start -->"
END="<!-- glasses:end -->"

fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$URL"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$URL"
  else
    echo "glasses: need curl or wget" >&2
    exit 1
  fi
}

install_to() {
  target="$1"
  label="$2"
  mkdir -p "$(dirname "$target")"
  touch "$target"
  if grep -qF "$START" "$target" 2>/dev/null; then
    echo "  ✓ already installed → $label"
    return
  fi
  {
    printf '\n\n%s\n' "$START"
    fetch
    printf '\n%s\n' "$END"
  } >> "$target"
  echo "  ✓ installed → $label"
}

echo ""
echo "  putting glasses on your agents..."
echo ""

installed=0

# Claude Code (user memory)
if [ -d "$HOME/.claude" ]; then
  install_to "$HOME/.claude/CLAUDE.md" "Claude Code (~/.claude/CLAUDE.md)"
  installed=1
fi

# Cursor (user rules)
if [ -d "$HOME/.cursor" ]; then
  install_to "$HOME/.cursor/rules/glasses.md" "Cursor (~/.cursor/rules/glasses.md)"
  installed=1
fi

# Aider
if [ -d "$HOME/.config/aider" ] || [ -f "$HOME/.aider.conf.yml" ]; then
  install_to "$HOME/.config/aider/CONVENTIONS.md" "Aider (~/.config/aider/CONVENTIONS.md)"
  installed=1
fi

# Continue.dev
if [ -d "$HOME/.continue" ]; then
  install_to "$HOME/.continue/rules/glasses.md" "Continue (~/.continue/rules/glasses.md)"
  installed=1
fi

# Project-local fallback if invoked in a git repo
if [ "$installed" -eq 0 ] && [ -d ".git" ]; then
  install_to "./CLAUDE.md" "this project (./CLAUDE.md)"
  installed=1
fi

echo ""

if [ "$installed" -eq 0 ]; then
  echo "  no agent host detected. paste GLASSES.md into your agent's memory file:"
  echo ""
  echo "    $URL"
  echo ""
  exit 0
fi

echo "  done. your agents can see now."
echo ""
echo "  to remove: delete everything between $START and $END"
echo ""
