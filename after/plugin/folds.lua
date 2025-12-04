-- Forzar folding por markers en vimwiki, cueste lo que cueste
local group = vim.api.nvim_create_augroup("vimwiki_markers_folds", { clear = true })

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = group,
  pattern = "*.md",
  callback = function()
    if vim.bo.filetype == "vimwiki" then
      vim.opt_local.foldmethod = "marker"
      vim.opt_local.foldmarker = "(··,··)"
    end
  end,
})
