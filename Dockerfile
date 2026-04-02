FROM homebrew/brew:latest

USER linuxbrew

# UTF-8 locale
RUN sudo locale-gen en_US.UTF-8 2>/dev/null || true
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

# Pre-install tools (install.sh does this too, but pre-install for faster builds)
RUN brew install git gh starship eza bat fd ripgrep zoxide trash-cli gum zsh node \
    zsh-autosuggestions atuin sk ghq zsh-syntax-highlighting vivid thefuck git-delta direnv tldr
RUN npm install -g @anthropic-ai/claude-code 2>/dev/null || true

# Copy yasashii-dotfiles
COPY --chown=linuxbrew:linuxbrew . /home/linuxbrew/.yasashii/
RUN find /home/linuxbrew/.yasashii -name '*.sh' -exec chmod +x {} \; && \
    chmod +x /home/linuxbrew/.yasashii/claude/beginner/statusline.py \
             /home/linuxbrew/.yasashii/scripts/generate-starship.sh

# Apply gitconfig + gitignore (install.sh step 5)
RUN cp /home/linuxbrew/.yasashii/config/git/gitconfig /home/linuxbrew/.gitconfig && \
    mkdir -p /home/linuxbrew/.config/git && \
    cp /home/linuxbrew/.yasashii/config/git/ignore /home/linuxbrew/.config/git/ignore

# Shell config (install.sh step 6)
RUN echo 'source ~/.yasashii/shell/init.sh' > /home/linuxbrew/.zshrc

# ECC clone (install.sh step 8)
RUN GHQ_ROOT=/home/linuxbrew/projects ghq get affaan-m/everything-claude-code 2>/dev/null || true
RUN ECC_DIR=$(find /home/linuxbrew/projects -type d -name "everything-claude-code" -maxdepth 5 2>/dev/null | head -1) && \
    if [ -n "$ECC_DIR" ]; then \
      python3 -c "import json; \
d=json.load(open('/home/linuxbrew/.yasashii/claude/beginner/settings.layer.json')); \
d['env']['ECC_ROOT']='$ECC_DIR'; \
d['env']['CLAUDE_PLUGIN_ROOT']='$ECC_DIR'; \
json.dump(d,open('/home/linuxbrew/.yasashii/claude/beginner/settings.layer.json','w'),indent=2,ensure_ascii=False)"; \
    fi

# Generate starship themes
RUN bash /home/linuxbrew/.yasashii/scripts/generate-starship.sh

# Default config
RUN printf 'YASASHII_LANG=ja\nYASASHII_THEME=dark\nYASASHII_FONT_SIZE=normal\n' \
    > /home/linuxbrew/.yasashii/.config

# Simulate user's environment: ghq-cloned repos
RUN mkdir -p /home/linuxbrew/projects/github.com/esh2n/yasashii-dotfiles && \
    cp -r /home/linuxbrew/.yasashii/* /home/linuxbrew/projects/github.com/esh2n/yasashii-dotfiles/ && \
    cd /home/linuxbrew/projects/github.com/esh2n/yasashii-dotfiles && \
    git init && git add -A && git config user.email "test@test.com" && git config user.name "Test" && git commit -m "init"

RUN mkdir -p /home/linuxbrew/projects/github.com/testuser/my-app && \
    cd /home/linuxbrew/projects/github.com/testuser/my-app && \
    git init && git config user.email "test@test.com" && git config user.name "Test" && \
    echo "hello" > README.md && git add . && git commit -m "init" && \
    echo "changed" >> README.md && echo "new file" > newfile.txt

WORKDIR /home/linuxbrew/projects/github.com/testuser/my-app
CMD ["/home/linuxbrew/.linuxbrew/bin/zsh"]
