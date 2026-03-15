if vim.loader then
  vim.loader.enable()
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

for _, plugin in ipairs({
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "tar",
  "tarPlugin",
  "tutor_mode_plugin",
  "zip",
  "zipPlugin",
}) do
  vim.g["loaded_" .. plugin] = 1
end

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 24

local uv = vim.uv or vim.loop
local api = vim.api
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.breakindent = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 6
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.updatetime = 200
opt.timeoutlen = 300
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.completeopt = { "menuone", "noselect", "popup", "fuzzy" }
opt.wildmode = { "longest", "full" }
opt.wildoptions = "pum"
opt.grepprg = "rg --vimgrep --smart-case --hidden"
opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
opt.laststatus = 3
opt.showmode = false
opt.confirm = true
opt.list = false
opt.listchars = { tab = "> ", trail = ".", nbsp = "+" }
opt.fillchars:append({ eob = " " })
opt.shortmess:append("c")
opt.inccommand = "split"
opt.winborder = "rounded"
opt.statusline = table.concat({
  " %f",
  "%m%r%h%w",
  "%=",
  " %y",
  " %l:%c",
  " %p%% ",
})

vim.cmd.colorscheme("habamax")

local function map(mode, lhs, rhs, desc, extra)
  local opts = vim.tbl_extend("force", { silent = true, desc = desc }, extra or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function augroup(name)
  return api.nvim_create_augroup("core_" .. name, { clear = true })
end

local function set_transparent_background()
  for _, group in ipairs({
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "SignColumn",
    "FoldColumn",
    "LineNr",
    "CursorLineNr",
    "EndOfBuffer",
    "StatusLine",
    "StatusLineNC",
    "TabLineFill",
    "Pmenu",
    "WinSeparator",
    "MsgArea",
  }) do
    local ok, hl = pcall(api.nvim_get_hl, 0, { name = group, link = false })
    if ok then
      hl.bg = "none"
      api.nvim_set_hl(0, group, hl)
    end
  end
end

local function notify(message)
  vim.notify(message, vim.log.levels.INFO, { title = "nvim" })
end

local function is_large_file(bufnr)
  local name = api.nvim_buf_get_name(bufnr)
  if name == "" then
    return false
  end

  local stat = uv.fs_stat(name)
  return stat and stat.size > 512 * 1024 or false
end

local function project_root(bufnr, markers)
  local bufname = api.nvim_buf_get_name(bufnr)
  return vim.fs.root(bufnr, markers) or (bufname ~= "" and vim.fs.dirname(bufname) or uv.cwd())
end

local function has_lsp_client(bufnr, method)
  return #vim.lsp.get_clients({ bufnr = bufnr, method = method }) > 0
end

local function lsp_float_opts(focusable)
  return {
    border = "rounded",
    max_width = 88,
    focusable = focusable,
    focus = false,
    silent = true,
    close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertEnter", "InsertLeave" },
  }
end

local function open_cursor_popup(bufnr)
  if vim.bo[bufnr].buftype ~= "" or vim.b[bufnr].large_file or vim.fn.mode() ~= "n" then
    return
  end

  local diagnostics = vim.diagnostic.get(bufnr, { lnum = api.nvim_win_get_cursor(0)[1] - 1 })
  if vim.g.auto_diagnostic_float and #diagnostics > 0 then
    vim.diagnostic.open_float(nil, {
      scope = "cursor",
      border = "rounded",
      focusable = false,
      close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertEnter" },
    })
    return
  end

  if vim.g.auto_lsp_popup and has_lsp_client(bufnr, "textDocument/hover") then
    pcall(vim.lsp.buf.hover, lsp_float_opts(false))
  end
end

local function open_signature_popup(bufnr)
  if not vim.g.auto_lsp_popup or vim.bo[bufnr].buftype ~= "" or vim.b[bufnr].large_file then
    return
  end

  if vim.fn.mode() ~= "i" or vim.fn.pumvisible() == 1 or not has_lsp_client(bufnr, "textDocument/signatureHelp") then
    return
  end

  pcall(vim.lsp.buf.signature_help, lsp_float_opts(false))
end

vim.g.autoformat = true
vim.g.auto_diagnostic_float = true
vim.g.auto_lsp_popup = true

api.nvim_create_autocmd("ColorScheme", {
  group = augroup("transparent"),
  callback = set_transparent_background,
})
set_transparent_background()

map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>", "Clear search highlight")
map("n", "<leader>w", "<cmd>update<cr>", "Save file")
map("n", "<leader>q", "<cmd>quit<cr>", "Quit window")
map("n", "<leader>bd", "<cmd>bdelete<cr>", "Delete buffer")
map("n", "<leader>e", "<cmd>Explore<cr>", "File explorer")
map("n", "<leader>tt", "<cmd>terminal<cr>", "Open terminal")
map("n", "<leader>lf", function()
  vim.lsp.buf.format({ async = true })
end, "Format buffer")
map("n", "<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
map("n", "<leader>xl", function()
  vim.diagnostic.setloclist({ open = true })
end, "Buffer diagnostics")
map("n", "<leader>xL", function()
  vim.diagnostic.setqflist({ open = true })
end, "Workspace diagnostics")
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, "Previous diagnostic")
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, "Next diagnostic")
map("n", "[q", "<cmd>cprevious<cr>zz", "Previous quickfix")
map("n", "]q", "<cmd>cnext<cr>zz", "Next quickfix")
map("n", "<leader>xq", "<cmd>copen<cr>", "Open quickfix")
map("n", "<leader>ur", function()
  opt.relativenumber = not opt.relativenumber:get()
  notify("relativenumber " .. (opt.relativenumber:get() and "on" or "off"))
end, "Toggle relative number")
map("n", "<leader>uw", function()
  vim.opt_local.wrap = not vim.opt_local.wrap:get()
  notify("wrap " .. (vim.opt_local.wrap:get() and "on" or "off"))
end, "Toggle wrap")
map("n", "<leader>us", function()
  vim.opt_local.spell = not vim.opt_local.spell:get()
  notify("spell " .. (vim.opt_local.spell:get() and "on" or "off"))
end, "Toggle spell")
map("n", "<leader>ul", function()
  opt.list = not opt.list:get()
  notify("listchars " .. (opt.list:get() and "on" or "off"))
end, "Toggle listchars")
map("n", "<leader>uf", function()
  vim.g.autoformat = not vim.g.autoformat
  notify("format on save " .. (vim.g.autoformat and "on" or "off"))
end, "Toggle format on save")
map("n", "<leader>ud", function()
  vim.g.auto_diagnostic_float = not vim.g.auto_diagnostic_float
  notify("diagnostic float " .. (vim.g.auto_diagnostic_float and "on" or "off"))
end, "Toggle diagnostic float")
map("n", "<leader>up", function()
  vim.g.auto_lsp_popup = not vim.g.auto_lsp_popup
  notify("lsp popup " .. (vim.g.auto_lsp_popup and "on" or "off"))
end, "Toggle lsp popup")
map("n", "<leader>uh", function()
  if not vim.lsp.inlay_hint then
    return
  end

  local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
  notify("inlay hints " .. (enabled and "off" or "on"))
end, "Toggle inlay hints")
map("n", "<C-h>", "<C-w>h", "Window left")
map("n", "<C-j>", "<C-w>j", "Window down")
map("n", "<C-k>", "<C-w>k", "Window up")
map("n", "<C-l>", "<C-w>l", "Window right")
map("n", "<C-Up>", "<cmd>resize +2<cr>", "Increase height")
map("n", "<C-Down>", "<cmd>resize -2<cr>", "Decrease height")
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", "Decrease width")
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", "Increase width")
map("n", "<S-h>", "<cmd>bprevious<cr>", "Previous buffer")
map("n", "<S-l>", "<cmd>bnext<cr>", "Next buffer")
map("n", "n", "nzzzv", "Next search result")
map("n", "N", "Nzzzv", "Previous search result")
map("n", "<C-d>", "<C-d>zz", "Half page down")
map("n", "<C-u>", "<C-u>zz", "Half page up")
map("v", "J", ":m '>+1<CR>gv=gv", "Move selection down")
map("v", "K", ":m '<-2<CR>gv=gv", "Move selection up")

map("n", "<C-s>", "<cmd>update<cr>", "Save file")
map("i", "<C-s>", "<C-o>:update<cr>", "Save file")
map("v", "<C-s>", "<Esc><cmd>update<cr>gv", "Save file")
map("t", "<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode")
map("i", "<C-Space>", function()
  if vim.lsp.completion then
    vim.lsp.completion.get()
  end
end, "Trigger completion")
map("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  end
  return "<Tab>"
end, "Next completion item", { expr = true })
map("i", "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  end
  return "<S-Tab>"
end, "Previous completion item", { expr = true })
map("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-y>"
  end
  return "<CR>"
end, "Confirm completion", { expr = true })

vim.diagnostic.config({
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "H",
    },
  },
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 2,
    source = "if_many",
  },
  float = {
    border = "rounded",
    source = "if_many",
  },
})

api.nvim_create_autocmd("TextYankPost", {
  group = augroup("yank"),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 180 })
  end,
})

api.nvim_create_autocmd("BufReadPre", {
  group = augroup("large_file"),
  callback = function(args)
    if is_large_file(args.buf) then
      vim.b[args.buf].large_file = true
    end
  end,
})

api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_cursor"),
  callback = function(args)
    local mark = api.nvim_buf_get_mark(args.buf, '"')
    local line_count = api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

api.nvim_create_autocmd("BufWritePre", {
  group = augroup("save"),
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end

    local name = api.nvim_buf_get_name(args.buf)
    if name ~= "" then
      vim.fn.mkdir(vim.fn.fnamemodify(name, ":p:h"), "p")
    end

    if not vim.g.autoformat or vim.b[args.buf].autoformat == false or vim.b[args.buf].large_file then
      return
    end

    if #vim.lsp.get_clients({ bufnr = args.buf, method = "textDocument/formatting" }) == 0 then
      return
    end

    pcall(vim.lsp.buf.format, {
      bufnr = args.buf,
      async = false,
      timeout_ms = 1200,
    })
  end,
})

api.nvim_create_autocmd("FileType", {
  group = augroup("formatoptions"),
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

api.nvim_create_autocmd("FileType", {
  group = augroup("text"),
  pattern = { "gitcommit", "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "man", "qf" },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    map("n", "q", "<cmd>close<cr>", "Close window", { buffer = args.buf })
  end,
})

api.nvim_create_autocmd("TermOpen", {
  group = augroup("terminal"),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd.startinsert()
  end,
})

api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd.checktime()
    end
  end,
})

api.nvim_create_autocmd("VimResized", {
  group = augroup("resize"),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

api.nvim_create_autocmd("CursorHold", {
  group = augroup("cursor_popup"),
  callback = function(args)
    open_cursor_popup(args.buf)
  end,
})

api.nvim_create_autocmd("CursorHoldI", {
  group = augroup("signature_popup"),
  callback = function(args)
    open_signature_popup(args.buf)
  end,
})

local servers = {
  lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  clangd = {
    cmd = { "clangd", "--background-index", "--header-insertion=never" },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
  },
  gopls = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
  },
  rust_analyzer = {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
  },
  pyright = {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = {
      "pyproject.toml",
      "pyrightconfig.json",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      ".git",
    },
  },
  ts_ls = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  },
  bashls = {
    cmd = { "bash-language-server", "start" },
    filetypes = { "sh", "bash", "zsh" },
    root_markers = { ".git" },
  },
  marksman = {
    cmd = { "marksman", "server" },
    filetypes = { "markdown" },
    root_markers = { ".marksman.toml", ".git" },
  },
}

for name, server in pairs(servers) do
  if vim.fn.executable(server.cmd[1]) == 1 then
    local config = vim.deepcopy(server)
    config.root_dir = function(bufnr, on_dir)
      if vim.bo[bufnr].buftype ~= "" or vim.b[bufnr].large_file then
        return
      end

      on_dir(project_root(bufnr, server.root_markers))
    end

    vim.lsp.config(name, config)
    vim.lsp.enable(name)
  end
end

api.nvim_create_autocmd("LspAttach", {
  group = augroup("lsp_attach"),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    local function bufmap(mode, lhs, rhs, desc)
      map(mode, lhs, rhs, desc, { buffer = bufnr })
    end

    bufmap("n", "gd", vim.lsp.buf.definition, "Goto definition")
    bufmap("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
    bufmap("n", "gr", vim.lsp.buf.references, "List references")
    bufmap("n", "gi", vim.lsp.buf.implementation, "Goto implementation")
    bufmap("n", "K", function()
      vim.lsp.buf.hover(lsp_float_opts(true))
    end, "Hover")
    bufmap("n", "<leader>lk", function()
      vim.lsp.buf.signature_help(lsp_float_opts(true))
    end, "Signature help")
    bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    bufmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    bufmap("i", "<C-k>", function()
      vim.lsp.buf.signature_help(lsp_float_opts(true))
    end, "Signature help")

    if vim.lsp.completion and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end

    if vim.lsp.inlay_hint
      and not vim.b[bufnr].large_file
      and client:supports_method("textDocument/inlayHint")
    then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    if vim.b[bufnr].large_file or not client:supports_method("textDocument/documentHighlight") then
      return
    end

    local group = api.nvim_create_augroup("core_lsp_highlight_" .. bufnr, { clear = true })
    api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end,
})

api.nvim_create_user_command("Format", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format current buffer" })
