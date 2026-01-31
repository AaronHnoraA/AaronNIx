-----------------------------------------------------------
-- 基础：leader / 插件管理（lazy.nvim）
-----------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- lazy.nvim 安装路径
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv and not vim.loop then
  vim.uv = vim.loop
end
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- 基础选项
-----------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.winblend = 0
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.winborder = "rounded"

-- 持久化 undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"

-- 系统剪贴板
vim.opt.clipboard = "unnamedplus"

-- 搜索小优化
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- 缩进展示
vim.opt.smartindent = true
vim.opt.breakindent = true

-----------------------------------------------------------
-- 透明背景
-----------------------------------------------------------
local function set_transparent()
  local groups = { "Normal", "NormalFloat", "SignColumn", "LineNr", "EndOfBuffer" }
  for _, grp in ipairs(groups) do
    vim.api.nvim_set_hl(0, grp, { bg = "none" })
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_transparent,
})
set_transparent()

-----------------------------------------------------------
-- 打开文件自动跳回上次光标位置
-----------------------------------------------------------
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(args)
    local bufnr = args.buf
    local mark = vim.api.nvim_buf_get_mark(bufnr, '"')
    local lcount = vim.api.nvim_buf_line_count(bufnr)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-----------------------------------------------------------
-- 你的 LazyFile / LSP / 补全逻辑
-----------------------------------------------------------
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  desc = "自定义事件LazyFile",
  pattern = "*",
  once = true,
  callback = function()
    if not vim.g._lazyfile_triggered then
      vim.g._lazyfile_triggered = true
      vim.schedule(function()
        vim.api.nvim_exec_autocmds("User", { pattern = "LazyFile" })
      end)
    end
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyFile",
  callback = function()
    -- 开启内置 LSP（假设你本机已装 lua-language-server / clangd）
    vim.lsp.enable({ "lua_ls", "clangd" })

    -- 诊断配置
    vim.diagnostic.config({
      virtual_text = true,
      update_in_insert = true,
      underline = true,
      float = { border = "rounded" },
    })

    -- 诊断快捷键
    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "diagnostic messages" })
    vim.keymap.set("n", "[d", function()
      vim.diagnostic.jump({ wrap = true, count = -1 })
    end, { desc = "prev diagnostic" })
    vim.keymap.set("n", "]d", function()
      vim.diagnostic.jump({ wrap = true, count = 1 })
    end, { desc = "next diagnostic" })

    -- 格式化
    vim.keymap.set("n", "<leader>lf", function()
      vim.lsp.buf.format()
    end, { desc = "format buffer" })

    -- 保存快捷键
    vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w<cr>", { desc = "save file" })
  end,
})

-- LspAttach 时补全相关设置
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client
      and client:supports_method("textDocument/completion")
      and vim.lsp.completion
    then
      vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })

      vim.keymap.set("i", "<C-Space>", function()
        vim.lsp.completion.get()
      end, { desc = "completion" })
    end

    -----------------------------------------------------
    -- 一些常用 LSP 快捷键（跳转/重命名/代码操作）
    -----------------------------------------------------
    local bufmap = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
    end

    bufmap("n", "gd", vim.lsp.buf.definition, "goto definition")
    bufmap("n", "gD", vim.lsp.buf.declaration, "goto declaration")
    bufmap("n", "gr", vim.lsp.buf.references, "references")
    bufmap("n", "gi", vim.lsp.buf.implementation, "implementation")
    bufmap("n", "K", vim.lsp.buf.hover, "hover doc")
    bufmap("n", "<leader>rn", vim.lsp.buf.rename, "rename symbol")
    bufmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "code action")
  end,
})

-----------------------------------------------------------
-- 一些简单的通用快捷键
-----------------------------------------------------------
-- 快速清除搜索高亮
vim.keymap.set("n", "<Esc>", "<cmd>noh<cr><Esc>", { desc = "clear highlights" })

-- 快速打开/关闭行号模式切换
vim.keymap.set("n", "<leader>rn", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "toggle relativenumber" })

-- 更舒服的窗口移动
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "window right" })

-----------------------------------------------------------
-- 插件：用 lazy.nvim 管理
-----------------------------------------------------------
require("lazy").setup({
  -------------------------------------------------------
  -- Treesitter 高亮
  -------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,  -- 官方建议不要懒加载 [web:39][web:42]
    opts = {
      ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "markdown" },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      -- 可选：用 Treesitter 做折叠（不喜欢可以删掉）[web:36]
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt.foldlevel = 99
    end,
  },

  -------------------------------------------------------
  -- 一个简单状态栏（lualine）
  -------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        section_separators = "",
        component_separators = "",
      },
    },
    config = function(_, opts)
      require("lualine").setup(opts)
    end,
  },

  -------------------------------------------------------
  -- 可选：一个简单的配色方案（支持透明）
  -------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = true,  -- 和我们上面的透明函数配合 [web:30]
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
})

