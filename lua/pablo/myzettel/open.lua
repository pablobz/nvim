local config = require("pablo.myzettel.config")
local M = M or {}

local function open_under_cursor()
  -- captura [[UID]] bajo el cursor
  local word = vim.fn.expand("<cWORD>")
  local uid = word:match("%[%[([%w%-]+)%]%]")  -- admite letras/números y guión si un día lo usas
  if not uid then
    vim.notify("No hay UID bajo el cursor (formato [[UID]])", vim.log.levels.WARN)
    return
  end
  local dir = vim.fn.expand(config.options.dir)
  local pattern = string.format("%s/%s*.md", dir, uid)
  local matches = vim.fn.glob(pattern, false, true)

  if #matches == 0 then
    vim.notify("No se encontró nota para UID " .. uid, vim.log.levels.WARN)
    return
  elseif #matches > 1 then
    -- Si hubiera colisión, abre la primera o lanza un picker aquí si quieres
    -- require('telescope.builtin').find_files({ cwd = dir, default_text = uid })
  end

  vim.cmd("edit " .. matches[1])
end

-- expórtala para usarla desde fuera
M.open_under_cursor = open_under_cursor

function M.register()
  -- ... tus otros comandos (ZettelNew, etc.)
  vim.api.nvim_create_user_command("ZettelOpen", function()
    open_under_cursor()
  end, {})
end

return M
