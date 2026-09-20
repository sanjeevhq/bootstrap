#!/bin/sh
set -eu

WORKSPACE="${WORKSPACE:-$HOME/workspace}"
SKELETON="${SKELETON:-SanjeevThapaUG/workspace}"

say() { printf '\033[1;36m▸ %s\033[0m\n' "$*"; }

install_base_tools() {
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
      [ -f /etc/arch-release ] || { echo "Only Arch-based Linux is supported" >&2; exit 1; }
      say "Installing git, just, gum, gh"
      sudo pacman -Sy --needed --noconfirm git just gum github-cli
      ;;
    *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
  esac
}

github_login() {
  gh auth status >/dev/null 2>&1 && return
  say "GitHub login: open the URL below on a machine with a browser and enter the code"
  BROWSER=echo gh auth login --hostname github.com --git-protocol https --web
}

clone_workspace() {
  if [ -d "$WORKSPACE/.git" ]; then say "Workspace present at $WORKSPACE"; return; fi
  say "Cloning $SKELETON → $WORKSPACE"
  gh repo clone "$SKELETON" "$WORKSPACE"
}

install_base_tools
github_login
clone_workspace
cd "$WORKSPACE"
exec just setup
