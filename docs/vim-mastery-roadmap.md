# Vim マスターへの道 - 入門から達人まで

## なぜVimを学ぶのか

- **速度**: マウス不要でテキスト編集が飛躍的に高速化
- **どこでも使える**: SSH接続先、サーバー、コンテナ内で即座に編集可能
- **エルゴノミクス**: ホームポジションから手を動かさない
- **思考の言語**: 「単語を削除」→ `dw` のように意図をコマンド化
- **長寿命**: 1991年リリース以降、今も進化し続ける

---

## Part 1: Vim関連ツール

### 1.1 練習・学習ツール

| ツール | 種類 | URL | 特徴 |
|--------|------|-----|------|
| **vimtutor** | CLI | `vimtutor` コマンド | 公式チュートリアル、30分で基礎習得 |
| **OpenVim** | Web | [openvim.com](https://openvim.com/) | インタラクティブな入門チュートリアル |
| **VIM Adventures** | ゲーム | [vim-adventures.com](https://vim-adventures.com/) | ゼルダ風RPGでVim操作を学ぶ |
| **Vim Racer** | ゲーム | [vim-racer.com](https://vim-racer.com/) | タイピングテスト形式、リーダーボード付き |
| **VimGenius** | Web | [vimgenius.com](http://www.vimgenius.com/) | フラッシュカード形式のタイムアタック |
| **VimHero** | Web | [vim-hero.com](https://www.vim-hero.com/) | インタラクティブなチャレンジ形式 |
| **Vimified** | Web | [vimified.com](https://www.vimified.com/) | 小さなレッスンで段階的に学習 |
| **PacVim** | CLI | [GitHub](https://github.com/jmoon018/PacVim) | パックマン風ゲームでVim操作 |

### 1.2 Vim本体

| ツール | 説明 | インストール |
|--------|------|-------------|
| **Vim** | オリジナル | `brew install vim` |
| **Neovim** | モダンなVimフォーク、Lua対応 | `brew install neovim` |
| **MacVim** | macOS GUI版 | `brew install --cask macvim` |

**推奨**: Neovim（Luaによる高速な設定、モダンなプラグインエコシステム）

### 1.3 Neovimディストリビューション

初心者でもすぐにIDE級の環境を構築できるプリセット設定

| ディストリ | 特徴 | URL | charm.ot.trog@gmail.com
|-----------|------|-----|
| **LazyVim** | 高速起動、モダン設計 | [lazyvim.org](https://www.lazyvim.org/) |
| **LunarVim** | IDE風、初心者向け | [lunarvim.org](https://www.lunarvim.org/) |
| **AstroNvim** | 美しいUI、豊富な機能 | [astronvim.com](https://astronvim.com/) |
| **NvChad** | 軽量、高速 | [nvchad.com](https://nvchad.com/) |
| **kickstart.nvim** | 最小構成、学習用 | [GitHub](https://github.com/nvim-lua/kickstart.nvim) |

**推奨パス**:
1. 最初は `kickstart.nvim` で設定を理解
2. 慣れたら `LazyVim` で本格運用

### 1.4 プラグインマネージャー

| マネージャー | 言語 | 特徴 |
|-------------|------|------|
| **lazy.nvim** | Lua | 最速、遅延読み込み、現在の標準 |
| **packer.nvim** | Lua | 安定、広く使われている |
| **vim-plug** | Vimscript | シンプル、Vim/Neovim両対応 |

### 1.5 必須プラグイン（2026年版）

#### コア機能

| プラグイン | 機能 | 優先度 |
|-----------|------|:------:|
| **nvim-treesitter** | 高度な構文ハイライト | ⭐⭐⭐ |
| **nvim-lspconfig** | 言語サーバー連携 | ⭐⭐⭐ |
| **telescope.nvim** | ファジーファインダー | ⭐⭐⭐ |
| **nvim-cmp** | 自動補完 | ⭐⭐⭐ |
| **mason.nvim** | LSP/リンター管理 | ⭐⭐⭐ |

#### 編集支援

| プラグイン | 機能 | 優先度 |
|-----------|------|:------:|
| **LuaSnip** | スニペット | ⭐⭐⭐ |
| **nvim-autopairs** | 括弧自動補完 | ⭐⭐ |
| **Comment.nvim** | コメントトグル | ⭐⭐ |
| **nvim-surround** | 囲み文字操作 | ⭐⭐ |
| **flash.nvim** | 高速移動 | ⭐⭐ |

#### Git連携

| プラグイン | 機能 | 優先度 |
|-----------|------|:------:|
| **gitsigns.nvim** | 変更表示、blame | ⭐⭐⭐ |
| **lazygit.nvim** | LazyGit連携 | ⭐⭐ |
| **diffview.nvim** | 差分ビューア | ⭐⭐ |

#### UI/UX

| プラグイン | 機能 | 優先度 |
|-----------|------|:------:|
| **lualine.nvim** | ステータスライン | ⭐⭐ |
| **which-key.nvim** | キーバインドヘルプ | ⭐⭐⭐ |
| **nvim-tree.lua** | ファイルツリー | ⭐⭐ |
| **trouble.nvim** | 診断情報表示 | ⭐⭐ |
| **noice.nvim** | UI刷新 | ⭐ |
| **catppuccin** | カラースキーム | ⭐ |

#### AI連携

| プラグイン | 機能 | 優先度 |
|-----------|------|:------:|
| **ChatGPT.nvim** | OpenAI連携 | ⭐⭐ |
| **copilot.lua** | GitHub Copilot | ⭐⭐ |
| **llm.nvim** | 複数LLM対応 | ⭐ |

### 1.6 他ツールでのVimキーバインド

| ツール | Vim拡張 |
|--------|---------|
| **VS Code** | Vim extension (`vscodevim.vim`) |
| **Antigravity** | Vim extension（VS Code互換） |
| **JetBrains IDE** | IdeaVim |
| **Chrome/Arc** | Vimium |
| **Obsidian** | Vim mode (設定で有効化) |
| **Zsh** | `bindkey -v` (viモード) |
| **tmux** | `set-window-option -g mode-keys vi` |

---

## Part 2: 学習ロードマップ

### Phase 1: 入門（Week 1-2）

#### 目標
- Vimを恐れずに開き、編集し、保存できる
- 基本的なカーソル移動ができる

#### 学習内容

```
【モードの理解】
- Normal mode: コマンド実行（デフォルト）
- Insert mode: テキスト入力
- Visual mode: 選択
- Command mode: コマンドライン

【基本操作】
i     → Insert mode（カーソル前）
a     → Insert mode（カーソル後）
Esc   → Normal mode に戻る
:w    → 保存
:q    → 終了
:wq   → 保存して終了
:q!   → 保存せず終了

【カーソル移動】
h j k l  → 左 下 上 右
w        → 次の単語の先頭
b        → 前の単語の先頭
e        → 単語の末尾
0        → 行頭
$        → 行末
gg       → ファイル先頭
G        → ファイル末尾
```

#### 実践課題
1. `vimtutor` を毎日1回、1週間続ける
2. Git commit メッセージをVimで書く
3. 設定ファイルの簡単な編集をVimで行う

#### 推奨ツール
- [OpenVim](https://openvim.com/) - 基礎のインタラクティブ学習
- `vimtutor` - 毎日15-30分

---

### Phase 2: 基礎固め（Week 3-4）

#### 目標
- 効率的なテキスト編集ができる
- 「動詞 + 名詞」の文法を理解する

#### 学習内容

```
【Vimの文法】
動詞（Operator） + 名詞（Motion/Text Object）

動詞:
d  → delete（削除）
c  → change（削除してInsert）
y  → yank（コピー）
v  → visual（選択）

名詞（Motion）:
w  → word（単語）
b  → back（前の単語）
$  → 行末まで
0  → 行頭まで
G  → ファイル末尾まで
gg → ファイル先頭まで

名詞（Text Object）:
iw → inner word（単語内）
aw → a word（単語+空白）
i" → inner quotes（引用符内）
a" → a quotes（引用符含む）
i( → inner parentheses（括弧内）
it → inner tag（HTMLタグ内）

【組み合わせ例】
dw   → 単語を削除
d$   → 行末まで削除
ciw  → 単語を変更
ci"  → 引用符内を変更
yap  → 段落をコピー
vi{  → 中括弧内を選択
```

#### 実践課題
1. [VIM Adventures](https://vim-adventures.com/) でステージ3までクリア
2. 実際のコードでテキストオブジェクトを使う
3. `.` (ドット)コマンドで繰り返し操作を習得

#### 追加操作

```
【編集】
x     → 1文字削除
r     → 1文字置換
~     → 大文字小文字切替
>>    → インデント追加
<<    → インデント削除
J     → 行結合

【検索】
/pattern  → 前方検索
?pattern  → 後方検索
n         → 次の検索結果
N         → 前の検索結果
*         → カーソル下の単語を検索
```

---

### Phase 3: 中級（Month 2）

#### 目標
- レジスタ、マクロを使いこなす
- プラグインで環境をカスタマイズ

#### 学習内容

```
【レジスタ】
"ayy  → レジスタaに行をコピー
"ap   → レジスタaからペースト
""    → 無名レジスタ（デフォルト）
"0    → ヤンク専用レジスタ
"+    → システムクリップボード
:reg  → レジスタ一覧

【マクロ】
qa    → レジスタaに記録開始
q     → 記録終了
@a    → マクロa実行
@@    → 最後のマクロを再実行
10@a  → マクロaを10回実行

【ウィンドウ・タブ】
:sp   → 水平分割
:vsp  → 垂直分割
Ctrl-w h/j/k/l → ウィンドウ移動
Ctrl-w = → サイズ均等化
:tabnew → 新規タブ
gt/gT   → タブ移動

【マーク】
ma    → マークa設定
'a    → マークaの行へ移動
`a    → マークaの位置へ移動
''    → 前回の位置へ戻る
```

#### プラグイン導入

1. Neovimをインストール
2. `kickstart.nvim` をクローン
3. 基本プラグインの動作を理解

```bash
# kickstart.nvimで始める
git clone https://github.com/nvim-lua/kickstart.nvim.git \
  "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

#### 実践課題
1. マクロで繰り返し作業を自動化
2. init.lua を読んで設定を理解
3. telescope.nvim でファイル検索を高速化

---

### Phase 4: 上級（Month 3）

#### 目標
- Luaで設定をカスタマイズ
- LSPを使った本格的な開発環境構築

#### 学習内容

```
【置換】
:s/old/new/      → 行内で最初の一致を置換
:s/old/new/g     → 行内で全て置換
:%s/old/new/g    → ファイル全体で置換
:%s/old/new/gc   → 確認しながら置換

【グローバルコマンド】
:g/pattern/d     → パターンに一致する行を削除
:g!/pattern/d    → 一致しない行を削除
:g/TODO/t$       → TODOを含む行をファイル末尾にコピー

【高度な移動】
%      → 対応する括弧へジャンプ
f{char} → 行内で文字を検索（前方）
t{char} → 文字の手前まで移動
;      → f/t を繰り返し
,      → f/t を逆方向に繰り返し
Ctrl-o → ジャンプリスト：戻る
Ctrl-i → ジャンプリスト：進む

【折りたたみ】
zf    → 折りたたみ作成
zo    → 開く
zc    → 閉じる
za    → トグル
zR    → 全て開く
zM    → 全て閉じる
```

#### Lua設定の基礎

```lua
-- init.lua の基本構造
vim.g.mapleader = " "  -- リーダーキーをスペースに

-- オプション設定
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- キーマップ
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
```

#### 実践課題
1. 自分用の `init.lua` を作成
2. LSP で補完・定義ジャンプを設定
3. 1日の開発をVimだけで完結させる

---

### Phase 5: 達人（Month 4+）

#### 目標
- Vimscript/Luaで独自機能を実装
- 思考速度でコーディング

#### 学習内容

```
【Vimscript基礎】
" 変数
let g:myvar = "global"
let b:myvar = "buffer local"

" 関数
function! MyFunction()
  echo "Hello"
endfunction

" 自動コマンド
autocmd BufWritePre *.py :%s/\s\+$//e

【Lua発展】
-- プラグイン作成
local M = {}

function M.setup(opts)
  -- 設定処理
end

return M
```

#### 達人の習慣
1. **キーストロークを数える**: 同じ操作をより少ないキーで
2. **ドットコマンド最適化**: 繰り返し可能な操作を意識
3. **テキストオブジェクト自作**: treesitter-textobjects活用
4. **プラグイン貢献**: OSSプラグインにPRを送る

#### 推奨書籍・リソース
- [Practical Vim](https://pragprog.com/titles/dnvim2/practical-vim-second-edition/) - Drew Neil
- [Learn Vim (the Smart Way)](https://github.com/iggredible/Learn-Vim) - GitHub
- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html) - 公式ドキュメント

---

## Part 3: クイックリファレンス

### 最重要コマンド（80/20の法則）

```
【移動】
h j k l     左下上右
w / b       単語移動
0 / $       行頭/行末
gg / G      ファイル先頭/末尾
Ctrl-d/u    半ページ移動
%           対応括弧

【編集】
i / a       挿入（前/後）
o / O       新行挿入（下/上）
d + motion  削除
c + motion  変更
y + motion  コピー
p / P       ペースト（後/前）
u           アンドゥ
Ctrl-r      リドゥ
.           繰り返し

【検索】
/ / ?       検索
n / N       次/前
* / #       カーソル単語検索
:%s/a/b/g   全置換

【その他】
:w          保存
:q          終了
:e file     ファイルを開く
:bn / :bp   バッファ移動
```

### 覚えておくべきテキストオブジェクト

```
iw / aw    単語
i" / a"    ダブルクォート
i' / a'    シングルクォート
i( / a(    括弧
i{ / a{    波括弧
i[ / a[    角括弧
it / at    HTMLタグ
ip / ap    段落
is / as    文
```

---

## Part 4: 推奨学習スケジュール

| 期間 | 目標 | 1日の練習時間 |
|------|------|--------------|
| Week 1-2 | vimtutor完走、基本操作 | 30分 |
| Week 3-4 | テキストオブジェクト習得 | 30分 |
| Month 2 | マクロ・プラグイン導入 | 45分 |
| Month 3 | LSP環境構築、Lua設定 | 1時間 |
| Month 4+ | 実戦投入、カスタマイズ | 日常使用 |

---

## Part 5: 参考リンク

### 公式・学習
- [Vim公式](https://www.vim.org/)
- [Neovim公式](https://neovim.io/)
- [Learn Vim (the Smart Way)](https://github.com/iggredible/Learn-Vim)
- [Vim Tips Wiki](https://vim.fandom.com/wiki/Vim_Tips_Wiki)

### プラグイン情報
- [Dotfyle - Neovim Plugins](https://dotfyle.com/neovim/plugins/top)
- [Awesome Neovim](https://github.com/rockerBOO/awesome-neovim)

### チートシート
- [Vim Cheat Sheet](https://vim.rtorr.com/)
- [Devhints Vim](https://devhints.io/vim)

### コミュニティ
- [r/neovim](https://www.reddit.com/r/neovim/)
- [r/vim](https://www.reddit.com/r/vim/)

---

## まとめ

Vim習得は「学習曲線が急だが、天井がない」スキルです。

1. **最初の1週間が最も辛い** - vimtutorを毎日やる
2. **2週間で基本操作が身につく** - 実務でも使い始められる
3. **1ヶ月でIDEより快適になる** - プラグインの力
4. **3ヶ月で思考速度に近づく** - テキストオブジェクト駆使
5. **1年で達人の入り口** - 独自設定・プラグイン開発

**最も重要なのは「毎日少しでも使う」こと。**

Good luck on your Vim journey! 🚀
