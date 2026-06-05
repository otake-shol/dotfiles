# dotfiles Makefile - GNU Stowベースのシンボリックリンク管理

SHELL := /bin/bash

STOW := stow
STOW_DIR := stow
# パッケージごとの除外は stow/<pkg>/.stow-local-ignore に分離。
# CLI --ignore は basename 末尾マッチのため、ここではsafety netとして basename のみ指定。
STOW_IGNORE_FLAGS := --ignore='\.p10k\.zsh$$' --ignore='installation_id$$'
STOW_COMMON_FLAGS := -v --target=$(HOME) --dir=$(STOW_DIR) $(STOW_IGNORE_FLAGS)
STOW_INSTALL_FLAGS := $(STOW_COMMON_FLAGS) --restow
STOW_DELETE_FLAGS := $(STOW_COMMON_FLAGS)
STOW_SIMULATE_FLAGS := --target=$(HOME) --dir=$(STOW_DIR) $(STOW_IGNORE_FLAGS)
PACKAGES := zsh git nvim ghostty bat atuin claude codex yazi direnv cmux asdf ssh
TOOL_VERSIONS := stow/asdf/.tool-versions
DOCTOR_LINK_DIRS := "$$HOME" "$$HOME/.config" "$$HOME/.claude" "$$HOME/.codex" "$$HOME/.docker" "$$HOME/.gnupg" "$$HOME/Library/Application Support/com.mitchellh.ghostty" "$$HOME/Library/LaunchAgents"
SNAPSHOT_DIR := .snapshot/$(shell date +%Y%m%d-%H%M%S)

.PHONY: help install uninstall check check-strict check-conflicts bootstrap lint clean install-% uninstall-% packages stats readme-check readme-sync runtimes-install versions-audit doctor doctor-plan doctor-clean-broken setup-fastlane-env validate snapshot new-mac macos-defaults

help:
	@echo "Usage:"
	@echo "  make install          全パッケージをインストール"
	@echo "  make uninstall        全パッケージをアンインストール"
	@echo "  make install-PKG      個別インストール (例: make install-zsh)"
	@echo "  make check            Stowドライラン"
	@echo "  make check-strict     Stowドライラン（差分・競合で失敗）"
	@echo "  make check-conflicts  Stowドライラン（競合のみ失敗、CI向け）"
	@echo "  make doctor           シンボリックリンク健全性チェック"
	@echo "  make doctor-plan      修復候補を表示（変更なし）"
	@echo "  make bootstrap        完全セットアップ"
	@echo "  make lint             ShellCheck"
	@echo "  make clean            バックアップファイル削除"
	@echo "  make stats            パッケージ数を表示"
	@echo "  make readme-check     README内の件数が実体と一致するか確認"
	@echo "  make readme-sync      README内の件数を実体に合わせて自動更新"
	@echo "  make runtimes-install asdf plugin/runtime を .tool-versions から導入"
	@echo "  make versions-audit   .tool-versions の固定バージョン確認"
	@echo "  make setup-fastlane-env  fastlane用環境変数を対話的にセットアップ"
	@echo "  make validate         移行可能性を機械検証（lint+readme+stow+toml+json+絶対パス）"
	@echo "  make snapshot         現PCの状態を .snapshot/<ts>/ に記録（移行前の証拠）"
	@echo "  make new-mac          新PC移行ガイドを表示"
	@echo "  make macos-defaults   macOS defaults を再適用"
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

check-conflicts:
	@for pkg in $(PACKAGES); do \
		echo "=== $$pkg ==="; \
		output=$$($(STOW) --simulate $(STOW_INSTALL_FLAGS) $$pkg 2>&1) || { \
			printf "%s\n" "$$output"; \
			exit 1; \
		}; \
	done

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
	broken=$$(for d in $(DOCTOR_LINK_DIRS); do \
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

macos-defaults:
	@bash ./bin/apply-macos-defaults

validate: lint readme-check
	@if [ "$${CI:-}" = "true" ]; then \
	  $(MAKE) check-conflicts; \
	else \
	  $(MAKE) check-strict; \
	fi
	@echo "▶ TOML 構文チェック"
	@git ls-files stow | grep -E '\.toml$$' \
	  | xargs -I{} python3 -c 'import tomllib,sys; tomllib.load(open(sys.argv[1],"rb"))' {} \
	  && echo "  ✓ TOML"
	@echo "▶ JSON 構文チェック"
	@git ls-files stow | grep -E '\.json$$' \
	  | xargs -I{} python3 -c 'import json,sys; json.load(open(sys.argv[1]))' {} \
	  && echo "  ✓ JSON"
	@echo "▶ .mjs 構文チェック"
	@if command -v node >/dev/null 2>&1; then \
	  files=$$(git ls-files stow | grep -E '\.mjs$$'); \
	  if [ -n "$$files" ]; then \
	    echo "$$files" | xargs node --check && echo "  ✓ Node syntax"; \
	  else \
	    echo "  ✓ Node syntax (対象なし)"; \
	  fi \
	else \
	  echo "  ⚠ node 未導入（スキップ）"; \
	fi
	@echo "▶ 絶対パス混入チェック（ユーザー名依存）"
	@hits=$$( { git ls-files stow \
	     | grep -E '\.(toml|json|zsh|sh|mjs|lua|txt|cfg|conf)$$' \
	     | xargs -I{} grep -Hn "/Users/[a-zA-Z0-9_-]\+" {} 2>/dev/null; \
	   grep -n "/Users/[a-zA-Z0-9_-]\+" bootstrap.sh bin/* 2>/dev/null \
	     | sed -E 's|^([^:]+:[0-9]+:)|\1|'; \
	 } | grep -vE '(/\.template$$|^[^:]*\.template:|^[^:]*\.example:|stow/codex/\.codex/config\.toml:[0-9]+:\[(projects|hooks\.state)\.)' || true); \
	if [ -n "$$hits" ]; then \
	  printf '%s\n' "$$hits"; \
	  echo "  ✗ 絶対パスが残存（新PCで壊れる）"; exit 1; \
	else \
	  echo "  ✓ 絶対パスなし（stow/, bootstrap.sh, bin/）"; \
	fi
	@echo "▶ Codex local-state 混入チェック"
	@if git ls-files stow/codex/.codex 2>/dev/null \
	    | grep -E '(^|/)(installation_id|auth\.json|history\.jsonl|.*\.sqlite([^/]*)?)$$' \
	    | grep -q .; then \
	  echo "  ✗ local stateがStow対象に混入（git管理下）"; exit 1; \
	else \
	  echo "  ✓ local stateなし"; \
	fi
	@if [ "$${CI:-}" = "true" ]; then \
	  echo "▶ doctor はCIの空HOMEではスキップ（Stow競合はcheck-conflictsで検証済み）"; \
	else \
	  $(MAKE) doctor; \
	fi
	@echo ""
	@printf "\033[32m✓ validate pass（リポジトリは新PCに移植可能）\033[0m\n"

snapshot:
	@mkdir -p $(SNAPSHOT_DIR)
	@echo "▶ 現PC状態をスナップショット: $(SNAPSHOT_DIR)"
	@if command -v brew >/dev/null 2>&1; then \
	  brew bundle dump --file=$(SNAPSHOT_DIR)/Brewfile.actual --force --describe 2>/dev/null \
	    && echo "  ✓ Brewfile.actual" || echo "  ⚠ brew bundle dump 失敗"; \
	else echo "  - brew 未導入"; fi
	@if command -v asdf >/dev/null 2>&1; then \
	  asdf current > $(SNAPSHOT_DIR)/asdf-current.txt 2>/dev/null \
	    && echo "  ✓ asdf-current"; \
	else echo "  - asdf 未導入"; fi
	@if command -v claude >/dev/null 2>&1; then \
	  claude mcp list > $(SNAPSHOT_DIR)/claude-mcp.txt 2>/dev/null \
	    && echo "  ✓ claude-mcp"; \
	else echo "  - claude 未導入"; fi
	@if command -v gh >/dev/null 2>&1; then \
	  gh auth status > $(SNAPSHOT_DIR)/gh-auth.txt 2>&1 \
	    && echo "  ✓ gh-auth" || echo "  ⚠ gh 未ログイン"; \
	else echo "  - gh 未導入"; fi
	@if [ -d "$$HOME/.appstoreconnect" ]; then \
	  ls -la "$$HOME/.appstoreconnect/" > $(SNAPSHOT_DIR)/appstoreconnect.txt 2>/dev/null \
	    && echo "  ✓ asc-keys"; \
	else echo "  - ASC keys なし"; fi
	@defaults read NSGlobalDomain > $(SNAPSHOT_DIR)/defaults-global.txt 2>/dev/null \
	  && echo "  ✓ defaults-global" || echo "  - defaults 取得失敗"
	@if [ -f $(SNAPSHOT_DIR)/Brewfile.actual ]; then \
	  diff -u Brewfile $(SNAPSHOT_DIR)/Brewfile.actual > $(SNAPSHOT_DIR)/Brewfile.drift 2>/dev/null || true; \
	  if [ -s $(SNAPSHOT_DIR)/Brewfile.drift ]; then \
	    echo "  ⚠ Brewfileドリフトあり: $(SNAPSHOT_DIR)/Brewfile.drift"; \
	  else \
	    echo "  ✓ Brewfile と実環境一致"; \
	    rm -f $(SNAPSHOT_DIR)/Brewfile.drift; \
	  fi; \
	fi
	@echo ""
	@printf "\033[32m✓ snapshot 完了: %s\033[0m\n" "$(SNAPSHOT_DIR)"

new-mac:
	@printf '%s\n' \
	  "▶ 新PC移行手順（順番に実行）" \
	  "" \
	  "  1. xcode-select --install" \
	  "  2. bash bootstrap.sh -y                       # Brewfile + Stow + macOS設定" \
	  "  3. make doctor                                # Stow健全性" \
	  "  4. make validate                              # リポジトリ整合性" \
	  "  5. make runtimes-install                      # asdf runtime（必要時のみ）" \
	  "  6. make setup-fastlane-env                    # ASC使う場合" \
	  "" \
	  "▶ 手動セットアップ（dotfiles外）" \
	  "" \
	  "  - App Store で Xcode をインストール（fastlane / iOS開発で必須）" \
	  "  - 1Password ログイン → SSH鍵 / GPG鍵 / .p8 を ~/.ssh, ~/.gnupg, ~/.appstoreconnect/ に配置" \
	  "  - gh auth login" \
	  "  - claude login" \
	  "  - codex login" \
	  "  - p10k configure                              # プロンプト初期化" \
	  "" \
	  "▶ 移行直後の確認" \
	  "" \
	  "  - 旧PCで事前に make snapshot → .snapshot/<ts>/ を新PCにコピー" \
	  "  - 新PCで make snapshot → 旧PCの .snapshot/ と diff して欠落確認" \
	  ""

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
	for d in $(DOCTOR_LINK_DIRS); do \
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
	@for d in $(DOCTOR_LINK_DIRS); do \
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

SHELLCHECK_TARGETS := bootstrap.sh \
	bin/setup-fastlane-env bin/apply-macos-defaults \
	$(wildcard stow/claude/.claude/hooks/*.sh) \
	$(wildcard stow/codex/.codex/hooks/*.sh) \
	$(wildcard stow/codex/.codex/bin/*.sh)

lint:
	@shellcheck -S warning $(SHELLCHECK_TARGETS)
	@if command -v node >/dev/null 2>&1; then \
		node --check stow/codex/.codex/bin/*.mjs; \
	else \
		echo "node not found; skipping .mjs syntax check"; \
	fi

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
	alias_count=$$(awk '/^alias /{count++} END{print count+0}' stow/zsh/.zsh/aliases/core.zsh); \
	claude_command_count=$$(find stow/claude/.claude/commands -maxdepth 1 -name '*.md' | wc -l | tr -d ' '); \
	error=0; \
	grep -qE "GNU Stowパッケージ（$${pkg_count}個）" README.md || { echo "READMEのStowパッケージ数が不一致: $$pkg_count (修復: make readme-sync)"; error=1; }; \
	grep -qE "Brewfile $${brew_total}パッケージ" README.md || { echo "READMEのBrewfile件数が不一致: $$brew_total (修復: make readme-sync)"; error=1; }; \
	grep -qE "遅延読み込み・$${alias_count}エイリアス・" README.md || { echo "READMEのzshエイリアス数が不一致: $$alias_count (修復: make readme-sync)"; error=1; }; \
	grep -qE "hookスクリプト・$${claude_command_count}コマンド・" README.md || { echo "READMEのClaudeコマンド数が不一致: $$claude_command_count (修復: make readme-sync)"; error=1; }; \
	exit $$error

readme-sync:
	@pkg_count=$$(printf "%s\n" $(PACKAGES) | wc -l | tr -d ' '); \
	brew_count=$$(awk '/^[[:space:]]*brew /{count++} END{print count+0}' Brewfile); \
	cask_count=$$(awk '/^[[:space:]]*cask /{count++} END{print count+0}' Brewfile); \
	brew_total=$$((brew_count + cask_count)); \
	alias_count=$$(awk '/^alias /{count++} END{print count+0}' stow/zsh/.zsh/aliases/core.zsh); \
	claude_command_count=$$(find stow/claude/.claude/commands -maxdepth 1 -name '*.md' | wc -l | tr -d ' '); \
	uname_s=$$(uname -s); \
	if [ "$$uname_s" = "Darwin" ]; then sed_i=(-i ''); else sed_i=(-i); fi; \
	sed "$${sed_i[@]}" -E "s/GNU Stowパッケージ（[0-9]+個）/GNU Stowパッケージ（$${pkg_count}個）/g" README.md; \
	sed "$${sed_i[@]}" -E "s/Brewfile [0-9]+パッケージ/Brewfile $${brew_total}パッケージ/g" README.md; \
	sed "$${sed_i[@]}" -E "s/遅延読み込み・[0-9]+エイリアス・/遅延読み込み・$${alias_count}エイリアス・/g" README.md; \
	sed "$${sed_i[@]}" -E "s/hookスクリプト・[0-9]+コマンド・/hookスクリプト・$${claude_command_count}コマンド・/g" README.md; \
	printf "stow=%s brew_total=%s alias=%s claude_cmd=%s に同期しました\n" "$$pkg_count" "$$brew_total" "$$alias_count" "$$claude_command_count"

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

