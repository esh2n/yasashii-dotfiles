#!/usr/bin/env zsh
# wt — friendly git worktree manager for yasashii-dotfiles
# Usage: wt [list|cd|add|rm|help]

_wt_msg() {
    local key="$1"
    case "$YASASHII_LANG" in
        ja) case "$key" in
            not_git)    echo "Git プロジェクトの中ではありません" ;;
            no_wt)      echo "ワークツリーはありません" ;;
            select_wt)  echo "ワークツリーを選んでください" ;;
            select_br)  echo "ブランチを選んでください" ;;
            new_branch) echo "新しいブランチ名を入力してください\n（ブランチ = プロジェクトのコピー。元に影響せず変更できます。例: fix-typo）" ;;
            created)    echo "ワークツリーを作成しました" ;;
            removed)    echo "ワークツリーを削除しました" ;;
            switched)   echo "移動しました" ;;
            confirm_rm) echo "このワークツリーを削除しますか？" ;;
            menu_list)  echo "一覧を見る" ;;
            menu_cd)    echo "切り替える" ;;
            menu_add)   echo "新しく作る" ;;
            menu_rm)    echo "削除する" ;;
            menu_help)  echo "使い方" ;;
            help_title) echo "wt — Git Worktree（ワークツリー）" ;;
            help_desc)  echo "ブランチ（git branch）は、今のフォルダの中で切り替えて作業します。\nワークツリーは、別のフォルダを作って同時に開きます。\n\n切り替えずに両方を見たいときに使います。" ;;
            menu_header) echo "Git Worktree（ワークツリー）\n別のフォルダで同じプロジェクトの違うバージョンを同時に開けます" ;;
        esac ;;
        zh) case "$key" in
            not_git)    echo "不在 Git 项目中" ;;
            no_wt)      echo "没有工作树" ;;
            select_wt)  echo "请选择工作树" ;;
            select_br)  echo "请选择分支" ;;
            new_branch) echo "请输入新分支名称\n（分支 = 项目的副本。可以修改而不影响原始版本。例: fix-typo）" ;;
            created)    echo "工作树已创建" ;;
            removed)    echo "工作树已删除" ;;
            switched)   echo "已切换" ;;
            confirm_rm) echo "确定要删除这个工作树吗？" ;;
            menu_list)  echo "查看列表" ;;
            menu_cd)    echo "切换" ;;
            menu_add)   echo "新建" ;;
            menu_rm)    echo "删除" ;;
            menu_help)  echo "帮助" ;;
            help_title) echo "wt — Git Worktree（工作树）" ;;
            help_desc)  echo "分支（git branch）是在当前文件夹中切换工作。\n工作树是创建另一个文件夹，同时打开两个版本。\n\n不想切换、想同时查看两边时使用。" ;;
            menu_header) echo "Git Worktree（工作树）\n在另一个文件夹中同时打开同一项目的不同版本" ;;
        esac ;;
        ko) case "$key" in
            not_git)    echo "Git 프로젝트 안이 아닙니다" ;;
            no_wt)      echo "워크트리가 없습니다" ;;
            select_wt)  echo "워크트리를 선택하세요" ;;
            select_br)  echo "브랜치를 선택하세요" ;;
            new_branch) echo "새 브랜치 이름을 입력하세요\n（브랜치 = 프로젝트의 복사본. 원본에 영향 없이 수정할 수 있습니다. 예: fix-typo）" ;;
            created)    echo "워크트리를 만들었습니다" ;;
            removed)    echo "워크트리를 삭제했습니다" ;;
            switched)   echo "이동했습니다" ;;
            confirm_rm) echo "이 워크트리를 삭제할까요?" ;;
            menu_list)  echo "목록 보기" ;;
            menu_cd)    echo "전환" ;;
            menu_add)   echo "새로 만들기" ;;
            menu_rm)    echo "삭제" ;;
            menu_help)  echo "도움말" ;;
            help_title) echo "wt — Git Worktree（워크트리）" ;;
            help_desc)  echo "브랜치（git branch）는 현재 폴더 안에서 전환하며 작업합니다.\n워크트리는 다른 폴더를 만들어 동시에 열 수 있습니다.\n\n전환 없이 양쪽을 동시에 보고 싶을 때 사용합니다." ;;
            menu_header) echo "Git Worktree（워크트리）\n다른 폴더에서 같은 프로젝트의 다른 버전을 동시에 열 수 있습니다" ;;
        esac ;;
        *) case "$key" in
            not_git)    echo "Not inside a Git project" ;;
            no_wt)      echo "No worktrees found" ;;
            select_wt)  echo "Select a worktree" ;;
            select_br)  echo "Select a branch" ;;
            new_branch) echo "Enter a new branch name\n(Branch = a copy of the project. You can make changes without affecting the original. e.g. fix-typo)" ;;
            created)    echo "Worktree created" ;;
            removed)    echo "Worktree removed" ;;
            switched)   echo "Switched" ;;
            confirm_rm) echo "Remove this worktree?" ;;
            menu_list)  echo "List all" ;;
            menu_cd)    echo "Switch to" ;;
            menu_add)   echo "Create new" ;;
            menu_rm)    echo "Remove" ;;
            menu_help)  echo "Help" ;;
            help_title) echo "wt — Git Worktree" ;;
            help_desc)  echo "A branch (git branch) switches between versions in the same folder.\nA worktree opens another version in a separate folder.\n\nUse it when you want to see both at the same time without switching." ;;
            menu_header) echo "Git Worktree\nOpen a different version of the same project in a separate folder" ;;
        esac ;;
    esac
}

_wt_check_git() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "$(_wt_msg not_git)" >&2
        return 1
    fi
}

_wt_list() {
    _wt_check_git || return 1
    git worktree list
}

_wt_cd() {
    _wt_check_git || return 1

    local worktrees
    worktrees=$(git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //')

    if [[ $(echo "$worktrees" | wc -l) -le 1 ]]; then
        echo "$(_wt_msg no_wt)"
        return 0
    fi

    local selected
    if command -v gum &>/dev/null; then
        selected=$(echo "$worktrees" | gum choose --header "$(_wt_msg select_wt)")
    else
        selected=$(echo "$worktrees" | head -5)
        echo "$(_wt_msg select_wt):"
        echo "$selected"
        return 0
    fi

    if [[ -n "$selected" ]]; then
        cd "$selected"
        echo "$(_wt_msg switched): $(basename "$selected")"
    fi
}

_wt_add() {
    _wt_check_git || return 1

    local branch
    if command -v gum &>/dev/null; then
        branch=$(gum input --placeholder "$(_wt_msg new_branch)")
    else
        printf "%s: " "$(_wt_msg new_branch)"
        read branch
    fi

    if [[ -z "$branch" ]]; then
        return 0
    fi

    local root
    root=$(git rev-parse --show-toplevel)
    local wt_path="${root}/../${branch}"

    git worktree add -b "$branch" "$wt_path" && \
        echo "$(_wt_msg created): $wt_path" && \
        cd "$wt_path"
}

_wt_rm() {
    _wt_check_git || return 1

    local worktrees
    worktrees=$(git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //')

    local main_wt
    main_wt=$(echo "$worktrees" | head -1)
    local other_wts
    other_wts=$(echo "$worktrees" | tail -n +2)

    if [[ -z "$other_wts" ]]; then
        echo "$(_wt_msg no_wt)"
        return 0
    fi

    local selected
    if command -v gum &>/dev/null; then
        selected=$(echo "$other_wts" | gum choose --header "$(_wt_msg select_wt)")
    else
        echo "$other_wts"
        return 0
    fi

    if [[ -z "$selected" ]]; then
        return 0
    fi

    if command -v gum &>/dev/null; then
        gum confirm "$(_wt_msg confirm_rm) $(basename "$selected")" || return 0
    fi

    # Move to main worktree if currently in the one being removed
    if [[ "$(pwd)" == "$selected"* ]]; then
        cd "$main_wt"
    fi

    git worktree remove "$selected" && echo "$(_wt_msg removed): $(basename "$selected")"
}

_wt_help() {
    echo "$(_wt_msg help_title)"
    echo ""
    echo -e "$(_wt_msg help_desc)"
    echo ""
    echo "  wt              — $(_wt_msg menu_list) / $(_wt_msg menu_cd) / $(_wt_msg menu_add) / $(_wt_msg menu_rm)"
    echo "  wt list         — $(_wt_msg menu_list)"
    echo "  wt cd           — $(_wt_msg menu_cd)"
    echo "  wt add          — $(_wt_msg menu_add)"
    echo "  wt rm           — $(_wt_msg menu_rm)"
    echo "  wt help         — $(_wt_msg menu_help)"
}

_wt_menu() {
    _wt_check_git || return 1

    if ! command -v gum &>/dev/null; then
        _wt_help
        return 0
    fi

    echo -e "$(_wt_msg menu_header)"
    echo ""

    local choice
    choice=$(gum choose \
        "$(_wt_msg menu_list)" \
        "$(_wt_msg menu_cd)" \
        "$(_wt_msg menu_add)" \
        "$(_wt_msg menu_rm)" \
        "$(_wt_msg menu_help)")

    case "$choice" in
        "$(_wt_msg menu_list)") echo; _wt_list ;;
        "$(_wt_msg menu_cd)")   _wt_cd ;;
        "$(_wt_msg menu_add)")  _wt_add ;;
        "$(_wt_msg menu_rm)")   _wt_rm ;;
        "$(_wt_msg menu_help)") echo; _wt_help ;;
    esac
}

wt() {
    case "${1:-}" in
        list|ls)   _wt_list ;;
        cd)        shift; _wt_cd "$@" ;;
        add|new)   _wt_add ;;
        rm|remove) _wt_rm ;;
        help|h)    _wt_help ;;
        "")        _wt_menu ;;
        *)         _wt_help ;;
    esac
}
