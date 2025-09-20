local M = {}
local config   = require("pablo.myzettel.config")
local commands = require("pablo.myzettel.commands")
local open     = require("pablo.myzettel.open")

function M.setup(opts)
  config.setup(opts or {})
  commands.register()  -- aquí registras ZettelNew y lo que tengas en commands.lua
  open.register()      -- IMPORTANTE: aquí creas :ZettelOpen
end

-- reexport correcto: desde el módulo open, no commands
M.open_under_cursor = open.open_under_cursor

return M
