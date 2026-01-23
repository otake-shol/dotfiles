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
-- (カラースキームとステータスラインはlazy.nvimで管理)
-- ===========================================

-- ===========================================
-- lazy.nvim プラグインマネージャー
-- ===========================================

-- lazy.nvim ブートストラップ
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- プラグイン設定
require("lazy").setup({
  -- カラースキーム: TokyoNight
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },

  -- ========================================
  -- LSP設定
  -- ========================================
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },
  -- フォーマッター・リンターの自動インストール
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- Formatters
          "stylua",       -- Lua
          "prettierd",    -- JS/TS/JSON/etc
          "black",        -- Python
          "isort",        -- Python imports
          "shfmt",        -- Shell
          "goimports",    -- Go
          -- Linters
          "eslint_d",     -- JS/TS
          "ruff",         -- Python
          "luacheck",     -- Lua
          "shellcheck",   -- Shell
          "golangci-lint", -- Go
          "markdownlint", -- Markdown
        },
        auto_update = false,
        run_on_start = true,
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",       -- Lua
          "ts_ls",        -- TypeScript/JavaScript
          "pyright",      -- Python
          "gopls",        -- Go
          "rust_analyzer", -- Rust
          "jsonls",       -- JSON
          "yamlls",       -- YAML
          "bashls",       -- Bash
        },
        automatic_installation = true,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- 共通キーマップ
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, opts)
      end

      -- 各LSPの設定
      local servers = { "ts_ls", "pyright", "gopls", "rust_analyzer", "jsonls", "yamlls", "bashls" }
      for _, server in ipairs(servers) do
        lspconfig[server].setup({
          capabilities = capabilities,
          on_attach = on_attach,
        })
      end

      -- Lua (Neovim設定用)
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
            telemetry = { enable = false },
          },
        },
      })

      -- 診断表示設定
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },

  -- ========================================
  -- 補完
  -- ========================================
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- friendly-snippets読み込み
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
        formatting = {
          format = function(entry, vim_item)
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
      })

      -- コマンドライン補完
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },

  -- ========================================
  -- フォーマッター（conform.nvim）
  -- ========================================
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>lf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "フォーマット",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        python = { "isort", "black" },
        go = { "gofmt", "goimports" },
        rust = { "rustfmt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_fallback = true,
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },

  -- ========================================
  -- リンター（nvim-lint）
  -- ========================================
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        python = { "ruff" },
        lua = { "luacheck" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        go = { "golangcilint" },
        markdown = { "markdownlint" },
      }

      -- 自動lint実行
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })

      -- 手動lint実行キーマップ
      vim.keymap.set("n", "<leader>ll", function()
        lint.try_lint()
      end, { desc = "リント実行" })
    end,
  },

  -- ========================================
  -- which-key（キーマップ表示）
  -- ========================================
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = { enabled = true } },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>b", group = "Buffer" },
        { "<leader>s", group = "Split" },
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>l", group = "Lint/Format" },
      })
    end,
  },

  -- ファジーファインダー: Telescope
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "ファイル検索" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "テキスト検索" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "バッファ一覧" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "ヘルプ検索" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "最近のファイル" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "診断一覧" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "シンボル検索" },
    },
  },

  -- シンタックスハイライト: Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc",
          "javascript", "typescript", "tsx",
          "python", "go", "rust",
          "json", "yaml", "toml", "markdown",
          "bash", "html", "css",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- ファイルエクスプローラー: neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "ファイルツリー" },
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
      },
    },
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  -- コメント
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- インデントガイド
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = false },
    },
  },

  -- ステータスライン: lualine
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "tokyonight",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
    },
  },

  -- 括弧の自動ペア
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- サラウンド操作
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },
}, {
  -- lazy.nvim オプション
  checker = { enabled = false }, -- 自動更新チェック無効
  change_detection = { notify = false },
})
