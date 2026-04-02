#!/usr/bin/env bash
# git-friendly: git output in friendly language
# Usage: git-friendly status | git-friendly log

YASASHII_DIR="${HOME}/.yasashii"
YASASHII_CONFIG="${YASASHII_DIR}/.config"

if [[ -f "$YASASHII_CONFIG" ]]; then
    source "$YASASHII_CONFIG"
fi

LANG_CODE="${YASASHII_LANG:-en}"

# Load labels from glossary
get_label() {
    local section="$1" key="$2" field="$3"
    local glossary="${YASASHII_DIR}/glossary/${LANG_CODE}.toml"
    python3 -c "
import sys
section = '$section'
key = '$key'
field = '$field'
in_section = False
for line in open('$glossary'):
    line = line.strip()
    if line.startswith('[' + section + ']'):
        in_section = True
        continue
    if line.startswith('[') and in_section:
        break
    if in_section and line.startswith(key + ' '):
        import re
        m = re.search(field + r' = \"([^\"]+)\"', line)
        if m:
            print(m.group(1))
            sys.exit(0)
" 2>/dev/null
}

friendly_status() {
    local git_st
    git_st=$(git status --porcelain 2>/dev/null)

    if [[ -z "$git_st" ]]; then
        local icon
        icon=$(get_label git.status clean icon)
        local label
        label=$(get_label git.status clean detail)
        echo "${icon:-✨} ${label:-Everything is saved}"
        return
    fi

    local branch
    branch=$(git branch --show-current 2>/dev/null)

    case "$LANG_CODE" in
        ja) echo "📍 ブランチ: ${branch}" ;;
        zh) echo "📍 分支: ${branch}" ;;
        ko) echo "📍 브랜치: ${branch}" ;;
        *)  echo "📍 Branch: ${branch}" ;;
    esac
    echo ""

    local untracked=0 modified=0 deleted=0 staged=0 conflicted=0

    while IFS= read -r line; do
        local x="${line:0:1}" y="${line:1:1}"
        case "$y" in
            '?') ((untracked++)) ;;
            'M') ((modified++)) ;;
            'D') ((deleted++)) ;;
        esac
        case "$x" in
            'A'|'M'|'R') ((staged++)) ;;
            'U') ((conflicted++)) ;;
        esac
    done <<< "$git_st"

    if [[ $staged -gt 0 ]]; then
        local icon=$(get_label git.status staged icon)
        local label=$(get_label git.status staged short)
        echo "  ${icon:-✅} ${label:-Selected}: ${staged}"
    fi
    if [[ $modified -gt 0 ]]; then
        local icon=$(get_label git.status modified icon)
        local label=$(get_label git.status modified short)
        echo "  ${icon:-✏️} ${label:-Changed}: ${modified}"
    fi
    if [[ $untracked -gt 0 ]]; then
        local icon=$(get_label git.status untracked icon)
        local label=$(get_label git.status untracked short)
        echo "  ${icon:-📄} ${label:-New}: ${untracked}"
    fi
    if [[ $deleted -gt 0 ]]; then
        local icon=$(get_label git.status deleted icon)
        local label=$(get_label git.status deleted short)
        echo "  ${icon:-🗑️} ${label:-Deleted}: ${deleted}"
    fi
    if [[ $conflicted -gt 0 ]]; then
        local icon=$(get_label git.status conflicted icon)
        local label=$(get_label git.status conflicted short)
        echo "  ${icon:-⚠️} ${label:-Conflict}: ${conflicted}"
    fi
}

friendly_log() {
    git log --oneline -10 --pretty=format:"%C(auto)%h %C(cyan)%ar%C(reset) %s" 2>/dev/null
}

case "${1:-}" in
    status) friendly_status ;;
    log)    friendly_log ;;
    *)
        case "$LANG_CODE" in
            ja) echo "使い方: git-friendly {status|log}" ;;
            zh) echo "用法: git-friendly {status|log}" ;;
            ko) echo "사용법: git-friendly {status|log}" ;;
            *)  echo "Usage: git-friendly {status|log}" ;;
        esac
        ;;
esac
