return {
  "vimwiki/vimwiki",
  init = function()
    vim.g.vimwiki_conceallevel = 0
    vim.g.vimwiki_conceal_onechar_markers = 0
    vim.g.vimwiki_list = {
      {
        path = "~/wiki/",
        syntax = "markdown",
        ext = "md",
      },
    }
  end,
}
