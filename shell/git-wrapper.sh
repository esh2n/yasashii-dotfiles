#!/usr/bin/env zsh
# git wrapper — interactive git menu for non-engineers
# Wraps bare `git` (no arguments) with a friendly gum menu
# Intercepts `git clone` to use ghq
# All other `git <subcommand>` calls pass through to real git

_git_real=$(whence -p git)

_gw_msg() {
    local key="$1"
    case "$YASASHII_LANG" in
        ja) case "$key" in
            header)        echo "Git — プロジェクトの変更を管理します" ;;
            status)        echo "状態を見る" ;;
            status_desc)   echo "今のファイルの変更状況を表示します" ;;
            add)           echo "保存するファイルを選ぶ" ;;
            add_desc)      echo "次の記録に含めるファイルを選びます" ;;
            add_all)       echo "すべてのファイルを選ぶ" ;;
            commit)        echo "変更を記録する" ;;
            commit_desc)   echo "選んだファイルをまとめて記録します" ;;
            upload)        echo "クラウドに送る" ;;
            upload_desc)   echo "記録した変更をチームと共有します" ;;
            download)      echo "クラウドから取得" ;;
            download_desc) echo "チームの最新の変更を取り込みます" ;;
            log)           echo "履歴を見る" ;;
            log_desc)      echo "過去の記録の一覧を表示します" ;;
            switch)        echo "ブランチを切り替え" ;;
            switch_desc)   echo "プロジェクトの別のコピーに移動します" ;;
            worktree)      echo "ワークツリー" ;;
            worktree_desc) echo "別フォルダで同時に作業します" ;;
            not_git)       echo "Git プロジェクトの中ではありません" ;;
            commit_msg)    echo "記録メッセージを入力してください（何を変えたか）" ;;
            select_files)  echo "ファイルを選んでください（スペースで選択、Enterで確定）" ;;
            select_all)    echo "すべて選択しました" ;;
            no_changes)    echo "変更はありません" ;;
            added)         echo "ファイルを選択しました" ;;
            committed)     echo "記録しました" ;;
            uploaded)      echo "クラウドに送信しました" ;;
            downloaded)    echo "最新の変更を取得しました" ;;
            select_branch) echo "切り替えるブランチを選んでください（ブランチ = プロジェクトのコピー）" ;;
            no_remote)     echo "クラウドの共有先が設定されていません。GitHub にリポジトリを作りますか？" ;;
            cloned)        echo "プロジェクトをダウンロードしました" ;;
            nothing_staged) echo "記録するファイルが選ばれていません。先に「保存するファイルを選ぶ」を実行してください" ;;
        esac ;;
        zh) case "$key" in
            header)        echo "Git — 管理项目的变更" ;;
            status)        echo "查看状态" ;;
            status_desc)   echo "显示当前文件的变更情况" ;;
            add)           echo "选择要记录的文件" ;;
            add_desc)      echo "选择下次记录中要包含的文件" ;;
            add_all)       echo "选择所有文件" ;;
            commit)        echo "记录变更" ;;
            commit_desc)   echo "将选择的文件记录下来" ;;
            upload)        echo "发送到云端" ;;
            upload_desc)   echo "将记录的变更分享给团队" ;;
            download)      echo "从云端获取" ;;
            download_desc) echo "获取团队的最新变更" ;;
            log)           echo "查看历史" ;;
            log_desc)      echo "显示过去的记录" ;;
            switch)        echo "切换分支" ;;
            switch_desc)   echo "切换到项目的另一个副本" ;;
            worktree)      echo "工作树" ;;
            worktree_desc) echo "在另一个文件夹中同时工作" ;;
            not_git)       echo "不在 Git 项目中" ;;
            commit_msg)    echo "请输入记录信息（描述你改了什么）" ;;
            select_files)  echo "请选择文件（空格选择，回车确认）" ;;
            select_all)    echo "已选择全部" ;;
            no_changes)    echo "没有变更" ;;
            added)         echo "已选择文件" ;;
            committed)     echo "已记录" ;;
            uploaded)      echo "已发送到云端" ;;
            downloaded)    echo "已获取最新变更" ;;
            select_branch) echo "请选择要切换的分支（分支 = 项目的副本）" ;;
            no_remote)     echo "还没有设置云端共享。要在 GitHub 上创建仓库吗？" ;;
            cloned)        echo "项目已下载" ;;
            nothing_staged) echo "还没有选择要记录的文件。请先执行「选择要记录的文件」" ;;
        esac ;;
        ko) case "$key" in
            header)        echo "Git — 프로젝트 변경을 관리합니다" ;;
            status)        echo "상태 보기" ;;
            status_desc)   echo "현재 파일의 변경 상황을 표시합니다" ;;
            add)           echo "기록할 파일 선택" ;;
            add_desc)      echo "다음 기록에 포함할 파일을 선택합니다" ;;
            add_all)       echo "모든 파일 선택" ;;
            commit)        echo "변경 기록" ;;
            commit_desc)   echo "선택한 파일을 기록합니다" ;;
            upload)        echo "클라우드에 보내기" ;;
            upload_desc)   echo "기록한 변경을 팀과 공유합니다" ;;
            download)      echo "클라우드에서 가져오기" ;;
            download_desc) echo "팀의 최신 변경을 가져옵니다" ;;
            log)           echo "이력 보기" ;;
            log_desc)      echo "과거 기록 목록을 표시합니다" ;;
            switch)        echo "브랜치 전환" ;;
            switch_desc)   echo "프로젝트의 다른 복사본으로 이동합니다" ;;
            worktree)      echo "워크트리" ;;
            worktree_desc) echo "다른 폴더에서 동시에 작업합니다" ;;
            not_git)       echo "Git 프로젝트 안이 아닙니다" ;;
            commit_msg)    echo "기록 메시지를 입력하세요 (무엇을 변경했는지)" ;;
            select_files)  echo "파일을 선택하세요 (스페이스로 선택, 엔터로 확인)" ;;
            select_all)    echo "모두 선택했습니다" ;;
            no_changes)    echo "변경이 없습니다" ;;
            added)         echo "파일을 선택했습니다" ;;
            committed)     echo "기록했습니다" ;;
            uploaded)      echo "클라우드에 보냈습니다" ;;
            downloaded)    echo "최신 변경을 가져왔습니다" ;;
            select_branch) echo "전환할 브랜치를 선택하세요 (브랜치 = 프로젝트의 복사본)" ;;
            no_remote)     echo "클라우드 공유 설정이 없습니다. GitHub에 저장소를 만들까요?" ;;
            cloned)        echo "프로젝트를 다운로드했습니다" ;;
            nothing_staged) echo "기록할 파일이 선택되지 않았습니다. 먼저 「기록할 파일 선택」을 실행하세요" ;;
        esac ;;
        *) case "$key" in
            header)        echo "Git — Manage your project changes" ;;
            status)        echo "See status" ;;
            status_desc)   echo "Show what files have changed" ;;
            add)           echo "Select files to record" ;;
            add_desc)      echo "Choose which files to include in the next record" ;;
            add_all)       echo "Select all files" ;;
            commit)        echo "Record changes" ;;
            commit_desc)   echo "Record the selected files" ;;
            upload)        echo "Send to cloud" ;;
            upload_desc)   echo "Share your recorded changes with the team" ;;
            download)      echo "Get from cloud" ;;
            download_desc) echo "Get the team's latest changes" ;;
            log)           echo "See history" ;;
            log_desc)      echo "Show past records" ;;
            switch)        echo "Switch branch" ;;
            switch_desc)   echo "Move to a different copy of the project" ;;
            worktree)      echo "Worktree" ;;
            worktree_desc) echo "Work in a separate folder at the same time" ;;
            not_git)       echo "Not inside a Git project" ;;
            commit_msg)    echo "Enter a record message (describe what you changed)" ;;
            select_files)  echo "Select files (space to select, enter to confirm)" ;;
            select_all)    echo "All selected" ;;
            no_changes)    echo "No changes" ;;
            added)         echo "Files selected" ;;
            committed)     echo "Recorded" ;;
            uploaded)      echo "Sent to cloud" ;;
            downloaded)    echo "Got latest changes" ;;
            select_branch) echo "Select a branch to switch to (branch = a copy of the project)" ;;
            no_remote)     echo "No cloud destination is set up. Create a repository on GitHub?" ;;
            cloned)        echo "Project downloaded" ;;
            nothing_staged) echo "No files selected for recording. Run \"Select files to record\" first" ;;
        esac ;;
    esac
}

_gw_check_git() {
    if ! $_git_real rev-parse --is-inside-work-tree &>/dev/null; then
        echo "$(_gw_msg not_git)" >&2
        return 1
    fi
}

_gw_status() {
    zsh "${YASASHII_DIR}/shell/git-friendly.sh" status
}

_gw_add() {
    _gw_check_git || return 1

    local changes
    changes=$($_git_real status --porcelain 2>/dev/null | awk '{print $2}')
    if [[ -z "$changes" ]]; then
        echo "$(_gw_msg no_changes)"
        return 0
    fi

    if ! command -v gum &>/dev/null; then
        # No gum: add all
        $_git_real add -A
        echo "$(_gw_msg select_all)"
        return 0
    fi

    local choice
    choice=$(gum choose \
        "$(_gw_msg add_all)" \
        "$(_gw_msg select_files)")

    case "$choice" in
        *"$(_gw_msg add_all)"*)
            $_git_real add -A
            echo "$(_gw_msg select_all)"
            ;;
        *)
            local selected
            selected=$(echo "$changes" | gum choose --no-limit --header "$(_gw_msg select_files)")
            [[ -z "$selected" ]] && return 0
            echo "$selected" | xargs $_git_real add
            echo "$(_gw_msg added)"
            ;;
    esac
}

_gw_commit() {
    _gw_check_git || return 1

    # Check if anything is staged
    local staged
    staged=$($_git_real diff --cached --name-only 2>/dev/null)
    if [[ -z "$staged" ]]; then
        echo "$(_gw_msg nothing_staged)"
        return 1
    fi

    local msg
    if command -v gum &>/dev/null; then
        msg=$(gum input --placeholder "$(_gw_msg commit_msg)")
    else
        printf "%s: " "$(_gw_msg commit_msg)"
        read msg
    fi
    [[ -z "$msg" ]] && return 0

    $_git_real commit -m "$msg"
    echo "$(_gw_msg committed)"
}

_gw_upload() {
    _gw_check_git || return 1

    # Check if remote exists
    if ! $_git_real remote get-url origin &>/dev/null; then
        if command -v gum &>/dev/null && command -v gh &>/dev/null; then
            if gum confirm "$(_gw_msg no_remote)"; then
                gh repo create --source . --push
                echo "$(_gw_msg uploaded)"
                return
            fi
        else
            echo "$(_gw_msg no_remote)" >&2
        fi
        return 1
    fi

    $_git_real push && echo "$(_gw_msg uploaded)"
}

_gw_download() {
    _gw_check_git || return 1
    $_git_real pull && echo "$(_gw_msg downloaded)"
}

_gw_log() {
    _gw_check_git || return 1
    if command -v delta &>/dev/null; then
        $_git_real log --oneline --graph --decorate --all \
            --format="%C(auto)%h %C(cyan)%ar %C(reset)%s %C(dim)— %an%C(reset)" \
            -20 | delta --paging=never
    else
        $_git_real log --oneline --graph --decorate --all \
            --format="%C(auto)%h %C(cyan)%ar %C(reset)%s %C(dim)— %an%C(reset)" \
            -20
    fi
}

_gw_switch() {
    _gw_check_git || return 1

    local branches
    branches=$($_git_real branch --format='%(refname:short)' 2>/dev/null)
    [[ -z "$branches" ]] && return 0

    local selected
    if command -v gum &>/dev/null; then
        selected=$(echo "$branches" | gum choose --header "$(_gw_msg select_branch)")
    else
        echo "$branches"
        return 0
    fi

    [[ -n "$selected" ]] && $_git_real checkout "$selected"
}

_gw_menu() {
    _gw_check_git || return 1

    if ! command -v gum &>/dev/null; then
        $_git_real status
        return
    fi

    echo "$(_gw_msg header)"
    echo ""

    local dim=$'\033[2m'
    local reset=$'\033[0m'

    local choice
    choice=$(gum choose \
        "$(_gw_msg status)  ${dim}git status${reset}  — $(_gw_msg status_desc)" \
        "$(_gw_msg add)  ${dim}git add${reset}  — $(_gw_msg add_desc)" \
        "$(_gw_msg commit)  ${dim}git commit${reset}  — $(_gw_msg commit_desc)" \
        "$(_gw_msg upload)  ${dim}git push${reset}  — $(_gw_msg upload_desc)" \
        "$(_gw_msg download)  ${dim}git pull${reset}  — $(_gw_msg download_desc)" \
        "$(_gw_msg log)  ${dim}git log${reset}  — $(_gw_msg log_desc)" \
        "$(_gw_msg switch)  ${dim}git checkout${reset}  — $(_gw_msg switch_desc)" \
        "$(_gw_msg worktree)  ${dim}git worktree${reset}  — $(_gw_msg worktree_desc)")

    case "$choice" in
        *"$(_gw_msg status)"*)   echo "${dim}→ git status${reset}"; echo; _gw_status ;;
        *"$(_gw_msg add)"*)      echo "${dim}→ git add${reset}"; _gw_add ;;
        *"$(_gw_msg commit)"*)   echo "${dim}→ git commit${reset}"; _gw_commit ;;
        *"$(_gw_msg upload)"*)   echo "${dim}→ git push${reset}"; _gw_upload ;;
        *"$(_gw_msg download)"*) echo "${dim}→ git pull${reset}"; _gw_download ;;
        *"$(_gw_msg log)"*)      echo "${dim}→ git log${reset}"; echo; _gw_log ;;
        *"$(_gw_msg switch)"*)   echo "${dim}→ git checkout${reset}"; _gw_switch ;;
        *"$(_gw_msg worktree)"*) echo "${dim}→ git worktree${reset}"; wt ;;
    esac
}

# Override `git`
# - bare `git` → interactive menu
# - `git clone <url>` → ghq get (stores in ~/projects/)
# - everything else → real git
git() {
    if [[ $# -eq 0 ]]; then
        _gw_menu
    elif [[ "$1" == "clone" ]]; then
        shift
        if command -v ghq &>/dev/null; then
            echo "${dim:-}→ ghq get $@${reset:-}"
            ghq get "$@" && echo "$(_gw_msg cloned)"
        else
            $_git_real clone "$@"
        fi
    else
        $_git_real "$@"
    fi
}
