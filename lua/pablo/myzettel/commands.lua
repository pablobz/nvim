local config = require("pablo.myzettel.config")

local M = {}

local function replace_literal(str, placeholder, value)
  -- Escapar cualquier carácter especial de patrones Lua
  local safe_placeholder = placeholder:gsub("(%W)", "%%%1")
  return str:gsub(safe_placeholder, value)
end

-- Genera UID único tipo 25I20A (o 25I20Z, 25I20AA, …)
local function generate_uid()
  local dir = vim.fn.expand(require("pablo.myzettel.config").options.dir)

  -- Mes como letra: A..L (ene..dic)
  local month_letters = { "A","B","C","D","E","F","G","H","I","J","K","L" }
  local y  = os.date("%y")
  local ml = month_letters[tonumber(os.date("%m"))]
  local d  = os.date("%d")
  local prefix = y .. ml .. d   -- p.ej. "25I20"

  -- Helpers: convertir letras→número y número→letras (base 26, A=1)
  local function letters_to_num(s)
    local n = 0
    for i = 1, #s do n = n * 26 + (string.byte(s, i) - 64) end
    return n
  end
  local function num_to_letters(n)
    local s = ""
    while n > 0 do
      local rem = (n - 1) % 26
      s = string.char(65 + rem) .. s
      n = math.floor((n - 1) / 26)
    end
    return s
  end

  -- Recolectar sufijos ya usados (A, B, ..., Z, AA...) en disco y buffers
  local used_max = 0

  -- 1) Disco
  local files = vim.fn.globpath(dir, prefix .. "*.md", false, true)
  for _, path in ipairs(files or {}) do
    local name = vim.fn.fnamemodify(path, ":t")
    local suf  = name:match("^" .. prefix .. "([A-Z]+)")
    if suf then
      local n = letters_to_num(suf)
      if n > used_max then used_max = n end
    end
  end

  -- 2) Buffers abiertos (aunque no estén guardados)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(b)
    if name and name ~= "" then
      local base = vim.fn.fnamemodify(name, ":t")
      local suf  = base:match("^" .. prefix .. "([A-Z]+)")
      if suf then
        local n = letters_to_num(suf)
        if n > used_max then used_max = n end
      end
    end
  end

  -- Siguiente sufijo
  local next_suffix = num_to_letters(used_max + 1)
  return prefix .. next_suffix
end

-- Utilidad para leer la plantilla desde disco
local function load_template(name)
  local path = debug.getinfo(1, "S").source:match("@?(.*/)") .. "templates/" .. name .. ".md"
  local file = io.open(path, "r")
  if not file then
    error("No se pudo cargar la plantilla: " .. name)
  end
  local content = file:read("*all")
  file:close()
  return content
end

local function new_note(opts)
  local title = vim.fn.input("Título: ")
  if title == "" then return end
  local uid = generate_uid()

  local filename = string.format("%s %s.md", uid, title)
  local filepath = vim.fn.expand(config.options.dir .. "/" .. filename)
  vim.cmd("edit " .. filepath)

  -- Fecha en formato legible
  local months = { "enero","febrero","marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre" }
  local date = os.date("*t")
  local date_str = string.format("%d de %s de %d", date.day, months[date.month], date.year)

  -- Tags opcionales pasados por argumento
  local tags = opts.args or "#sinempezar"

  -- Cargar y reemplazar variables de la plantilla
  local template = load_template(config.options.template)
  template = replace_literal(template, "%%uid%%", uid)
  template = replace_literal(template, "%%title%%", title)
  template = replace_literal(template, "%%date%%", date_str)
  template = replace_literal(template, "%%tags%%", tags)

  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(template, "\n"))
end

function M.register()
  vim.api.nvim_create_user_command("ZettelNew", new_note, { nargs = "?" })
end


return M

