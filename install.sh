#!/usr/bin/env bash
set -euo pipefail

# yasashii-dotfiles installer
# Usage: curl -fsSL https://raw.githubusercontent.com/esh2n/yasashii-dotfiles/main/install.sh | bash

REPO_URL="https://github.com/esh2n/yasashii-dotfiles.git"
INSTALL_DIR="${HOME}/.yasashii"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${BLUE}[yasashii]${NC} $1"; }
success() { echo -e "${GREEN}[yasashii]${NC} $1"; }
warn()    { echo -e "${YELLOW}[yasashii]${NC} $1"; }

# --- 1. Homebrew ---
if ! command -v brew &>/dev/null; then
    info "Homebrew をインストールしています... / Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi
success "Homebrew OK"

# --- 2. CLI tools ---
info "ツールをインストールしています... / Installing tools..."
TOOLS=(git gh starship eza bat fd ripgrep zoxide trash-cli gum zsh-autosuggestions atuin sk ghq zsh-syntax-highlighting vivid thefuck git-delta direnv tldr)
for tool in "${TOOLS[@]}"; do
    brew install "$tool" 2>/dev/null || true
done

# Pre-cache tldr pages (first run is slow without this)
tldr --update 2>/dev/null || true

success "CLI tools OK"

# --- 3. GUI apps ---
info "アプリをインストールしています... / Installing apps..."

# Font (always install)
brew install --cask font-moralerspace-nerd-font 2>/dev/null || true

# Terminal selection (gum is available after step 2)
if command -v gum &>/dev/null; then
    TERMINAL_CHOICE=$(gum choose --header "Terminal / ターミナルアプリを選んでください" \
        "cmux — シンプルで使いやすいターミナル（おすすめ）" \
        "Warp — AI機能付きのモダンなターミナル" \
        "インストール済み / Already installed")
else
    TERMINAL_CHOICE="インストール済み / Already installed"
fi

case "$TERMINAL_CHOICE" in
    *cmux*)
        brew install --cask cmux 2>/dev/null || true
        ;;
    *Warp*)
        brew install --cask warp 2>/dev/null || true
        ;;
esac

# AI completion (optional)
brew install --cask amazon-q 2>/dev/null || true

success "Apps OK"

# --- 4. Clone or update ---
if [[ -d "$INSTALL_DIR" ]]; then
    if git -C "$INSTALL_DIR" remote get-url origin &>/dev/null; then
        info "設定を更新しています... / Updating..."
        git -C "$INSTALL_DIR" pull --quiet 2>/dev/null || true
    else
        info "設定は既にあります / Config already exists"
    fi
else
    info "設定をダウンロードしています... / Downloading..."
    git clone --quiet "$REPO_URL" "$INSTALL_DIR"
fi
success "yasashii-dotfiles OK"

# --- 5. Git defaults ---
# gitconfig: only copy if none exists (don't overwrite user's config)
if [[ ! -f "$HOME/.gitconfig" ]]; then
    info "Git の初期設定... / Setting up Git defaults..."
    cp "$INSTALL_DIR/config/git/gitconfig" "$HOME/.gitconfig"
    success "Git config OK"
else
    info "Git 設定は既にあります / Git config exists, skipping"
fi
# gitignore: always update (safe to overwrite)
mkdir -p "$HOME/.config/git"
cp "$INSTALL_DIR/config/git/ignore" "$HOME/.config/git/ignore"

# projects directory for ghq
mkdir -p "$HOME/projects"

# --- 6. Shell config ---
if ! grep -q 'yasashii' "$HOME/.zshrc" 2>/dev/null; then
    info "シェルの設定... / Configuring shell..."
    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d)"
    echo 'source ~/.yasashii/shell/init.sh' >> "$HOME/.zshrc"
    success "Shell OK"
fi

# --- 7. Claude Code + LSP ---
if ! command -v claude &>/dev/null; then
    if command -v npm &>/dev/null; then
        info "Claude Code をインストール... / Installing Claude Code..."
        npm install -g @anthropic-ai/claude-code 2>/dev/null || true
        success "Claude Code OK"
    fi
fi

# PHP LSP (intelephense) for WordPress development
if command -v npm &>/dev/null; then
    npm install -g intelephense 2>/dev/null || true
fi
# Swift LSP (sourcekit-lsp) is bundled with Xcode — no install needed

# --- 8. ECC (Everything Claude Code) ---
# Search for existing ECC installation first
ECC_DIR=$(find "${HOME}/projects" "${HOME}/go" -type d -name "everything-claude-code" -maxdepth 5 2>/dev/null | head -1)

if [[ -z "$ECC_DIR" ]]; then
    if command -v ghq &>/dev/null; then
        info "ECC をダウンロード... / Downloading Everything Claude Code..."
        GHQ_ROOT="${HOME}/projects" ghq get affaan-m/everything-claude-code 2>/dev/null || true
        ECC_DIR=$(find "${HOME}/projects" -type d -name "everything-claude-code" -maxdepth 5 2>/dev/null | head -1)
    fi
fi

if [[ -d "$ECC_DIR" ]]; then
    info "ECC を検出: $ECC_DIR / ECC found: $ECC_DIR"

    # Write ECC paths into the beginner settings
    python3 -c "
import json
with open('${INSTALL_DIR}/claude/beginner/settings.layer.json') as f:
    data = json.load(f)
data['env']['ECC_ROOT'] = '${ECC_DIR}'
data['env']['CLAUDE_PLUGIN_ROOT'] = '${ECC_DIR}'
with open('${INSTALL_DIR}/claude/beginner/settings.layer.json', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
"
    success "ECC OK"
else
    info "ECC が見つかりません（オプション） / ECC not found (optional)"
fi

# --- 9. Setup wizard (last — user-facing interaction) ---
if [[ -f "$INSTALL_DIR/setup.sh" ]]; then
    zsh "$INSTALL_DIR/setup.sh"
fi

echo ""
success "完了！ターミナルを再起動してください / Done! Please restart your terminal"
