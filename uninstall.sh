#!/usr/bin/env bash
set -euo pipefail

# yasashii-dotfiles uninstaller

INSTALL_DIR="${HOME}/.yasashii"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${BLUE}[yasashii]${NC} $1"; }
success() { echo -e "${GREEN}[yasashii]${NC} $1"; }
warn()    { echo -e "${YELLOW}[yasashii]${NC} $1"; }

echo ""
info "yasashii-dotfiles をアンインストールします / Uninstalling yasashii-dotfiles"
echo ""

# Remove source line from .zshrc
if [[ -f "$HOME/.zshrc" ]]; then
    if grep -q 'yasashii' "$HOME/.zshrc"; then
        info ".zshrc から yasashii を削除... / Removing from .zshrc..."
        python3 -c "
lines = open('$HOME/.zshrc').readlines()
with open('$HOME/.zshrc', 'w') as f:
    for line in lines:
        if 'yasashii' not in line:
            f.write(line)
"
        success ".zshrc OK"
    fi
fi

# Remove Ghostty config (only if it's yasashii's)
if [[ -f "$HOME/.config/ghostty/config" ]]; then
    if grep -q 'yasashii' "$HOME/.config/ghostty/config"; then
        info "Ghostty 設定を削除... / Removing Ghostty config..."
        rm -f "$HOME/.config/ghostty/config"
        rm -f "$HOME/.config/ghostty/themes/yasashii-"*
        success "Ghostty OK"
    fi
fi

# Remove Warp themes
if [[ -d "$HOME/.warp/themes" ]]; then
    rm -f "$HOME/.warp/themes/yasashii-"*.yaml
    success "Warp themes OK"
fi

# Remove yasashii directory
if [[ -d "$INSTALL_DIR" ]]; then
    info "yasashii ディレクトリを削除... / Removing yasashii directory..."
    rm -rf "$INSTALL_DIR"
    success "yasashii directory OK"
fi

echo ""
success "アンインストール完了 / Uninstall complete"
info "brew でインストールしたツールは残っています / Tools installed via brew are kept"
info "削除するには: brew uninstall starship eza bat ... / To remove: brew uninstall ..."
