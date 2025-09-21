local keymap = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, expr = true, silent = true }

-- Visual line wraps
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", expr_opts)
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", expr_opts)
vim.api.nvim_set_keymap('i', 'jk', '<ESC>', {noremap = true})
vim.api.nvim_set_keymap('i', 'kj', '<ESC>', {noremap = true})

vim.api.nvim_set_keymap('i', '@sc', '<!--', {noremap = true})
vim.api.nvim_set_keymap('i', '@ec', '-->', {noremap = true})

vim.api.nvim_command ("digraph -- 8212")
vim.api.nvim_command ("digraph .. 8230")

-- Abrir zettel bajo el cursor (usa el comando que expone tu plugin)
keymap("n", "zo", "<cmd>ZettelOpen<CR>", default_opts)

-- Autocompletar enlaces
vim.keymap.set("i", "[[", function()
  require("pablo.myzettel.complete").insert_link()
end, { noremap = true, silent = true, desc = "Buscar e insertar enlace Zettel" })

vim.keymap.set("v", "zc", ":ZettelExtract<CR>", { noremap = true, silent = true, desc = "Extraer notas y crear enlaces" })
