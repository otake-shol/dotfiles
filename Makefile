# dotfiles Makefile - GNU Stowベースのシンボリックリンク管理

STOW := stow
STOW_DIR := stow
STOW_FLAGS := -v --target=$(HOME) --dir=$(STOW_DIR) --restow
PACKAGES := zsh git nvim ghostty bat atuin claude gh yazi ripgrep direnv cmux

.PHONY: help install uninstall check bootstrap lint health brewsync clean install-% uninstall-%

help:
	@echo "Usage:"
	@echo "  make install          全パッケージをインストール"
	@echo "  make uninstall        全パッケージをアンインストール"
	@echo "  make install-PKG      個別インストール (例: make install-zsh)"
	@echo "  make check            Stowドライラン"
	@echo "  make bootstrap        完全セットアップ"
	@echo "  make lint             ShellCheck"
	@echo "  make health           lint + check + verify"
	@echo "  make brewsync         Brewfile同期チェック"
	@echo "  make clean            バックアップファイル削除"
	@echo ""
	@echo "Packages: $(PACKAGES)"

install: $(addprefix install-,$(PACKAGES))
	@echo "✓ 全パッケージをインストールしました"

uninstall: $(addprefix uninstall-,$(PACKAGES))
	@echo "✓ 全パッケージをアンインストールしました"

install-%:
	@if [ -d "$(STOW_DIR)/$*" ]; then \
		$(STOW) $(STOW_FLAGS) $*; \
	else \
		echo "⚠ $(STOW_DIR)/$* が見つかりません"; \
	fi

uninstall-%:
	@[ -d "$(STOW_DIR)/$*" ] && $(STOW) -D $(STOW_FLAGS) $* || true

check:
	@for pkg in $(PACKAGES); do \
		echo "=== $$pkg ==="; \
		$(STOW) --simulate $(STOW_FLAGS) $$pkg 2>&1 || true; \
	done

bootstrap:
	bash bootstrap.sh

lint:
	@shellcheck -S warning bootstrap.sh
	@find scripts -name '*.sh' -exec shellcheck -S warning {} +

health: lint check
	@bash scripts/maintenance/verify-setup.sh

brewsync:
	@bash scripts/maintenance/sync-brewfile.sh

clean:
	@find . -name "*.backup.*" -delete
	@find . -name "*~" -delete
	@echo "✓ クリーンアップ完了"
