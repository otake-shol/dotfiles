# dotfiles Makefile - GNU Stowベースのシンボリックリンク管理

SHELL := /bin/bash

STOW := stow
STOW_DIR := stow
STOW_COMMON_FLAGS := -v --target=$(HOME) --dir=$(STOW_DIR)
STOW_INSTALL_FLAGS := $(STOW_COMMON_FLAGS) --restow
STOW_DELETE_FLAGS := $(STOW_COMMON_FLAGS)
STOW_SIMULATE_FLAGS := --target=$(HOME) --dir=$(STOW_DIR)
PACKAGES := zsh git nvim ghostty bat atuin claude codex yazi direnv cmux asdf cursor
CURSOR_EXT_LIST := stow/cursor/.config/cursor/extensions.txt
TOOL_VERSIONS := stow/asdf/.tool-versions

.PHONY: help install uninstall check check-strict bootstrap lint clean install-% uninstall-% packages stats readme-check runtimes-install versions-audit cursor-sync cursor-diff doctor doctor-plan doctor-clean-broken setup-fastlane-env

help:
	@echo "Usage:"
	@echo "  make install          全パッケージをインストール"
	@echo "  make uninstall        全パッケージをアンインストール"
	@echo "  make install-PKG      個別インストール (例: make install-zsh)"
	@echo "  make check            Stowドライラン"
	@echo "  make check-strict     Stowドライラン（差分・競合で失敗）"
	@echo "  make doctor           シンボリックリンク健全性チェック"
	@echo "  make doctor-plan      修復候補を表示（変更なし）"
	@echo "  make bootstrap        完全セットアップ"
	@echo "  make lint             ShellCheck"
	@echo "  make clean            バックアップファイル削除"
	@echo "  make stats            パッケージ数を表示"
	@echo "  make readme-check     README内の件数が実体と一致するか確認"
	@echo "  make runtimes-install asdf plugin/runtime を .tool-versions から導入"
	@echo "  make versions-audit   .tool-versions の固定バージョン確認"
	@echo "  make cursor-sync      Cursor拡張を extensions.txt に同期"
	@echo "  make cursor-diff      現状とリストの差分を表示（変更なし）"
	@echo "  make setup-fastlane-env  fastlane用環境変数を対話的にセットアップ"
	@echo ""
	@echo "Packages: $(PACKAGES)"

install: $(addprefix install-,$(PACKAGES))
	@echo "✓ 全パッケージをインストールしました"

uninstall: $(addprefix uninstall-,$(PACKAGES))
	@echo "✓ 全パッケージをアンインストールしました"

install-%:
	@if [ -d "$(STOW_DIR)/$*" ]; then \
		$(STOW) $(STOW_INSTALL_FLAGS) $*; \
	else \
		echo "⚠ $(STOW_DIR)/$* が見つかりません"; \
	fi

uninstall-%:
	@[ -d "$(STOW_DIR)/$*" ] && $(STOW) -D $(STOW_DELETE_FLAGS) $* || true

check:
	@for pkg in $(PACKAGES); do \
		echo "=== $$pkg ==="; \
		$(STOW) --simulate $(STOW_INSTALL_FLAGS) $$pkg 2>&1 || true; \
	done

check-strict:
	@error=0; \
	for pkg in $(PACKAGES); do \
		echo "=== $$pkg ==="; \
		output=$$($(STOW) --simulate -v $(STOW_SIMULATE_FLAGS) $$pkg 2>&1 || true); \
		diff=$$(printf "%s\n" "$$output" | grep -vE "^WARNING: in simulation|^$$" || true); \
		if [ -n "$$diff" ]; then \
			printf "%s\n" "$$diff"; \
			error=1; \
		fi; \
	done; \
	exit $$error

doctor:
	@error=0; \
	echo "▶ Stow 同期状態"; \
	for pkg in $(PACKAGES); do \
		if [ ! -d "$(STOW_DIR)/$$pkg" ]; then \
			printf "  \033[31m✗\033[0m %s (パッケージディレクトリ無し)\n" "$$pkg"; error=1; continue; \
		fi; \
		diff=$$($(STOW) --simulate -v $(STOW_SIMULATE_FLAGS) $$pkg 2>&1 \
			| grep -vE "^WARNING: in simulation|^$$" || true); \
		if [ -z "$$diff" ]; then \
			printf "  \033[32m✓\033[0m %s\n" "$$pkg"; \
		else \
			printf "  \033[33m⚠\033[0m %s 未同期 (修復: make install-%s)\n" "$$pkg" "$$pkg"; \
			error=1; \
		fi; \
	done; \
	echo ""; \
	echo "▶ \$$HOME 配下の壊れたシンボリックリンク (dotfiles 由来のみ)"; \
	broken=$$(for d in "$$HOME" "$$HOME/.config" "$$HOME/.claude" "$$HOME/.codex"; do \
		find "$$d" -maxdepth 4 -type l 2>/dev/null; \
	done | sort -u | while read -r l; do \
		[ -e "$$l" ] && continue; \
		readlink "$$l" 2>/dev/null | grep -q dotfiles && echo "$$l"; \
	done); \
	if [ -z "$$broken" ]; then \
		printf "  \033[32m✓\033[0m 壊れたリンクなし\n"; \
	else \
		echo "$$broken" | sed 's|^|  ✗ |'; error=1; \
	fi; \
	echo ""; \
	echo "▶ fastlane env 設定（任意。警告のみ、doctor判定には影響しない）"; \
	env_file="$$HOME/.config/fastlane/env"; \
	if [ ! -f "$$env_file" ]; then \
		printf "  \033[33m⚠\033[0m %s 未作成 (修復: make setup-fastlane-env)\n" "$$env_file"; \
	elif grep -qE '"<[^"]+>"' "$$env_file"; then \
		count=$$(grep -cE '"<[^"]+>"' "$$env_file"); \
		printf "  \033[33m⚠\033[0m %s にプレースホルダー残 %s個 (修復: make setup-fastlane-env)\n" "$$env_file" "$$count"; \
	else \
		printf "  \033[32m✓\033[0m %s\n" "$$env_file"; \
	fi; \
	echo ""; \
	if [ $$error -eq 0 ]; then \
		printf "\033[32m✓ doctor pass\033[0m\n"; \
	else \
		printf "\033[31m✗ doctor fail\033[0m\n"; exit 1; \
	fi

setup-fastlane-env:
	@bash ./bin/setup-fastlane-env

doctor-plan:
	@echo "▶ Stow 修復候補（変更なし）"; \
	for pkg in $(PACKAGES); do \
		diff=$$($(STOW) --simulate -v $(STOW_SIMULATE_FLAGS) $$pkg 2>&1 \
			| grep -vE "^WARNING: in simulation|^$$" || true); \
		if [ -n "$$diff" ]; then \
			printf "\n=== %s ===\n" "$$pkg"; \
			printf "%s\n" "$$diff"; \
			printf "修復候補: make install-%s\n" "$$pkg"; \
		fi; \
	done; \
	echo ""; \
	echo "▶ 壊れた dotfiles 由来リンク（削除は手動確認）"; \
	for d in "$$HOME" "$$HOME/.config" "$$HOME/.claude" "$$HOME/.codex" "$$HOME/.docker" "$$HOME/.gnupg" "$$HOME/Library/Application Support/com.mitchellh.ghostty" "$$HOME/Library/LaunchAgents"; do \
		find "$$d" -maxdepth 4 -type l 2>/dev/null; \
	done | sort -u | while read -r l; do \
		[ -e "$$l" ] && continue; \
		target=$$(readlink "$$l" 2>/dev/null || true); \
		printf "%s" "$$target" | grep -q dotfiles || continue; \
		printf "  %s -> %s\n" "$$l" "$$target"; \
	done

doctor-clean-broken:
	@if [ "$${CONFIRM:-}" != "delete-broken-links" ]; then \
		echo "壊れた dotfiles 由来リンクを削除するには CONFIRM=delete-broken-links を付けてください"; \
		echo "例: make doctor-clean-broken CONFIRM=delete-broken-links"; \
		exit 2; \
	fi
	@for d in "$$HOME" "$$HOME/.config" "$$HOME/.claude" "$$HOME/.codex" "$$HOME/.docker" "$$HOME/.gnupg" "$$HOME/Library/Application Support/com.mitchellh.ghostty" "$$HOME/Library/LaunchAgents"; do \
		find "$$d" -maxdepth 4 -type l 2>/dev/null; \
	done | sort -u | while read -r l; do \
		[ -e "$$l" ] && continue; \
		target=$$(readlink "$$l" 2>/dev/null || true); \
		printf "%s" "$$target" | grep -q dotfiles || continue; \
		printf "delete %s -> %s\n" "$$l" "$$target"; \
		rm -- "$$l"; \
	done

bootstrap:
	bash bootstrap.sh

lint:
	@shellcheck -S warning bootstrap.sh
	@shellcheck -S warning stow/claude/.claude/hooks/*.sh
	@shellcheck -S warning stow/codex/.codex/hooks/*.sh
	@shellcheck -S warning stow/codex/.codex/bin/*.sh

clean:
	@find . -name "*.backup.*" -delete
	@find . -name "*~" -delete
	@find . -name ".DS_Store" -delete
	@echo "✓ クリーンアップ完了"

packages:
	@echo $(PACKAGES)

stats:
	@pkg_count=$$(printf "%s\n" $(PACKAGES) | wc -l | tr -d ' '); \
	brew_count=$$(awk '/^[[:space:]]*brew /{count++} END{print count+0}' Brewfile); \
	cask_count=$$(awk '/^[[:space:]]*cask /{count++} END{print count+0}' Brewfile); \
	printf "stow packages: %s\n" "$$pkg_count"; \
	printf "brew formulae: %s\n" "$$brew_count"; \
	printf "brew casks: %s\n" "$$cask_count"; \
	printf "brew total: %s\n" "$$((brew_count + cask_count))"

readme-check:
	@pkg_count=$$(printf "%s\n" $(PACKAGES) | wc -l | tr -d ' '); \
	brew_count=$$(awk '/^[[:space:]]*brew /{count++} END{print count+0}' Brewfile); \
	cask_count=$$(awk '/^[[:space:]]*cask /{count++} END{print count+0}' Brewfile); \
	brew_total=$$((brew_count + cask_count)); \
	error=0; \
	grep -q "GNU Stowパッケージ（$${pkg_count}個）" README.md || { echo "READMEのStowパッケージ数が不一致: $$pkg_count"; error=1; }; \
	grep -q "Brewfile $${brew_total}パッケージ" README.md || { echo "READMEのBrewfile件数が不一致: $$brew_total"; error=1; }; \
	exit $$error

runtimes-install:
	@if ! command -v asdf >/dev/null 2>&1; then echo "asdf not found"; exit 1; fi
	@if [ ! -f "$(TOOL_VERSIONS)" ]; then echo "$(TOOL_VERSIONS) が見つかりません"; exit 1; fi
	@while read -r tool version _; do \
		[ -z "$$tool" ] && continue; \
		case "$$tool" in \#*) continue ;; esac; \
		if ! asdf plugin list 2>/dev/null | grep -qx "$$tool"; then \
			printf "plugin add %s\n" "$$tool"; \
			asdf plugin add "$$tool"; \
		fi; \
		printf "install %s %s\n" "$$tool" "$$version"; \
		asdf install "$$tool" "$$version"; \
	done < "$(TOOL_VERSIONS)"

versions-audit:
	@tool_versions="$(TOOL_VERSIONS)"; \
	if [ ! -f "$$tool_versions" ]; then echo "$$tool_versions が見つかりません"; exit 1; fi; \
	if ! command -v asdf >/dev/null 2>&1; then echo "asdf not found"; exit 1; fi; \
	while read -r tool version _; do \
		[ -z "$$tool" ] && continue; \
		case "$$tool" in \#*) continue ;; esac; \
		latest=$$(asdf latest "$$tool" 2>/dev/null || true); \
		case "$$latest" in "No compatible versions available"*|"No versions available"*) latest="" ;; esac; \
		if [ -n "$$latest" ] && [ "$$latest" != "$$version" ]; then \
			printf "  ⚠ %s pinned=%s latest=%s\n" "$$tool" "$$version" "$$latest"; \
		elif [ -z "$$latest" ]; then \
			printf "  ? %s pinned=%s latest=unknown\n" "$$tool" "$$version"; \
		else \
			printf "  ✓ %s pinned=%s\n" "$$tool" "$$version"; \
		fi; \
	done < "$$tool_versions"

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
