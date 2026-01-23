#!/usr/bin/env bats
# performance.bats - zsh起動時間ベンチマーク

load 'test_helper'

# 起動時間ベンチマーク (500ms以下を目標)
@test "zsh startup time is under 500ms" {
    if ! command -v zsh &>/dev/null; then
        skip "zsh not installed"
    fi

    # CI環境または依存関係がない場合はスキップ
    if [[ "$CI" = "true" ]] && [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        skip "Oh My Zsh not installed in CI environment"
    fi

    # 実際のホームディレクトリでテスト（設定が必要）
    if [[ ! -f "$HOME/.zshrc" ]]; then
        skip ".zshrc not found in home directory"
    fi

    # 5回測定して平均を取る
    total_time=0
    iterations=5

    for i in $(seq 1 $iterations); do
        # /usr/bin/time を使用してzsh起動時間を測定
        if [[ "$(uname)" == "Darwin" ]]; then
            # macOS
            start_time=$(gdate +%s%N 2>/dev/null || date +%s)
            zsh -i -c 'exit' 2>/dev/null
            end_time=$(gdate +%s%N 2>/dev/null || date +%s)

            if command -v gdate &>/dev/null; then
                elapsed=$(( (end_time - start_time) / 1000000 ))
            else
                elapsed=0  # gdate がない場合はスキップ
                skip "gdate not installed for accurate timing on macOS"
            fi
        else
            # Linux
            start_time=$(date +%s%N)
            zsh -i -c 'exit' 2>/dev/null
            end_time=$(date +%s%N)
            elapsed=$(( (end_time - start_time) / 1000000 ))
        fi

        total_time=$((total_time + elapsed))
    done

    avg_time=$((total_time / iterations))
    echo "Average startup time: ${avg_time}ms"

    # 500ms以下であることを確認
    [ "$avg_time" -lt 500 ]
}

# ベンチマークスクリプトの存在確認
@test "zsh-benchmark.sh script exists" {
    assert_file_exists "$DOTFILES_ROOT/scripts/utils/zsh-benchmark.sh"
}

# ベンチマークスクリプトの構文チェック
@test "zsh-benchmark.sh has valid bash syntax" {
    run bash -n "$DOTFILES_ROOT/scripts/utils/zsh-benchmark.sh"
    [ "$status" -eq 0 ]
}

# .zshrcが最適化設定を含むこと
@test ".zshrc uses plugin caching for performance" {
    grep -q '_plugin_cache' "$DOTFILES_ROOT/.zshrc"
}

@test ".zshrc uses conditional plugin loading" {
    grep -q '$+commands' "$DOTFILES_ROOT/.zshrc"
}

@test ".zshrc has p10k instant prompt" {
    grep -q 'p10k-instant-prompt' "$DOTFILES_ROOT/.zshrc"
}

# 遅延読み込み関連
@test ".zshrc supports minimal profile for fast startup" {
    grep -q 'DOTFILES_MINIMAL' "$DOTFILES_ROOT/.zshrc"
}

@test "minimal profile skips heavy tools" {
    if [ -f "$DOTFILES_ROOT/profiles/minimal.zsh" ]; then
        grep -q 'DOTFILES_MINIMAL=true' "$DOTFILES_ROOT/profiles/minimal.zsh"
    else
        skip "minimal.zsh profile not found"
    fi
}

# プロファイリング機能
@test ".zshrc has commented zprof for profiling" {
    grep -q 'zmodload zsh/zprof' "$DOTFILES_ROOT/.zshrc"
}

# ファイルサイズチェック（大きすぎないこと）
@test ".zshrc file size is reasonable (under 20KB)" {
    size=$(wc -c < "$DOTFILES_ROOT/.zshrc")
    [ "$size" -lt 20480 ]
}

@test ".aliases file size is reasonable (under 10KB)" {
    if [ -f "$DOTFILES_ROOT/.aliases" ]; then
        size=$(wc -c < "$DOTFILES_ROOT/.aliases")
        [ "$size" -lt 10240 ]
    else
        skip ".aliases not found"
    fi
}
