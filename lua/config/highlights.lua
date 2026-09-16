local M = {}

function M.setup()
  -- Colores (ajústalos a tu esquema)
  vim.api.nvim_set_hl(0, "AtOne", { fg = "#ff5555", force = true })
  vim.api.nvim_set_hl(0, "AtTwo", { fg = "#50fa7b", force = true })
  vim.api.nvim_set_hl(0, "AtThree", { fg = "#bd93f9", force = true })

  -- Aplicar en cada buffer
  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
      vim.fn.matchadd("AtOne", [[@1\>]])
      vim.fn.matchadd("AtTwo", [[@2\>]])
      vim.fn.matchadd("AtThree", [[@3\>]])
    end,
  })
end

return M
