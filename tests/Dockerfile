# dotfiles テスト環境用 Dockerfile
# Ubuntu環境でのdotfiles動作検証

FROM ubuntu:22.04

# 非対話モード
ENV DEBIAN_FRONTEND=noninteractive

# 必要パッケージのインストール
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zsh \
    bats \
    sudo \
    locales \
    stow \
    make \
    vim \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# ロケール設定
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# batsヘルパーのインストール
RUN git clone --depth=1 https://github.com/bats-core/bats-support.git /usr/local/lib/bats-support && \
    git clone --depth=1 https://github.com/bats-core/bats-assert.git /usr/local/lib/bats-assert

# テストユーザーの作成
RUN useradd -m -s /bin/zsh testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# dotfilesをコピー
COPY --chown=testuser:testuser . /home/testuser/dotfiles

# 作業ディレクトリ設定
WORKDIR /home/testuser/dotfiles

# ユーザー切り替え
USER testuser
ENV HOME=/home/testuser

# デフォルトコマンド: テスト実行
CMD ["bats", "tests/"]
