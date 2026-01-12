# Oh My Zsh + Powerlevel10k セットアップガイド

参考: https://zenn.dev/collabostyle/articles/6d668b46627d64

## Step 1: Oh My Zshのインストール

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

実行後、`~/.zshrc` が自動生成される。

## Step 2: Powerlevel10kの導入

### 2-1. フォントのインストール

Powerlevel10kの正しい表示にはNerd Font対応フォントが必要。

1. [Nerd Fonts Releases](https://github.com/ryanoasis/nerd-fonts/releases/latest) にアクセス
2. Assetsから `Meslo.zip` をダウンロード
3. 解凍して以下の4つのフォントをインストール:
   - MesloLGSNerdFont-Regular.ttf
   - MesloLGSNerdFont-Bold.ttf
   - MesloLGSNerdFont-Italic.ttf
   - MesloLGSNerdFont-BoldItalic.ttf
4. ターミナルのフォント設定を「MesloLGS Nerd Font」に変更

### 2-2. Powerlevel10kのインストール

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### 2-3. テーマの設定

`~/.zshrc` を編集:

```zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
```

ターミナルを再起動するとセットアップウィザードが起動する。

## Step 3: プラグインの追加

### 3-1. プラグインのインストール

```bash
# zsh-autosuggestions（コマンド履歴から自動補完）
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting（コマンドの色分け表示）
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 3-2. プラグインの有効化

`~/.zshrc` の `plugins` を編集:

```zsh
plugins=(
  git
  z
  colored-man-pages
  zsh-autosuggestions
  zsh-syntax-highlighting
)
```

### プラグインの説明

| プラグイン | 説明 |
|-----------|------|
| git | Gitの補完とエイリアス |
| z | よく使うディレクトリへの高速移動 |
| colored-man-pages | manページのカラー表示 |
| zsh-autosuggestions | 過去のコマンド履歴から自動補完を提案 |
| zsh-syntax-highlighting | 入力中のコマンドを色分け表示 |

## 設定の反映

```bash
source ~/.zshrc
```

または新しいターミナルを開く。
