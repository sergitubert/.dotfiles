#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Helpers ───────────────────────────────────────────────────────────────────

log()  { echo "==> $*"; }
warn() { echo "WARN: $*" >&2; }

# ── Preflight ─────────────────────────────────────────────────────────────────

if ! grep -qi "microsoft" /proc/version 2>/dev/null; then
  warn "Not running under WSL2 — some steps may not apply."
fi

# ── Git identity ──────────────────────────────────────────────────────────────

read -rp "Git name:  " GIT_NAME
read -rp "Git email: " GIT_EMAIL

# ── Install packages ──────────────────────────────────────────────────────────

for script in "$DOTFILES_DIR"/install/*.sh; do
  log "Running $(basename "$script")…"
  bash "$script"
done

# ── Symlink dotfiles ──────────────────────────────────────────────────────────

log "Symlinking dotfiles…"

symlink() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "${dst}.bak"
    warn "Backed up existing $dst to ${dst}.bak"
  fi
  ln -sf "$src" "$dst"
}

symlink "$DOTFILES_DIR/dots/bashrc"  "$HOME/.bashrc"
symlink "$DOTFILES_DIR/dots/inputrc" "$HOME/.inputrc"

mkdir -p "$HOME/.config"
symlink "$DOTFILES_DIR/dots/zellij" "$HOME/.config/zellij"

# ── Git configuration ─────────────────────────────────────────────────────────

log "Configuring git…"
git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true

# ── Final upgrade ─────────────────────────────────────────────────────────────

log "Running final apt upgrade…"
sudo apt upgrade -y

log "Done. Restart your terminal to apply all changes."
