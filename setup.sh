#!/usr/bin/env zsh
set -euo pipefail

# yasashii-dotfiles setup wizard

INSTALL_DIR="${HOME}/.yasashii"
CONFIG_FILE="${INSTALL_DIR}/.config"

if ! command -v gum &>/dev/null; then
    echo "gum not found. Skipping setup wizard."
    exit 0
fi

echo ""
gum style --border rounded --padding "1 2" --border-foreground 212 \
    "yasashii-dotfiles"

# ─────────────────────────────────────────
# 1. What do you want to do?
#    First question is multilingual so no language selection needed yet
# ─────────────────────────────────────────
echo ""
PURPOSE=$(gum choose --no-limit --header "何をしたいですか？/ What do you want to do? (space to select)" \
    "📱 iPhone アプリを作りたい / Build an iPhone app" \
    "🌐 ウェブサイトを作りたい / Build a website" \
    "🐍 データ分析・AI / Data analysis & AI" \
    "🤖 Claude Code を使いたい / Use Claude Code" \
    "✨ ターミナルをきれいにしたい / Just make the terminal nice")

# ─────────────────────────────────────────
# 2. Language (detect from purpose selection behavior, but ask explicitly)
# ─────────────────────────────────────────
LANG_CHOICE=$(gum choose --header "Language / 言語" \
    "日本語" \
    "English" \
    "中文" \
    "한국어")

case "$LANG_CHOICE" in
    "日本語")  LANG_CODE="ja" ;;
    "English") LANG_CODE="en" ;;
    "中文")    LANG_CODE="zh" ;;
    "한국어")  LANG_CODE="ko" ;;
esac

# ─────────────────────────────────────────
# 3. Theme
# ─────────────────────────────────────────
THEME_CHOICE=$(gum choose --header "$(
    case $LANG_CODE in
        ja) echo "テーマ" ;;
        en) echo "Theme" ;;
        zh) echo "主题" ;;
        ko) echo "테마" ;;
    esac
)" \
    "🌙 Dark" \
    "☀️  Light" \
    "🌸 Sakura")

case "$THEME_CHOICE" in
    *Dark*)   THEME="dark" ;;
    *Light*)  THEME="light" ;;
    *Sakura*) THEME="sakura" ;;
esac

# ─────────────────────────────────────────
# 4. Font size
# ─────────────────────────────────────────
FONT_CHOICE=$(gum choose --header "$(
    case $LANG_CODE in
        ja) echo "文字の大きさ" ;;
        en) echo "Font size" ;;
        zh) echo "字体大小" ;;
        ko) echo "글자 크기" ;;
    esac
)" \
    "$(case $LANG_CODE in ja) echo "普通";; en) echo "Normal";; zh) echo "普通";; ko) echo "보통";; esac)" \
    "$(case $LANG_CODE in ja) echo "大きめ";; en) echo "Large";; zh) echo "大号";; ko) echo "크게";; esac)" \
    "$(case $LANG_CODE in ja) echo "とても大きい";; en) echo "Extra large";; zh) echo "特大";; ko) echo "아주 크게";; esac)")

case "$FONT_CHOICE" in
    普通|Normal|普通|보통)           FONT_SIZE="normal" ;;
    大きめ|Large|大号|크게)          FONT_SIZE="large" ;;
    *大きい|"Extra large"|特大|*크게) FONT_SIZE="xlarge" ;;
esac

# ─────────────────────────────────────────
# Save config
# ─────────────────────────────────────────
cat > "$CONFIG_FILE" << EOF
YASASHII_LANG=${LANG_CODE}
YASASHII_THEME=${THEME}
YASASHII_FONT_SIZE=${FONT_SIZE}
EOF

# ─────────────────────────────────────────
# Apply LSP plugins based on purpose
# ─────────────────────────────────────────
local settings_file="${INSTALL_DIR}/claude/beginner/settings.layer.json"
if [[ -f "$settings_file" ]]; then
    python3 -c "
import json
d = json.load(open('$settings_file'))
choices = '''$PURPOSE'''
plugins = d.get('enabledPlugins', {})

# Reset LSP plugins
for k in list(plugins.keys()):
    if 'lsp' in k:
        del plugins[k]

# Enable based on purpose
if 'iPhone' in choices or 'app' in choices:
    plugins['swift-lsp@claude-plugins-official'] = True
if 'ウェブ' in choices or 'website' in choices:
    plugins['php-lsp@claude-plugins-official'] = True

# Marketplace
if 'extraKnownMarketplaces' not in d:
    d['extraKnownMarketplaces'] = {}
d['extraKnownMarketplaces']['claude-plugins-official'] = {
    'source': {'source': 'github', 'repo': 'anthropics/claude-plugins-official'}
}

d['enabledPlugins'] = plugins
with open('$settings_file', 'w') as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
    f.write('\n')
"
fi

# ─────────────────────────────────────────
# Apply terminal themes
# ─────────────────────────────────────────

# Ghostty
local ghostty_config_dir="${HOME}/.config/ghostty"
if [[ -d "$ghostty_config_dir" ]] || [[ -d "/Applications/Ghostty.app" ]]; then
    mkdir -p "$ghostty_config_dir/themes"
    for theme_file in "${INSTALL_DIR}/config/ghostty/themes/"*; do
        [[ -f "$theme_file" ]] && cp "$theme_file" "$ghostty_config_dir/themes/"
    done
    cp "${INSTALL_DIR}/config/ghostty/${THEME}.config" "$ghostty_config_dir/config"

    if [[ -f "$ghostty_config_dir/config" ]]; then
        local font_px
        case "$FONT_SIZE" in
            normal) font_px=15 ;;
            large)  font_px=17 ;;
            xlarge) font_px=19 ;;
        esac
        python3 -c "
import re
content = open('${ghostty_config_dir}/config').read()
content = re.sub(r'font-size = \d+', 'font-size = ${font_px}', content)
open('${ghostty_config_dir}/config', 'w').write(content)
"
    fi
fi

# Warp
local warp_themes_dir="${HOME}/.warp/themes"
if [[ -d "${HOME}/.warp" ]] || [[ -d "/Applications/Warp.app" ]]; then
    mkdir -p "$warp_themes_dir"
    cp "${INSTALL_DIR}/config/warp/themes/yasashii-${THEME}.yaml" "$warp_themes_dir/"
fi

# ─────────────────────────────────────────
# Done
# ─────────────────────────────────────────
echo ""
case $LANG_CODE in
    ja) echo "✅ 設定を保存しました" ;;
    zh) echo "✅ 设置已保存" ;;
    ko) echo "✅ 설정이 저장되었습니다" ;;
    *)  echo "✅ Settings saved" ;;
esac

echo ""

if [[ "${TERM_PROGRAM:-}" == "WarpTerminal" ]]; then
    case $LANG_CODE in
        ja) echo "  プロンプトは次の行から反映されます"
            echo "  テーマの色は Settings > Appearance > Theme で「yasashii ${THEME}」を選んでください" ;;
        zh) echo "  提示符将从下一行开始生效"
            echo "  请在 Settings > Appearance > Theme 中选择「yasashii ${THEME}」" ;;
        ko) echo "  프롬프트는 다음 줄부터 반영됩니다"
            echo "  Settings > Appearance > Theme 에서「yasashii ${THEME}」를 선택하세요" ;;
        *)  echo "  Prompt will update on the next line"
            echo "  For theme colors: Settings > Appearance > Theme → select 'yasashii ${THEME}'" ;;
    esac
else
    case $LANG_CODE in
        ja) echo "  プロンプトは次の行から反映されます"
            echo "  テーマの色を反映するには Cmd+Shift+, を押してください" ;;
        zh) echo "  提示符将从下一行开始生效"
            echo "  要让主题颜色生效，请按 Cmd+Shift+," ;;
        ko) echo "  프롬프트는 다음 줄부터 반영됩니다"
            echo "  테마 색상을 반영하려면 Cmd+Shift+, 를 누르세요" ;;
        *)  echo "  Prompt will update on the next line"
            echo "  To apply theme colors, press Cmd+Shift+," ;;
    esac
fi

# ─────────────────────────────────────────
# Reload current session
# ─────────────────────────────────────────
export YASASHII_LANG="${LANG_CODE}"
export YASASHII_THEME="${THEME}"
export YASASHII_FONT_SIZE="${FONT_SIZE}"
export STARSHIP_CONFIG="${INSTALL_DIR}/config/starship/generated/${LANG_CODE}-${THEME}.toml"

if [[ -f "${INSTALL_DIR}/scripts/generate-starship.sh" ]]; then
    bash "${INSTALL_DIR}/scripts/generate-starship.sh" >/dev/null 2>&1
fi
