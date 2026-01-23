# dotfiles Development Container
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Install additional packages
RUN apt-get update && apt-get install -y \
    bat \
    curl \
    fd-find \
    fzf \
    git \
    jq \
    neovim \
    ripgrep \
    shellcheck \
    stow \
    tmux \
    tree \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Create symlinks for renamed packages
RUN ln -sf /usr/bin/batcat /usr/local/bin/bat \
    && ln -sf /usr/bin/fdfind /usr/local/bin/fd

# Install modern CLI tools via cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . "$HOME/.cargo/env" \
    && cargo install eza zoxide du-dust procs sd hyperfine tokei \
    && rm -rf /root/.cargo/registry

# Install bats-core for testing
RUN git clone https://github.com/bats-core/bats-core.git /tmp/bats-core \
    && cd /tmp/bats-core \
    && ./install.sh /usr/local \
    && rm -rf /tmp/bats-core

# Install bats helper libraries
RUN git clone https://github.com/bats-core/bats-support.git /usr/local/lib/bats-support \
    && git clone https://github.com/bats-core/bats-assert.git /usr/local/lib/bats-assert

# Set default shell to zsh
SHELL ["/bin/zsh", "-c"]

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
