#!/usr/bin/env bash
set -euo pipefail

# Build and run yasashii-dotfiles in a container
# Usage: ./test.sh [interactive|auto|fresh]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="yasashii-dotfiles-test"
FRESH_IMAGE="yasashii-dotfiles-fresh"

case "${1:-auto}" in
    fresh)
        echo "🆕 Building fresh install container (no ~/.yasashii)..."
        docker build -f - -t "$FRESH_IMAGE" "$SCRIPT_DIR" <<'DOCKERFILE'
FROM homebrew/brew:latest
USER linuxbrew
RUN sudo locale-gen en_US.UTF-8 2>/dev/null || true
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

# Copy repo to temp (install.sh will copy to ~/.yasashii)
COPY --chown=linuxbrew:linuxbrew . /tmp/yasashii-src/
RUN chmod +x /tmp/yasashii-src/install.sh

# Create a test project to land in
RUN mkdir -p /home/linuxbrew/projects/github.com/testuser/my-app && \
    cd /home/linuxbrew/projects/github.com/testuser/my-app && \
    git init && git config user.email "test@test.com" && git config user.name "Test" && \
    echo "hello" > README.md && git add . && git commit -m "init"

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
WORKDIR /home/linuxbrew/projects/github.com/testuser/my-app
CMD ["/bin/bash"]
DOCKERFILE
        echo "🚀 Starting fresh install..."
        echo "   Run: bash /tmp/install.sh"
        docker run -it --rm "$FRESH_IMAGE"
        ;;
    interactive)
        echo "🔨 Building container..."
        docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"
        echo "🚀 Starting interactive zsh..."
        echo "   Try: ls, git, wt, tips, yasashii"
        docker run -it --rm "$IMAGE_NAME"
        ;;
    auto)
        echo "🔨 Building container..."
        docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"
        echo "🧪 Running tests..."
        docker run --rm "$IMAGE_NAME" /home/linuxbrew/.linuxbrew/bin/zsh -c '
            source /home/linuxbrew/.yasashii/shell/init.sh 2>/dev/null

            PASS=0
            FAIL=0

            assert() {
                local desc="$1" cmd="$2"
                if eval "$cmd" >/dev/null 2>&1; then
                    echo "  ✅ $desc"
                    ((PASS++))
                else
                    echo "  ❌ $desc"
                    ((FAIL++))
                fi
            }

            echo ""
            echo "=== Glossary ==="
            assert "ja.toml exists"    "[[ -f ~/.yasashii/glossary/ja.toml ]]"
            assert "en.toml exists"    "[[ -f ~/.yasashii/glossary/en.toml ]]"
            assert "zh.toml exists"    "[[ -f ~/.yasashii/glossary/zh.toml ]]"
            assert "ko.toml exists"    "[[ -f ~/.yasashii/glossary/ko.toml ]]"
            assert "schema.toml exists" "[[ -f ~/.yasashii/glossary/schema.toml ]]"

            echo ""
            echo "=== CLI Tools ==="
            assert "eza installed"     "command -v eza"
            assert "bat installed"     "command -v bat"
            assert "fd installed"      "command -v fd"
            assert "rg installed"      "command -v rg"
            assert "starship installed" "command -v starship"
            assert "gum installed"     "command -v gum"
            assert "trash installed"   "command -v trash"

            echo ""
            echo "=== Aliases ==="
            assert "ls → eza"         "alias ls 2>&1 | grep -q eza"
            assert "cat → bat"        "alias cat 2>&1 | grep -q bat"
            assert "rm → trash"       "alias rm 2>&1 | grep -q trash"

            echo ""
            echo "=== Starship Themes (generated) ==="
            assert "ja-dark exists"    "[[ -f ~/.yasashii/config/starship/generated/ja-dark.toml ]]"
            assert "en-dark exists"    "[[ -f ~/.yasashii/config/starship/generated/en-dark.toml ]]"
            assert "zh-dark exists"    "[[ -f ~/.yasashii/config/starship/generated/zh-dark.toml ]]"
            assert "ko-dark exists"    "[[ -f ~/.yasashii/config/starship/generated/ko-dark.toml ]]"
            assert "ja has ファイルの変更" "grep -q ファイルの変更 ~/.yasashii/config/starship/generated/ja-dark.toml"
            assert "en has files changed" "grep -q files.changed ~/.yasashii/config/starship/generated/en-dark.toml"
            assert "ja has 要対応"     "grep -q 要対応 ~/.yasashii/config/starship/generated/ja-dark.toml"
            assert "no templates left" "! grep -q '{{' ~/.yasashii/config/starship/generated/ja-dark.toml"
            assert "STARSHIP_CONFIG set" "[[ -n \$STARSHIP_CONFIG ]]"

            echo ""
            echo "=== git-friendly ==="
            assert "git-friendly runs"     "bash ~/.yasashii/shell/git-friendly.sh status"
            assert "shows modified"        "bash ~/.yasashii/shell/git-friendly.sh status | grep -q 編集済み"
            assert "shows new file"        "bash ~/.yasashii/shell/git-friendly.sh status | grep -q 新しい"

            echo ""
            echo "=== New Tools ==="
            assert "sk installed"      "command -v sk"
            assert "ghq installed"     "command -v ghq"
            assert "atuin installed"   "command -v atuin"
            assert "vivid installed"   "command -v vivid"
            assert "thefuck installed" "command -v thefuck"
            assert "delta installed"   "command -v delta"
            assert "direnv installed"  "command -v direnv"

            echo ""
            echo "=== Shell Functions ==="
            assert "wt function"       "type wt 2>&1 | grep -q function"
            assert "git wrapper"       "type git 2>&1 | grep -q function"
            assert "mkcd function"     "type mkcd 2>&1 | grep -q function"
            assert "extract function"  "type extract 2>&1 | grep -q function"

            echo ""
            echo "=== Git Config ==="
            assert "gitconfig exists"  "[[ -f ~/.yasashii/config/git/gitconfig ]]"
            assert "gitignore exists"  "[[ -f ~/.yasashii/config/git/ignore ]]"
            assert "delta configured"  "grep -q delta ~/.yasashii/config/git/gitconfig"
            assert "ghq root set"      "grep -q projects ~/.yasashii/config/git/gitconfig"

            echo ""
            echo "=== Claude Profile ==="
            assert "CLAUDE.layer.md exists"      "[[ -f ~/.yasashii/claude/beginner/CLAUDE.layer.md ]]"
            assert "settings.layer.json exists"  "[[ -f ~/.yasashii/claude/beginner/settings.layer.json ]]"

            echo ""
            echo "=== Config ==="
            assert ".config exists"    "[[ -f ~/.yasashii/.config ]]"
            assert "YASASHII_LANG=ja"  "grep -q YASASHII_LANG=ja ~/.yasashii/.config"

            echo ""
            echo "=== Results ==="
            echo "  PASSED: $PASS"
            echo "  FAILED: $FAIL"
            [[ $FAIL -eq 0 ]] && echo "  🎉 ALL PASSED" || exit 1
        '
        ;;
esac
