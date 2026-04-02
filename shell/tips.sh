#!/usr/bin/env zsh
# tips — quick reference for frequently needed commands

tips() {
    if command -v gum &>/dev/null; then
        _tips_gum
    else
        _tips_plain
    fi
}

_tips_gum() {
    case "$YASASHII_LANG" in
        ja) _tips_gum_render \
            "操作" "止める=Ctrl+C" "画面をきれいに=Ctrl+L" "履歴を探す=Ctrl+R" "プロジェクト移動=Ctrl+]" "フォルダを探す=Ctrl+G" "ファイルを探す=Ctrl+F" \
            "移動" "1つ上へ=cd .." "ホームに戻る=cd ~" "前のフォルダへ=cd -" \
            "開く" "Finderで開く=open ." "VS Codeで開く=code ." "ブラウザで開く=open http://localhost:3000" \
            "ファイル" "フォルダ作成=mkcd 名前" "展開=extract ファイル" "隠しファイル=ls -la" \
            "Git" "Gitメニュー=git" "ワークツリー=wt" "使い方=help コマンド" \
            "トラブル" "ポート調査=lsof -i :3000" "npm修復=rm -rf node_modules && npm install" "現在地=pwd" ;;
        *)  _tips_gum_render \
            "Control" "Stop=Ctrl+C" "Clear=Ctrl+L" "History=Ctrl+R" "Project=Ctrl+]" "Folders=Ctrl+G" "Files=Ctrl+F" \
            "Navigate" "Up one=cd .." "Home=cd ~" "Previous=cd -" \
            "Open" "Finder=open ." "VS Code=code ." "Browser=open http://localhost:3000" \
            "Files" "New folder=mkcd name" "Extract=extract file" "Hidden=ls -la" \
            "Git" "Git menu=git" "Worktree=wt" "Help=help command" \
            "Trouble" "Port check=lsof -i :3000" "Fix npm=rm -rf node_modules && npm install" "Location=pwd" ;;
    esac
}

_tips_gum_render() {
    printf '%s\n' "$@" | python3 -c "
import unicodedata, sys

def display_width(s):
    return sum(2 if unicodedata.east_asian_width(c) in ('F','W') else 1 for c in s)

def pad(s, total):
    return s + ' ' * max(total - display_width(s), 1)

B, C, R = '\033[1m', '\033[36m', '\033[0m'
first = True
for line in sys.stdin:
    line = line.rstrip()
    if '=' not in line:
        if not first: print()
        first = False
        print(f'{B}{line}{R}')
    else:
        label, cmd = line.split('=', 1)
        print(f'  {pad(label, 22)}{C}{cmd}{R}')
print()
"
}

_tips_plain() {
    local b=$'\033[1m'
    local c=$'\033[36m'
    local r=$'\033[0m'

    case "$YASASHII_LANG" in
        ja)
            cat <<EOF

${b}操作${r}
  止める                    ${c}Ctrl+C${r}
  画面をきれいに            ${c}Ctrl+L${r}
  履歴を探す                ${c}Ctrl+R${r}
  プロジェクト移動          ${c}Ctrl+]${r}
  フォルダを探す            ${c}Ctrl+G${r}
  ファイルを探す            ${c}Ctrl+F${r}

${b}移動${r}
  1つ上へ                   ${c}cd ..${r}
  ホームに戻る              ${c}cd ~${r}
  前のフォルダへ            ${c}cd -${r}

${b}開く${r}
  Finderで開く              ${c}open .${r}
  VS Codeで開く             ${c}code .${r}
  ブラウザで開く            ${c}open http://localhost:3000${r}

${b}ファイル${r}
  フォルダ作成              ${c}mkcd 名前${r}
  展開                      ${c}extract ファイル${r}
  隠しファイル              ${c}ls -la${r}

${b}Git${r}
  Gitメニュー               ${c}git${r}
  ワークツリー              ${c}wt${r}
  使い方                    ${c}help コマンド${r}

${b}トラブル${r}
  ポート調査                ${c}lsof -i :3000${r}
  npm修復                   ${c}rm -rf node_modules && npm install${r}
  現在地                    ${c}pwd${r}

EOF
            ;;
        *)
            cat <<EOF

${b}Control${r}
  Stop                      ${c}Ctrl+C${r}
  Clear                     ${c}Ctrl+L${r}
  History                   ${c}Ctrl+R${r}
  Project                   ${c}Ctrl+]${r}
  Folders                   ${c}Ctrl+G${r}
  Files                     ${c}Ctrl+F${r}

${b}Navigate${r}
  Up one                    ${c}cd ..${r}
  Home                      ${c}cd ~${r}
  Previous                  ${c}cd -${r}

${b}Open${r}
  Finder                    ${c}open .${r}
  VS Code                   ${c}code .${r}
  Browser                   ${c}open http://localhost:3000${r}

${b}Files${r}
  New folder                ${c}mkcd name${r}
  Extract                   ${c}extract file${r}
  Hidden                    ${c}ls -la${r}

${b}Git${r}
  Git menu                  ${c}git${r}
  Worktree                  ${c}wt${r}
  Help                      ${c}help command${r}

${b}Trouble${r}
  Port check                ${c}lsof -i :3000${r}
  Fix npm                   ${c}rm -rf node_modules && npm install${r}
  Location                  ${c}pwd${r}

EOF
            ;;
    esac
}
