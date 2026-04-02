#!/usr/bin/env zsh
# yasashii-dotfiles shell initializer
# Source this from .zshrc: source ~/.yasashii/shell/init.sh

YASASHII_DIR="${HOME}/.yasashii"
YASASHII_CONFIG="${YASASHII_DIR}/.config"

# Load user config
if [[ -f "$YASASHII_CONFIG" ]]; then
    source "$YASASHII_CONFIG"
fi

YASASHII_LANG="${YASASHII_LANG:-en}"
YASASHII_THEME="${YASASHII_THEME:-dark}"

# --- XDG Base Directory (keeps home directory clean) ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# --- Pager ---
export LESS="-R"
export LESSHISTFILE="-"

# --- Starship ---
export STARSHIP_CONFIG="${YASASHII_DIR}/config/starship/generated/${YASASHII_LANG}-${YASASHII_THEME}.toml"

# --- Transparent command replacements ---
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza --icons --group-directories-first -l'
    alias la='eza --icons --group-directories-first -la'
fi

if command -v bat &>/dev/null; then
    alias cat='bat --plain --paging=never'
fi

if command -v trash &>/dev/null; then
    alias rm='trash'
fi

if command -v zoxide &>/dev/null; then
    if [[ -n "$ZSH_VERSION" ]]; then
        eval "$(zoxide init zsh)"
    elif [[ -n "$BASH_VERSION" ]]; then
        eval "$(zoxide init bash)"
    fi
fi

# --- ZSH options (only in zsh) ---
if [[ -n "$ZSH_VERSION" ]]; then
    # Completion
    autoload -Uz compinit && compinit -u
    zstyle ':completion:*:default' menu select=1
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
    setopt auto_list
    setopt auto_menu

    # History
    HISTFILE=~/.zsh_history
    HISTSIZE=10000
    SAVEHIST=10000
    setopt append_history
    setopt hist_ignore_dups
    setopt hist_ignore_space
    setopt share_history
    setopt inc_append_history

    # Navigation
    setopt auto_cd
    setopt auto_pushd
    setopt pushd_ignore_dups

    # UX
    setopt correct
    setopt interactive_comments
    setopt no_flow_control

    # History search with arrow keys + Ctrl+P/N
    autoload -Uz history-search-end
    zle -N history-beginning-search-backward-end history-search-end
    zle -N history-beginning-search-forward-end history-search-end
    bindkey "^[[A" history-beginning-search-backward-end
    bindkey "^[[B" history-beginning-search-forward-end
    bindkey "^P" history-beginning-search-backward-end
    bindkey "^N" history-beginning-search-forward-end

    # Word navigation (Alt+Left/Right — standard in editors and browsers)
    bindkey "^[[1;3C" forward-word
    bindkey "^[[1;3D" backward-word
fi

# --- Inline suggestions (fish-style ghost text) ---
# Shows command suggestions as you type. Press → to accept.
if [[ -n "$ZSH_VERSION" ]]; then
    # Try linuxbrew path, then macOS homebrew path
    for _yas_as in \
        "/home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
        "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
        "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
        if [[ -f "$_yas_as" ]]; then
            source "$_yas_as"
            break
        fi
    done
    unset _yas_as
fi

# --- Syntax highlighting (colors commands as you type) ---
if [[ -n "$ZSH_VERSION" ]]; then
    for _yas_sh in \
        "/home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
        "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
        "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; do
        if [[ -f "$_yas_sh" ]]; then
            source "$_yas_sh"
            break
        fi
    done
    unset _yas_sh
fi

# --- Atuin (enhanced history) ---
if command -v atuin &>/dev/null; then
    if [[ -n "$ZSH_VERSION" ]]; then
        eval "$(atuin init zsh)"
    fi
fi

# --- Vivid (LS_COLORS) ---
if command -v vivid &>/dev/null; then
    export LS_COLORS="$(vivid generate molokai)"
fi

# --- Thefuck (command correction) ---
if command -v thefuck &>/dev/null; then
    eval "$(thefuck --alias)"
fi

# --- Direnv (per-project env) ---
if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi

# --- tldr (simplified man pages) ---
if command -v tldr &>/dev/null; then
    alias help='tldr'
fi

# --- Skim keybindings (fuzzy finder) ---
if [[ -n "$ZSH_VERSION" ]] && command -v sk &>/dev/null; then
    # Ctrl+] — jump to ghq project
    sk_select_src() {
        if ! command -v ghq &>/dev/null; then return 1; fi
        local selected
        selected=$(ghq list -p | sk --ansi --reverse --height '50%')
        if [[ -n "$selected" ]]; then
            BUFFER="cd ${(q)selected}"
            zle accept-line
        fi
        zle clear-screen
    }
    zle -N sk_select_src
    bindkey '^]' sk_select_src

    # Ctrl+G — jump to recent directory (zoxide)
    sk_change_directory() {
        if ! command -v zoxide &>/dev/null; then return 1; fi
        local selected
        selected=$(zoxide query -l | sk --ansi --reverse --height '50%')
        if [[ -n "$selected" ]]; then
            BUFFER="cd ${(q)selected}"
            zle accept-line
        fi
        zle clear-screen
    }
    zle -N sk_change_directory
    bindkey '^g' sk_change_directory

    # Ctrl+F — find file in project
    sk_select_file() {
        local selected
        selected=$(fd --type f --hidden --exclude .git | sk --ansi --reverse --height '50%')
        if [[ -n "$selected" ]]; then
            BUFFER="${BUFFER}${(q)selected}"
            CURSOR=$#BUFFER
        fi
        zle clear-screen
    }
    zle -N sk_select_file
    bindkey '^f' sk_select_file
fi

# --- Settings ---
yasashii() {
    source "${YASASHII_DIR}/setup.sh"
}

# --- Tips (quick reference) ---
source "${YASASHII_DIR}/shell/tips.sh"

# --- Utility functions ---
# mkcd: create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1" }

# --- Git interactive menu (bare `git` shows friendly menu) ---
source "${YASASHII_DIR}/shell/git-wrapper.sh"

# --- Worktree manager ---
source "${YASASHII_DIR}/shell/wt.sh"

# extract: universal archive extraction
extract() {
    if [[ ! -f "$1" ]]; then
        echo "File not found: $1" >&2
        return 1
    fi
    case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz)  tar xzf "$1" ;;
        *.tar.xz)  tar xJf "$1" ;;
        *.bz2)     bunzip2 "$1" ;;
        *.gz)      gunzip "$1" ;;
        *.tar)     tar xf "$1" ;;
        *.tbz2)    tar xjf "$1" ;;
        *.tgz)     tar xzf "$1" ;;
        *.zip)     unzip "$1" ;;
        *.7z)      7z x "$1" ;;
        *.rar)     unrar x "$1" ;;
        *)
            case "$YASASHII_LANG" in
                ja) echo "展開方法が分かりません: $1" ;;
                *)  echo "Don't know how to extract: $1" ;;
            esac
            return 1
            ;;
    esac
}

# For enhanced AI-powered completion, install Kiro CLI: https://kiro.dev

# --- Starship ---
if command -v starship &>/dev/null; then
    if [[ -n "$ZSH_VERSION" ]]; then
        eval "$(starship init zsh)"
    elif [[ -n "$BASH_VERSION" ]]; then
        eval "$(starship init bash)"
    fi
fi

# --- command_not_found handler ---
command_not_found_handler() {
    local cmd="$1"
    shift

    # Load language-specific messages
    case "$YASASHII_LANG" in
        ja) echo "「${cmd}」は見つかりません。" ;;
        zh) echo "「${cmd}」未找到。" ;;
        ko) echo "「${cmd}」을(를) 찾을 수 없습니다." ;;
        *)  echo "\"${cmd}\" not found." ;;
    esac

    # Suggest similar commands
    if command -v brew &>/dev/null; then
        local suggestion
        suggestion=$(brew which-formula "$cmd" 2>/dev/null || true)
        if [[ -n "$suggestion" ]]; then
            case "$YASASHII_LANG" in
                ja) echo "→ brew install ${suggestion} でインストールできます" ;;
                zh) echo "→ 可以通过 brew install ${suggestion} 安装" ;;
                ko) echo "→ brew install ${suggestion} 로 설치할 수 있습니다" ;;
                *)  echo "→ Install with: brew install ${suggestion}" ;;
            esac
        fi
    fi

    return 127
}

# --- Welcome screen (first launch only) ---
zsh "${YASASHII_DIR}/shell/welcome.sh" 2>/dev/null

# --- Error handler (zsh only) ---
if [[ -n "$ZSH_VERSION" ]]; then
    # Friendly error messages for common failures
    yasashii_precmd() {
        local exit_code=$?
        [[ $exit_code -eq 0 ]] && return

        case "$exit_code" in
            1)   ;; # Generic error, too noisy to always show
            126)
                case "$YASASHII_LANG" in
                    ja) echo "  → 実行権限がありません。chmod +x で権限を付けてください" ;;
                    zh) echo "  → 没有执行权限。请用 chmod +x 添加权限" ;;
                    ko) echo "  → 실행 권한이 없습니다. chmod +x로 권한을 추가하세요" ;;
                    *)  echo "  → Permission denied. Add execute permission with: chmod +x" ;;
                esac
                ;;
            127) ;; # command_not_found_handler already covers this
            128)
                case "$YASASHII_LANG" in
                    ja) echo "  → 中断されました" ;;
                    zh) echo "  → 已中断" ;;
                    ko) echo "  → 중단되었습니다" ;;
                    *)  echo "  → Interrupted" ;;
                esac
                ;;
        esac
    }
    precmd_functions+=(yasashii_precmd)

    # Long-running command notification (10+ seconds)
    _YASASHII_CMD_START=0
    _YASASHII_CMD_NAME=""
    _YASASHII_NOTIFY_THRESHOLD=10
    _YASASHII_NOTIFY_EXCLUDE="claude|git|bash|zsh|nvim|vim|vi|less|man|ssh|top"

    yasashii_preexec() {
        _YASASHII_CMD_START=$EPOCHSECONDS
        _YASASHII_CMD_NAME="$1"
    }

    yasashii_notify_precmd() {
        [[ $_YASASHII_CMD_START -eq 0 ]] && return
        local elapsed=$(( EPOCHSECONDS - _YASASHII_CMD_START ))
        _YASASHII_CMD_START=0

        [[ $elapsed -lt $_YASASHII_NOTIFY_THRESHOLD ]] && return
        [[ "$_YASASHII_CMD_NAME" =~ $_YASASHII_NOTIFY_EXCLUDE ]] && return

        local cmd_short="${_YASASHII_CMD_NAME%% *}"
        case "$YASASHII_LANG" in
            ja) printf '\a'; echo "  ⏱ ${cmd_short} が完了しました (${elapsed}秒)" ;;
            zh) printf '\a'; echo "  ⏱ ${cmd_short} 已完成 (${elapsed}秒)" ;;
            ko) printf '\a'; echo "  ⏱ ${cmd_short} 완료 (${elapsed}초)" ;;
            *)  printf '\a'; echo "  ⏱ ${cmd_short} finished (${elapsed}s)" ;;
        esac
    }

    preexec_functions+=(yasashii_preexec)
    precmd_functions+=(yasashii_notify_precmd)
fi

# --- Explain prompt (Ctrl+H) ---
if [[ -n "$ZSH_VERSION" ]]; then
    explain-prompt() {
        local lang="${YASASHII_LANG:-en}"
        local glossary="${YASASHII_DIR}/glossary/${lang}.toml"
        if [[ ! -f "$glossary" ]]; then
            zle -M "Glossary not found: ${glossary}"
            return
        fi
        # Read detail fields from glossary
        local msg=""
        while IFS= read -r line; do
            if [[ "$line" =~ 'detail = "(.+)"' ]]; then
                [[ -n "$msg" ]] && msg="${msg} | "
                msg="${msg}${match[1]}"
            fi
        done < "$glossary"
        zle -M "${msg:-No help available}"
    }
    zle -N explain-prompt
    bindkey '^H' explain-prompt
fi
