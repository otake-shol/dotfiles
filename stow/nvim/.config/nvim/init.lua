-- ===========================================
-- Neovim 最小構成
-- ===========================================
-- 用途: git commit、設定ファイルの軽微な編集
-- メインエディタ: Antigravity + Claude Code
--
-- 意図的にプラグインなしの最小構成を維持しています。
-- 理由: Antigravityで本格的な開発を行うため、Neovimは
--       ターミナル上での軽微な編集専用として高速起動を優先。

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

-- ===========================================
-- 拡張ポイント（必要に応じて追加）
-- ===========================================
-- この設定は軽微な編集用の最小構成です。
-- より本格的な開発環境が必要な場合は以下を検討してください。
--
-- 【lazy.nvimでプラグイン管理する場合】
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
--   vim.fn.system({
--     "git", "clone", "--filter=blob:none",
--     "https://github.com/folke/lazy.nvim.git",
--     "--branch=stable", lazypath
--   })
-- end
-- vim.opt.rtp:prepend(lazypath)
-- require("lazy").setup({ ... })
--
-- 【推奨プラグイン】
-- - nvim-treesitter: シンタックスハイライト・コード解析
-- - nvim-lspconfig: Language Server Protocol統合
-- - telescope.nvim: ファジーファインダー
-- - gitsigns.nvim: Git差分表示
-- - which-key.nvim: キーバインドヘルプ
-- - lualine.nvim: ステータスライン
--
-- 【設定ファイルの拡張構成案】
-- ~/.config/nvim/
-- ├── init.lua
-- └── lua/
--     ├── plugins/       # プラグイン設定
--     ├── config/        # 基本設定
--     └── keymaps.lua    # キーマップ
