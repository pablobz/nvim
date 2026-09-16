local opt = vim.opt -- for conciseness
vim.g.mapleader = ","
vim.opt.swapfile = false

-- line numbers
opt.number = true
opt.relativenumber = true

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = true
opt.linebreak = true

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- cursor line
opt.cursorline = false

-- appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start"

-- spell
opt.spell = true
vim.opt.spelllang = { "es", "es" }

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

opt.iskeyword:append("-")

-- surround

-- folding
opt.foldmarker = "(··,··)"
opt.foldmethod = "marker"

-- markdown con html
vim.g.markdown_fenced_languages = {
  "html",
  "css",
  "javascript",
}

-- conceal
vim.g.vimwiki_conceallevel = 0
vim.g.vimwiki_conceal_onechar_markers = 0

vim.api.nvim_create_autocmd("FileType", {
  pattern = "vimwiki",
  callback = function()
    vim.opt_local.conceallevel = 0
    vim.opt_local.concealcursor = ""
  end,
})
