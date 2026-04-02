#!/usr/bin/env bash
set -euo pipefail

# Generate language-specific starship themes from glossary + base themes
# Uses python for template substitution (no sed)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
GLOSSARY_DIR="$ROOT_DIR/glossary"
BASE_DIR="$ROOT_DIR/config/starship/base"
OUT_DIR="$ROOT_DIR/config/starship/generated"

mkdir -p "$OUT_DIR"

get_prompt_val() {
    local file="$1" key="$2"
    python3 -c "
import sys
for line in open('$file'):
    line = line.strip()
    if line.startswith('$key'):
        val = line.split('\"')[1]
        print(val)
        sys.exit(0)
"
}

get_counter() {
    local lang="$1"
    case "$lang" in
        ja) echo "件" ;;
        zh) echo "个" ;;
        ko) echo "개" ;;
        *)  echo "" ;;
    esac
}

# Git icon: U+E702 (nf-dev-git)
GIT_ICON=$(printf '\ue702')

# Home directory name (e.g. "shunya.endo" on macOS, "linuxbrew" in container)
HOME_DIR_NAME=$(basename "$HOME")

LANGUAGES=$(python3 -c "
for line in open('$GLOSSARY_DIR/schema.toml'):
    line = line.strip()
    if line and not line.startswith('[') and '=' in line:
        print(line.split('=')[0].strip())
")

for lang in $LANGUAGES; do
    glossary="$GLOSSARY_DIR/${lang}.toml"
    [[ -f "$glossary" ]] || continue

    unsaved=$(get_prompt_val "$glossary" "unsaved")
    all_saved=$(get_prompt_val "$glossary" "all_saved")
    cloud_upload=$(get_prompt_val "$glossary" "cloud_upload")
    cloud_download=$(get_prompt_val "$glossary" "cloud_download")
    conflict=$(get_prompt_val "$glossary" "conflict")
    worktree=$(get_prompt_val "$glossary" "worktree")
    tips_hint=$(get_prompt_val "$glossary" "tips_hint")
    counter=$(get_counter "$lang")

    for theme in dark light sakura; do
        base="$BASE_DIR/${theme}.toml"
        [[ -f "$base" ]] || continue
        out="$OUT_DIR/${lang}-${theme}.toml"

        python3 -c "
content = open('$base').read()
replacements = {
    '{{UNSAVED_LABEL}}': '''$unsaved''',
    '{{ALL_SAVED_LABEL}}': '''$all_saved''',
    '{{CLOUD_UPLOAD_LABEL}}': '''$cloud_upload''',
    '{{CLOUD_DOWNLOAD_LABEL}}': '''$cloud_download''',
    '{{CONFLICT_LABEL}}': '''$conflict''',
    '{{WORKTREE_LABEL}}': '''$worktree''',
    '{{COUNTER}}': '''$counter''',
    '{{GIT_ICON}}': '''$GIT_ICON''',
    '{{HOME_DIR_NAME}}': '''$HOME_DIR_NAME''',
    '{{TIPS_HINT}}': '''$tips_hint''',
}
for k, v in replacements.items():
    content = content.replace(k, v)
with open('$out', 'w') as f:
    f.write(content)
"
        echo "Generated: $out"
    done
done
