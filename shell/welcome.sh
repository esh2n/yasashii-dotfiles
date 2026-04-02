#!/usr/bin/env zsh
YASASHII_DIR="${HOME}/.yasashii"
WELCOMED_FLAG="${YASASHII_DIR}/.welcomed"

[[ -f "$WELCOMED_FLAG" ]] && exit 0

YASASHII_LANG="en"
if [[ -f "${YASASHII_DIR}/.config" ]]; then
    source "${YASASHII_DIR}/.config"
fi

_welcome_render() {
    local title="$1"
    shift

    local b=$'\033[1m'
    local c=$'\033[36m'
    local d=$'\033[2m'
    local p=$'\033[35m'
    local r=$'\033[0m'

    # Title box (use python for correct CJK width)
    local title_width
    title_width=$(python3 -c "
import unicodedata
s = '''$title'''
print(sum(2 if unicodedata.east_asian_width(c) in ('F','W') else 1 for c in s))
")
    local pad=$((title_width + 6))
    local border=$(printf '─%.0s' {1..$pad})

    echo ""
    echo "  ${d}╭${border}╮${r}"
    echo "  ${d}│${r}   ${b}${title}${r}   ${d}│${r}"
    echo "  ${d}╰${border}╯${r}"
    echo ""

    # Sections
    local section=""
    for arg in "$@"; do
        if [[ "$arg" == "---" ]]; then
            section=""
            echo ""
        elif [[ -z "$section" ]]; then
            section="$arg"
            echo "  ${p}${b}${section}${r}"
        else
            local label="${arg%%=*}"
            local desc="${arg#*=}"
            echo "    ${c}${label}${r}  ${d}${desc}${r}"
        fi
    done
    echo ""
}

case "$YASASHII_LANG" in
    ja)
        _welcome_render "ようこそ yasashii-dotfiles へ" \
            "はじめる" \
            "tips=よく使うコマンドの一覧を表示" \
            "git=Git の操作メニューを表示" \
            "wt=ワークツリーの管理メニューを表示" \
            "---" \
            "ショートカット" \
            "Ctrl+]=プロジェクトに移動" \
            "Ctrl+G=フォルダを探して移動" \
            "Ctrl+F=ファイルを探す" \
            "Ctrl+R=コマンドの履歴を検索" \
            "Ctrl+H=プロンプトの説明を表示" \
            "↑ ↓=履歴から入力補完" \
            "---" \
            "カスタマイズ" \
            "yasashii=テーマ・言語・フォントサイズの変更" \
            "rm ~/.yasashii/.welcomed=この画面を再表示" \
            "---"
        ;;
    zh)
        _welcome_render "欢迎使用 yasashii-dotfiles" \
            "开始" \
            "tips=显示常用命令列表" \
            "git=打开 Git 操作菜单" \
            "wt=打开工作树管理菜单" \
            "---" \
            "快捷键" \
            "Ctrl+]=跳转到项目" \
            "Ctrl+G=搜索并跳转到文件夹" \
            "Ctrl+F=搜索文件" \
            "Ctrl+R=搜索命令历史" \
            "Ctrl+H=显示提示说明" \
            "↑ ↓=从历史补全" \
            "---" \
            "自定义" \
            "yasashii=更改主题、语言和字体大小" \
            "rm ~/.yasashii/.welcomed=再次显示此页面" \
            "---"
        ;;
    ko)
        _welcome_render "yasashii-dotfiles에 오신 것을 환영합니다" \
            "시작하기" \
            "tips=자주 쓰는 명령어 목록 표시" \
            "git=Git 작업 메뉴 열기" \
            "wt=워크트리 관리 메뉴 열기" \
            "---" \
            "단축키" \
            "Ctrl+]=프로젝트로 이동" \
            "Ctrl+G=폴더 검색 후 이동" \
            "Ctrl+F=파일 검색" \
            "Ctrl+R=명령어 이력 검색" \
            "Ctrl+H=프롬프트 설명 표시" \
            "↑ ↓=이력에서 자동완성" \
            "---" \
            "커스터마이즈" \
            "yasashii=테마, 언어, 글자 크기 변경" \
            "rm ~/.yasashii/.welcomed=이 화면 다시 표시" \
            "---"
        ;;
    *)
        _welcome_render "Welcome to yasashii-dotfiles" \
            "Start" \
            "tips=Show frequently used commands" \
            "git=Open Git operations menu" \
            "wt=Open worktree manager" \
            "---" \
            "Shortcuts" \
            "Ctrl+]=Jump to project" \
            "Ctrl+G=Search and jump to folder" \
            "Ctrl+F=Search files" \
            "Ctrl+R=Search command history" \
            "Ctrl+H=Show prompt help" \
            "↑ ↓=Complete from history" \
            "---" \
            "Customize" \
            "yasashii=Change theme, language, font size" \
            "rm ~/.yasashii/.welcomed=Show this screen again" \
            "---"
        ;;
esac

touch "$WELCOMED_FLAG"
