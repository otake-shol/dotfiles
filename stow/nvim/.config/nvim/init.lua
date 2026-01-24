-- ===========================================
-- Neovim 最小構成
-- ===========================================
-- 用途: git commit、設定ファイルの軽微な編集
-- メインエディタ: Antigravity + Claude Code

-- リーダーキー
vim.g.mapleader = " "

-- ===========================================
-- 表示設定
-- ===========================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.wrap = false
vim.opt.showmode = false

-- 不可視文字
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "·" }

-- ===========================================
-- 編集設定
-- ===========================================
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.undofile = true
vim.opt.backup = false
vim.opt.swapfile = false

-- 検索
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- ===========================================
-- キーマップ
-- ===========================================
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)
keymap("n", "<leader>w", "<cmd>w<CR>", opts)
keymap("n", "<leader>q", "<cmd>q<CR>", opts)

-- ウィンドウ移動
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- ===========================================
-- TokyoNight テーマ（プラグインなし）
-- ===========================================
-- 手動インストール済みのテーマを読み込み
-- ~/.local/share/nvim/site/pack/colors/start/tokyonight.nvim
pcall(vim.cmd.colorscheme, "tokyonight-night")
