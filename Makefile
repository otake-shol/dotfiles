# dotfiles Makefile
# GNU Stowを使った宣言的なシンボリックリンク管理
#
# 使用方法:
#   make install      # 全設定をインストール
#   make uninstall    # 全設定をアンインストール
#   make install-zsh  # zsh設定のみインストール
#   make help         # ヘルプ表示

STOW := stow
STOW_FLAGS := -v --target=$(HOME) --restow

# Stowパッケージ一覧
PACKAGES := zsh git nvim tmux ghostty bat atuin

# macOS専用パッケージ
MACOS_PACKAGES := antigravity

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
	@echo "パッケージ: $(PACKAGES)"

# パッケージ一覧表示
.PHONY: list
list:
	@echo "利用可能なパッケージ:"
	@echo "  共通: $(PACKAGES)"
	@echo "  macOS: $(MACOS_PACKAGES)"

# ドライラン
.PHONY: check
check:
	@for pkg in $(PACKAGES); do \
		echo "=== $$pkg ==="; \
		$(STOW) --simulate $(STOW_FLAGS) stow/$$pkg 2>&1 || true; \
	done

# 全パッケージインストール
.PHONY: install
install: $(addprefix install-,$(PACKAGES))
	@echo "✓ 全パッケージをインストールしました"
ifeq ($(shell uname -s),Darwin)
	@$(MAKE) install-macos
endif

# 全パッケージアンインストール
.PHONY: uninstall
uninstall: $(addprefix uninstall-,$(PACKAGES))
	@echo "✓ 全パッケージをアンインストールしました"
ifeq ($(shell uname -s),Darwin)
	@$(MAKE) uninstall-macos
endif

# macOS専用パッケージ
.PHONY: install-macos
install-macos: $(addprefix install-,$(MACOS_PACKAGES))

.PHONY: uninstall-macos
uninstall-macos: $(addprefix uninstall-,$(MACOS_PACKAGES))

# 個別パッケージのインストール/アンインストール
.PHONY: install-%
install-%:
	@if [ -d "stow/$*" ]; then \
		echo "Installing $*..."; \
		$(STOW) $(STOW_FLAGS) stow/$*; \
		echo "✓ $* をインストールしました"; \
	else \
		echo "⚠ パッケージ stow/$* が見つかりません"; \
	fi

.PHONY: uninstall-%
uninstall-%:
	@if [ -d "stow/$*" ]; then \
		echo "Uninstalling $*..."; \
		$(STOW) -D $(STOW_FLAGS) stow/$*; \
		echo "✓ $* をアンインストールしました"; \
	fi

# bootstrap.sh実行
.PHONY: bootstrap
bootstrap:
	bash bootstrap.sh

# テスト
.PHONY: test
test:
	@echo "Running tests..."
	@if [ -d "tests" ]; then \
		bats tests/; \
	else \
		echo "tests/ ディレクトリがありません"; \
	fi

# シェルスクリプトのlint
.PHONY: lint
lint:
	@echo "Running shellcheck..."
	@find . -name "*.sh" -not -path "./.git/*" | xargs shellcheck || true

# クリーン（バックアップファイル削除）
.PHONY: clean
clean:
	@find . -name "*.backup.*" -delete
	@find . -name "*~" -delete
	@echo "✓ バックアップファイルを削除しました"
