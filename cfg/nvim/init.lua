vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.cmd([[hi @lsp.type.number gui=bold]])

vim.opt.mouse = ""
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.showtabline = 2
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 200
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.confirm = true
vim.opt.cursorcolumn = false
vim.opt.completeopt:append({ "menuone", "noselect", "popup" })

pcall(function()
  vim.opt.winborder = "rounded"
end)

for type, icon in pairs({
  Error = "E ",
  Warn = "W ",
  Hint = "H ",
  Info = "I ",
}) do
  vim.fn.sign_define("DiagnosticSign" .. type, {
    text = icon,
    texthl = "DiagnosticSign" .. type,
    numhl = "",
  })
end

local function maybe_require(name)
  local ok, mod = pcall(require, name)
  if ok then
    return mod
  end
  return nil
end

local function missing_plugin_handler(name)
  return function()
    vim.notify(name .. " is unavailable", vim.log.levels.WARN)
  end
end

local map = vim.keymap.set
local builtin = maybe_require("telescope.builtin")
local telescope = maybe_require("telescope")
local telescope_themes = maybe_require("telescope.themes")
local ls = maybe_require("luasnip")
local oil = maybe_require("oil")
local uv = vim.uv or vim.loop
local startup_cwd = uv.cwd()

if not builtin then
  builtin = setmetatable({}, {
    __index = function(_, key)
      return missing_plugin_handler("telescope." .. key)
    end,
  })
end

local dap = maybe_require("dap")
local dapui = maybe_require("dapui")
local dap_lldb = maybe_require("dap-lldb")
local dap_virtual_text = maybe_require("nvim-dap-virtual-text")
local mason = maybe_require("mason")
local actions_preview = maybe_require("actions-preview")

if mason then
  mason.setup()
end

if dap_virtual_text then
  dap_virtual_text.setup({})
end

if dapui then
  dapui.setup({})
end

if dap_lldb then
  dap_lldb.setup()
end

if dap and dapui then
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end

  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end

  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end

  if dap_lldb then
    map("n", "<leader>d", "<cmd>DapNew<cr>", { desc = "Start DAP session" })
  end

  map({ "n", "i" }, "<C-b>", "<cmd>DapToggleBreakpoint<cr>", { desc = "Toggle breakpoint" })
end

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "c",
    "cpp",
    "glsl",
    "javascript",
    "lua",
    "markdown",
    "python",
    "react",
    "rust",
    "svelte",
    "typst",
    "typescript",
    "typescriptreact",
    "zig",
  },
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = { "*.jsx", "*.tsx" },
  group = vim.api.nvim_create_augroup("user-ts-react", { clear = true }),
  callback = function()
    vim.bo.filetype = "typescriptreact"
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  group = vim.api.nvim_create_augroup("user-auto-cd-new-file", { clear = true }),
  callback = function(args)
    local path = vim.api.nvim_buf_get_name(args.buf)
    if path == "" then
      return
    end

    local dir = vim.fn.fnamemodify(path, ":p:h")
    if vim.fn.isdirectory(dir) == 1 then
      vim.cmd.cd(vim.fn.fnameescape(dir))
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local bufmap = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      local chars = {}
      for i = 32, 126 do
        table.insert(chars, string.char(i))
      end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end

    bufmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
    bufmap("n", "gr", vim.lsp.buf.references, "References")
    bufmap("n", "K", vim.lsp.buf.hover, "Hover")
    bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    bufmap("n", "<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
    bufmap("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
    bufmap("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
  end,
})

local marks = maybe_require("marks")
if marks then
  marks.setup({
    builtin_marks = { "<", ">", "^" },
  })
end

local gitsigns = maybe_require("gitsigns")
if gitsigns then
  gitsigns.setup({})
end

local comment = maybe_require("Comment")
if comment then
  comment.setup({})
end

if ls then
  ls.setup({
    enable_autosnippets = true,
  })

  local luasnip_loader = maybe_require("luasnip.loaders.from_lua")
  if luasnip_loader then
    luasnip_loader.load({
      paths = { vim.fs.joinpath(vim.fn.stdpath("config"), "snippets") },
    })
  end
end

if oil then
  oil.setup({
    default_file_explorer = false,
    lsp_file_methods = {
      enabled = true,
      timeout_ms = 1000,
      autosave_changes = true,
    },
    columns = {
      "icon",
    },
    view_options = {
      show_hidden = false,
    },
    float = {
      border = "rounded",
      max_width = 0.55,
      max_height = 0.75,
      override = function(conf)
        local width = math.min(math.floor(vim.o.columns * 0.55), 96)
        local height = math.min(math.floor(vim.o.lines * 0.75), 32)

        conf.relative = "editor"
        conf.width = width
        conf.height = height
        conf.col = math.floor((vim.o.columns - width) / 2)
        conf.row = math.floor((vim.o.lines - height) / 2)

        return conf
      end,
    },
  })
end

local function buffer_dir()
  if oil then
    local dir = oil.get_current_dir(0)
    if dir then
      return dir
    end
  end

  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return uv.cwd()
  end

  if vim.fn.isdirectory(name) == 1 then
    return name
  end

  return vim.fn.fnamemodify(name, ":p:h")
end

local function repo_root()
  local dir = buffer_dir()
  return vim.fs.root(dir, { ".git" }) or dir
end

local function open_path(path)
  vim.cmd.edit(vim.fn.fnameescape(path or "."))
end

local function open_oil(path, as_float)
  if not oil then
    open_path(path)
    return
  end

  if as_float then
    oil.open_float(path)
    return
  end

  oil.open(path)
end

local function open_repo_oil()
  local root = repo_root()
  if vim.bo.filetype == "oil" then
    open_oil(root, false)
    return
  end

  open_oil(root, true)
end

local function open_file_browser(path)
  if not telescope then
    open_oil(path, false)
    return
  end

  local file_browser = telescope.extensions.file_browser
  if not file_browser then
    builtin.find_files({ cwd = path })
    return
  end

  file_browser.file_browser({
    path = path,
    cwd = path,
    respect_gitignore = true,
    hidden = false,
    grouped = true,
    hijack_netrw = false,
    initial_mode = "normal",
    layout_strategy = "horizontal",
    layout_config = {
      prompt_position = "top",
      preview_width = 0.5,
      width = 0.95,
      height = 0.9,
    },
  })
end

if oil then
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("user-oil-maps", { clear = true }),
    pattern = "oil",
    callback = function(args)
      local opts = { buffer = args.buf, silent = true }
      local actions = require("oil.actions")

      map("n", "<BS>", function()
        actions.parent.callback()
      end, vim.tbl_extend("force", opts, { desc = "Parent directory" }))

      map("n", "gr", open_repo_oil, vim.tbl_extend("force", opts, { desc = "Repo root" }))
    end,
  })
end

local has_env_extension = false
if telescope then
  telescope.setup({
    defaults = {
      preview = {
        treesitter = true,
      },
      color_devicons = true,
      sorting_strategy = "ascending",
      borderchars = {
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
      },
      path_display = { "smart" },
      layout_config = {
        height = 0.9,
        width = 0.9,
        prompt_position = "top",
        preview_cutoff = 40,
      },
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
        },
      },
    },
    extensions = {
      ["ui-select"] = telescope_themes and telescope_themes.get_dropdown({}) or {},
    },
  })
  pcall(telescope.load_extension, "fzf")
  pcall(telescope.load_extension, "file_browser")
  pcall(telescope.load_extension, "ui-select")
  has_env_extension = pcall(telescope.load_extension, "env")
end

if actions_preview and telescope_themes then
  actions_preview.setup({
    backend = { "telescope" },
    telescope = vim.tbl_extend(
      "force",
      telescope_themes.get_dropdown(),
      {}
    ),
  })
end

do
  local ok, treesitter = pcall(require, "nvim-treesitter.configs")
  if ok then
    treesitter.setup({
      highlight = { enable = true },
      indent = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
        },
      },
    })
  end
end

vim.cmd.colorscheme("kanagawa-wave")

vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 2,
    source = "if_many",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "if_many",
  },
})

vim.api.nvim_create_autocmd("CursorHold", {
  group = vim.api.nvim_create_augroup("user-diagnostics-float", { clear = true }),
  callback = function()
    vim.diagnostic.open_float(nil, {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = "rounded",
      source = "if_many",
      scope = "line",
    })
  end,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      telemetry = {
        enable = false,
      },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
})

vim.lsp.config("nil_ls", {})
vim.lsp.config("rust_analyzer", {})
vim.lsp.config("clangd", {})

for _, server in ipairs({
  "lua_ls",
  "nil_ls",
  "rust_analyzer",
  "clangd",
  "tinymist",
}) do
  pcall(vim.lsp.enable, server)
end

map("n", "g=", "g+")
map("n", "gK", "@='ddkPJ'<cr>")

vim.cmd([[
  xnoremap gK <esc><cmd>keeppatterns '<,'>-global/$/normal! ddpkJ<cr>
  noremap! <c-r><c-d> <c-r>=strftime('%F')<cr>
  noremap! <c-r><c-t> <c-r>=strftime('%T')<cr>
  noremap! <c-r><c-f> <c-r>=expand('%:t')<cr>
  noremap! <c-r><c-p> <c-r>=expand('%:p')<cr>
  xnoremap <expr> . "<esc><cmd>'<,'>normal! ".v:count1.'.<cr>'
]])

for i = 1, 8 do
  map({ "n", "t" }, "<leader>" .. i, "<cmd>tabnext " .. i .. "<cr>")
end

map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
if ls then
  map({ "i", "s" }, "<C-e>", function()
    ls.expand_or_jump(1)
  end, { silent = true })
  map({ "i", "s" }, "<C-J>", function()
    ls.jump(1)
  end, { silent = true })
  map({ "i", "s" }, "<C-K>", function()
    ls.jump(-1)
  end, { silent = true })
end
map("n", "yag", ":%y<cr>", { silent = true })
map("n", "vag", "ggVG", { silent = true })
map("n", "gl", "$", { desc = "Jump to end of line" })
map({ "n", "v", "x" }, "<CR>", ":", { desc = "Command-line mode" })
map("n", "<leader>f", function()
  open_file_browser(buffer_dir())
end, { desc = "Browse files from current view", nowait = true })
map("n", "<leader>F", function()
  open_file_browser(startup_cwd)
end, { desc = "Browse files from startup directory" })
map("n", "<leader>g", builtin.live_grep, { desc = "Live grep" })
map("n", "<leader>sg", function()
  builtin.find_files({ no_ignore = true })
end, { desc = "Find all files" })
map("n", "<leader>sb", builtin.buffers, { desc = "Buffers" })
map("n", "<leader>si", builtin.grep_string, { desc = "Grep string" })
map("n", "<leader>so", builtin.oldfiles, { desc = "Old files" })
map("n", "<leader>sh", builtin.help_tags, { desc = "Help" })
map("n", "<leader>sm", builtin.man_pages, { desc = "Man pages" })
map("n", "<leader>G", builtin.git_commits, { desc = "Git commits" })
map("n", "<leader>sr", builtin.lsp_references, { desc = "LSP references" })
map("n", "<leader>sd", builtin.diagnostics, { desc = "Diagnostics" })
map("n", "<leader>sT", builtin.lsp_type_definitions, { desc = "Type definitions" })
map("n", "<leader>ss", builtin.current_buffer_fuzzy_find, { desc = "Buffer search" })
map("n", "<leader>st", builtin.builtin, { desc = "Telescope pickers" })
map("n", "<leader>sk", builtin.keymaps, { desc = "Keymaps" })
if has_env_extension then
  map("n", "<leader>se", "<cmd>Telescope env<cr>", { desc = "Environment variables" })
end
if actions_preview then
  map("n", "<leader>sa", actions_preview.code_actions, { desc = "Code actions" })
else
  map("n", "<leader>sa", vim.lsp.buf.code_action, { desc = "Code actions" })
end
map("n", "<leader>e", open_repo_oil, { desc = "Explorer (repo root)" })
map("n", "-", function()
  open_oil(nil, false)
end, { desc = "Open file explorer" })
map("n", "<leader>E", function()
  open_oil(buffer_dir(), true)
end, { desc = "Explorer (current dir)" })
map("n", "<leader>c", "1z=", { desc = "Spell suggestions" })
map("n", "<leader>t", "<cmd>split<cr><cmd>term<cr>i", { desc = "Open terminal" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Terminal normal mode" })
map("n", "<leader>x", "<cmd>tabclose<cr>", { desc = "Close tab" })
map("n", "<leader>w", "<cmd>update<cr>", { desc = "Write buffer" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit buffer" })
map("n", "<leader>Q", "<cmd>wqa<cr>", { desc = "Write and quit all" })
map("n", "<leader>a", "<cmd>edit #<cr>", { desc = "Alternate buffer" })
map("n", "<leader>r", "<cmd>edit!<cr>", { desc = "Reload current file" })
map("n", "<leader>v", "<cmd>edit $MYVIMRC<cr>", { desc = "Edit Neovim config" })
map("n", "<leader>z", "<cmd>edit ~/.config/zsh/.zshrc<cr>", { desc = "Edit zshrc" })
map({ "n", "v", "x" }, "<leader>n", ":norm ", { desc = "Run normal command" })
map({ "n", "v", "x" }, "<leader>o", "<cmd>source $MYVIMRC<cr>", { desc = "Source Neovim config" })
map({ "n", "v", "x" }, "<C-s>", [[:s/\V]], { desc = "Start substitute" })
map({ "n", "v", "x" }, "<leader>i", "<cmd>tabedit .gitignore<cr>", { desc = "Edit .gitignore" })
map("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format buffer" })
map("n", "<leader>xl", vim.diagnostic.setloclist, { desc = "Diagnostics list" })
map("n", "<C-q>", "<cmd>copen<cr>", { desc = "Open quickfix" })
map("n", "<M-n>", "<cmd>resize +2<cr>", { desc = "Increase height" })
map("n", "<M-e>", "<cmd>resize -2<cr>", { desc = "Decrease height" })
map("n", "<M-i>", "<cmd>vertical resize +5<cr>", { desc = "Increase width" })
map("n", "<M-m>", "<cmd>vertical resize -5<cr>", { desc = "Decrease width" })
map({ "v", "x", "n" }, "<C-y>", '"+y', { desc = "System clipboard yank" })
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("v", "<", "<gv")
map("v", ">", ">gv")
