local M = {}

M.options = {
  dir = "~/zettelkasten",
  template = "default",  -- nombre de plantilla, sin extensión
  uid_scheme = "custom"
}

function M.setup(opts)
  M.options = vim.tbl_extend("force", M.options, opts or {})
end

return M
