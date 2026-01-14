-- ===========================================
-- Neovim ミニマル設定
-- ===========================================

-- リーダーキー設定（最初に設定）
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ===========================================
-- 表示設定
-- ===========================================

-- 行番号
vim.opt.number = true           -- 行番号表示
vim.opt.relativenumber = true   -- 相対行番号（移動が楽）

-- カーソル
vim.opt.cursorline = true       -- カーソル行ハイライト
vim.opt.scrolloff = 8           -- 上下に8行の余白を確保
vim.opt.sidescrolloff = 8       -- 左右に8列の余白

-- 検索
vim.opt.hlsearch = true         -- 検索結果ハイライト
vim.opt.incsearch = true        -- インクリメンタルサーチ
vim.opt.ignorecase = true       -- 大文字小文字を無視
vim.opt.smartcase = true        -- 大文字が含まれる場合は区別

-- 不可視文字の表示
vim.opt.list = true
vim.opt.listchars = {
  tab = "→ ",
  trail = "·",
  extends = "»",
  precedes = "«",
  nbsp = "␣",
}

-- その他の表示
vim.opt.signcolumn = "yes"      -- サイン列を常に表示
vim.opt.colorcolumn = "80,120"  -- 80,120文字目にライン
vim.opt.wrap = false            -- 折り返しなし
vim.opt.termguicolors = true    -- True Color対応
vim.opt.showmode = false        -- モード表示をオフ（ステータスラインで表示）

-- ===========================================
-- 編集設定
-- ===========================================

-- インデント
vim.opt.tabstop = 2             -- タブ幅
vim.opt.shiftwidth = 2          -- インデント幅
vim.opt.softtabstop = 2
vim.opt.expandtab = true        -- タブをスペースに
vim.opt.smartindent = true      -- スマートインデント
vim.opt.autoindent = true

-- クリップボード（システムと共有）
vim.opt.clipboard = "unnamedplus"

-- マウス
vim.opt.mouse = "a"             -- マウス有効

-- Undo永続化
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- バックアップ・スワップ
vim.opt.backup = false
vim.opt.swapfile = false

-- ファイル
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.autoread = true         -- 外部変更を自動読み込み

-- 分割
vim.opt.splitbelow = true       -- 水平分割は下に
vim.opt.splitright = true       -- 垂直分割は右に

-- 補完
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.pumheight = 10          -- 補完メニューの高さ

-- ===========================================
-- キーマップ
-- ===========================================

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 検索ハイライト解除
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)

-- 保存・終了
keymap("n", "<leader>w", "<cmd>w<CR>", { desc = "保存" })
keymap("n", "<leader>q", "<cmd>q<CR>", { desc = "終了" })
keymap("n", "<leader>x", "<cmd>x<CR>", { desc = "保存して終了" })

-- ウィンドウ移動
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- ウィンドウ分割
keymap("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "縦分割" })
keymap("n", "<leader>sh", "<cmd>split<CR>", { desc = "横分割" })

-- バッファ移動
keymap("n", "<S-h>", "<cmd>bprevious<CR>", opts)
keymap("n", "<S-l>", "<cmd>bnext<CR>", opts)
keymap("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "バッファを閉じる" })

-- 行移動（Visual mode）
keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap("v", "K", ":m '<-2<CR>gv=gv", opts)

-- インデント維持（Visual mode）
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- ペースト時にレジスタを上書きしない
keymap("x", "p", '"_dP', opts)

-- 全選択
keymap("n", "<C-a>", "ggVG", opts)

-- ===========================================
-- 自動コマンド
-- ===========================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ファイルタイプ別設定
augroup("FileTypeSettings", { clear = true })
autocmd("FileType", {
  group = "FileTypeSettings",
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

autocmd("FileType", {
  group = "FileTypeSettings",
  pattern = { "go" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

-- ヤンク時にハイライト
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- 最後のカーソル位置を復元
augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
  group = "RestoreCursor",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- 末尾の空白を自動削除（保存時）
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- ===========================================
-- カラースキーム
-- ===========================================

-- TokyoNight がインストールされていれば使用、なければ habamax
local ok, _ = pcall(vim.cmd, "colorscheme tokyonight-night")
if not ok then
  vim.cmd("colorscheme habamax")
end

-- ===========================================
-- ステータスライン（シンプル版）
-- ===========================================

vim.opt.laststatus = 2
vim.opt.statusline = table.concat({
  " %f",                    -- ファイル名
  " %m",                    -- 変更フラグ
  " %r",                    -- 読み取り専用フラグ
  "%=",                     -- 右寄せ
  " %y",                    -- ファイルタイプ
  " [%{&fileencoding}]",    -- エンコーディング
  " %l:%c ",                -- 行:列
  " %p%% ",                 -- パーセント
})
