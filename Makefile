# dotfiles Makefile
# GNU Stowを使った宣言的なシンボリックリンク管理
#
# 使用方法:
#   make install      # 全設定をインストール
#   make uninstall    # 全設定をアンインストール
#   make install-zsh  # zsh設定のみインストール
#   make help         # ヘルプ表示

STOW := stow
STOW_DIR := stow
STOW_FLAGS := -v --target=$(HOME) --dir=$(STOW_DIR) --restow

# Stowパッケージ一覧
# 注: espanso, raycast, antigravityはOS固有パスのためStow対象外（bootstrap.shで個別処理）
PACKAGES := zsh git nvim tmux ghostty bat atuin claude gh ssh

# デフォルトターゲット
.PHONY: help
help:
	@echo "dotfiles - GNU Stowベースのシンボリックリンク管理"
	@echo ""
	@echo "使用方法:"
	@echo "  make install        全設定をインストール"
	@echo "  make uninstall      全設定をアンインストール"
	@echo "  make install-PKG    特定パッケージをインストール (例: make install-zsh)"
	@echo "  make uninstall-PKG  特定パッケージをアンインストール"
	@echo "  make list           インストール可能なパッケージ一覧"
	@echo "  make check          Stowのドライラン（変更確認）"
	@echo "  make bootstrap      完全セットアップ（bootstrap.sh実行）"
	@echo ""
	@echo "検証・メンテナンス:"
	@echo "  make lint           ShellCheckでlint"
	@echo "  make health         全体ヘルスチェック（lint+verify）"
	@echo "  make bench          Zsh起動速度ベンチマーク"
	@echo "  make deps           Homebrew依存ツリー表示"
	@echo "  make brewsync       Brewfile同期チェック"
	@echo "  make changelog      CHANGELOG.md生成（git-cliff）"
	@echo "  make clean          バックアップファイル削除"
	@echo ""
	@echo "パッケージ: $(PACKAGES)"

# パッケージ一覧表示
.PHONY: list
list:
	@echo "利用可能なパッケージ: $(PACKAGES)"

# ドライラン
.PHONY: check
check:
	@for pkg in $(PACKAGES); do \
		echo "=== $$pkg ==="; \
		$(STOW) --simulate $(STOW_FLAGS) $$pkg 2>&1 || true; \
	done

# 全パッケージインストール
.PHONY: install
install: $(addprefix install-,$(PACKAGES))
	@echo "✓ 全パッケージをインストールしました"

# 全パッケージアンインストール
.PHONY: uninstall
uninstall: $(addprefix uninstall-,$(PACKAGES))
	@echo "✓ 全パッケージをアンインストールしました"

# 個別パッケージのインストール/アンインストール
.PHONY: install-%
install-%:
	@if [ -d "$(STOW_DIR)/$*" ]; then \
		echo "Installing $*..."; \
		$(STOW) $(STOW_FLAGS) $*; \
		echo "✓ $* をインストールしました"; \
	else \
		echo "⚠ パッケージ $(STOW_DIR)/$* が見つかりません"; \
	fi

.PHONY: uninstall-%
uninstall-%:
	@if [ -d "$(STOW_DIR)/$*" ]; then \
		echo "Uninstalling $*..."; \
		$(STOW) -D $(STOW_FLAGS) $*; \
		echo "✓ $* をアンインストールしました"; \
	fi

# bootstrap.sh実行
.PHONY: bootstrap
bootstrap:
	bash bootstrap.sh

# シェルスクリプトのlint
.PHONY: lint
lint:
	@echo "Running shellcheck..."
	@shellcheck -S warning bootstrap.sh scripts/**/*.sh || true

# クリーン（バックアップファイル削除）
.PHONY: clean
clean:
	@find . -name "*.backup.*" -delete
	@find . -name "*~" -delete
	@echo "✓ バックアップファイルを削除しました"

# zsh起動速度ベンチマーク
.PHONY: bench
bench:
	@echo "=== Zsh起動速度ベンチマーク ==="
	@bash scripts/utils/zsh-benchmark.sh

# 全体ヘルスチェック
.PHONY: health
health: lint check
	@echo ""
	@echo "=== セットアップ検証 ==="
	@bash scripts/maintenance/verify-setup.sh

# Homebrew依存ツリー表示
.PHONY: deps
deps:
	@echo "=== Brewfile 依存関係 ==="
	@brew deps --tree stow bat eza fzf ripgrep zoxide 2>/dev/null || echo "brew deps 実行にはHomebrewが必要です"

# Brewfile同期チェック
.PHONY: brewsync
brewsync:
	@bash scripts/maintenance/sync-brewfile.sh

# CHANGELOG生成
.PHONY: changelog
changelog:
	@if command -v git-cliff >/dev/null 2>&1; then \
		git-cliff -o CHANGELOG.md; \
		echo "✓ CHANGELOG.md を生成しました"; \
	else \
		echo "⚠ git-cliff がインストールされていません"; \
		echo "  brew install git-cliff でインストールしてください"; \
	fi
