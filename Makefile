# dotfiles Makefile - GNU Stowベースのシンボリックリンク管理

SHELL := /bin/bash

STOW := stow
STOW_DIR := stow
STOW_FLAGS := -v --target=$(HOME) --dir=$(STOW_DIR) --restow
PACKAGES := zsh git nvim ghostty bat atuin claude yazi direnv cmux asdf cursor
CURSOR_EXT_LIST := stow/cursor/.config/cursor/extensions.txt

.PHONY: help install uninstall check bootstrap lint clean install-% uninstall-% packages cursor-sync cursor-diff

help:
	@echo "Usage:"
	@echo "  make install          全パッケージをインストール"
	@echo "  make uninstall        全パッケージをアンインストール"
	@echo "  make install-PKG      個別インストール (例: make install-zsh)"
	@echo "  make check            Stowドライラン"
	@echo "  make bootstrap        完全セットアップ"
	@echo "  make lint             ShellCheck"
	@echo "  make clean            バックアップファイル削除"
	@echo "  make cursor-sync      Cursor拡張を extensions.txt に同期"
	@echo "  make cursor-diff      現状とリストの差分を表示（変更なし）"
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
	@shellcheck -S warning stow/claude/.claude/hooks/*.sh

clean:
	@find . -name "*.backup.*" -delete
	@find . -name "*~" -delete
	@find . -name ".DS_Store" -delete
	@echo "✓ クリーンアップ完了"

packages:
	@echo $(PACKAGES)

cursor-diff:
	@command -v cursor >/dev/null 2>&1 || { echo "❌ cursor CLI not found"; exit 1; }
	@desired=$$(grep -vE '^[[:space:]]*(#|$$)' $(CURSOR_EXT_LIST) | tr '[:upper:]' '[:lower:]' | sort -u); \
	 current=$$(cursor --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]' | sort -u); \
	 echo "=== 追加予定 (リストにあるが未インストール) ==="; \
	 comm -23 <(echo "$$desired") <(echo "$$current") | sed 's/^/  + /'; \
	 echo "=== 削除予定 (インストール済みだがリスト外) ==="; \
	 comm -13 <(echo "$$desired") <(echo "$$current") | sed 's/^/  - /'

cursor-sync:
	@command -v cursor >/dev/null 2>&1 || { echo "❌ cursor CLI not found"; exit 1; }
	@echo "▶ Cursor拡張を同期中..."
	@desired=$$(grep -vE '^[[:space:]]*(#|$$)' $(CURSOR_EXT_LIST) | tr '[:upper:]' '[:lower:]' | sort -u); \
	 current=$$(cursor --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]' | sort -u); \
	 to_install=$$(comm -23 <(echo "$$desired") <(echo "$$current")); \
	 to_remove=$$(comm -13 <(echo "$$desired") <(echo "$$current")); \
	 for ext in $$to_install; do echo "  + $$ext"; cursor --install-extension "$$ext" >/dev/null; done; \
	 for ext in $$to_remove; do echo "  - $$ext"; cursor --uninstall-extension "$$ext" >/dev/null; done
	@echo "✓ 同期完了 ($$(cursor --list-extensions 2>/dev/null | wc -l | tr -d ' ') extensions installed)"
