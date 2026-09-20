#!/bin/sh
# Layer 1 — bootstrap a fresh machine into the workspace.
#
#   curl -fsSL https://raw.githubusercontent.com/SanjeevThapaUG/workspace/main/shared/machines/bootstrap.sh | sh
#
# Does exactly four things and never grows: install git/just/gum/gh, log in to
# GitHub, clone the workspace skeleton to ~/workspace, hand off to `just setup`.
# Everything else lives in setup/ so it can be re-run without this script.
set -eu

WORKSPACE="${WORKSPACE:-$HOME/workspace}"
SKELETON="${SKELETON:-SanjeevThapaUG/workspace}"

say() { printf '\033[1;36m▸ %s\033[0m\n' "$*"; }

case "$(uname -s)" in
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      say "Installing Homebrew"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    say "Installing git, just, gum, gh"
    brew install git just gum gh
    ;;
  Linux)
    if [ -f /etc/arch-release ]; then
      say "Installing git, just, gum, gh"
      sudo pacman -Sy --needed --noconfirm git just gum github-cli
    else
      echo "Unsupported Linux flavour — only Arch-based systems are handled." >&2
      exit 1
    fi
    ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

# The skeleton is private: gh's credential helper lets us clone over HTTPS
# before any SSH key exists on this machine. Keys are set up by `just setup`.
if ! gh auth status >/dev/null 2>&1; then
  say "Log in to GitHub (opens a device-code flow)"
  gh auth login --hostname github.com --git-protocol https --web
fi

if [ ! -d "$WORKSPACE/.git" ]; then
  say "Cloning $SKELETON → $WORKSPACE"
  gh repo clone "$SKELETON" "$WORKSPACE"
else
  say "Workspace already present at $WORKSPACE"
fi

cd "$WORKSPACE"
say "Handing off to: just setup"
exec just setup
