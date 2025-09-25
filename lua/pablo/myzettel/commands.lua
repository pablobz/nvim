local config = require("pablo.myzettel.config")

local M = {}

-----------------------------------------------------------------------
-- Utilidades comunes
-----------------------------------------------------------------------

-- Reemplazo literal seguro en plantillas
local function replace_literal(str, placeholder, value)
  local safe_placeholder = placeholder:gsub("(%W)", "%%%1")
  return str:gsub(safe_placeholder, value)
end

-- Genera UID único tipo 25I20A (o 25I20Z, 25I20AA, …)
local function generate_uid()
  local dir = vim.fn.expand(config.options.dir)
  local month_letters = { "A","B","C","D","E","F","G","H","I","J","K","L" }
  local y  = os.date("%y")
  local ml = month_letters[tonumber(os.date("%m"))]
  local d  = os.date("%d")
  local prefix = y .. ml .. d

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

  local used_max = 0

  -- Buscar archivos existentes en disco
  local files = vim.fn.globpath(dir, prefix .. "*.md", false, true)
  for _, path in ipairs(files or {}) do
    local name = vim.fn.fnamemodify(path, ":t")
    local suf  = name:match("^" .. prefix .. "([A-Z]+)")
    if suf then
      local n = letters_to_num(suf)
      if n > used_max then used_max = n end
    end
  end

  -- Buscar en buffers abiertos
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

  return prefix .. num_to_letters(used_max + 1)
end

-- Carga plantilla desde disco
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

-- Fecha legible
local function human_date()
  local months = { "enero","febrero","marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre" }
  local date = os.date("*t")
  return string.format("%d de %s de %d", date.day, months[date.month], date.year)
end

-----------------------------------------------------------------------
-- Creación de notas
-----------------------------------------------------------------------

local function create_note_file(uid, title, body, tags, parent_uid, parent_title)
  local filepath = vim.fn.expand(config.options.dir .. "/" .. string.format("%s %s.md", uid, title))
  local template = load_template(config.options.template)

  template = replace_literal(template, "%%uid%%", uid)
  template = replace_literal(template, "%%title%%", title)
  template = replace_literal(template, "%%date%%", human_date())
  template = replace_literal(template, "%%tags%%", tags or "#sinempezar")

  -- Insertar cuerpo
  if body and body ~= "" then
    local lines = vim.split(template, "\n")
    local sep_index
    for i, line in ipairs(lines) do
      if line:match("^%-%-%-%s*$") then
        sep_index = i
        break
      end
    end
    if sep_index then
      while sep_index > 1 and lines[sep_index - 1]:match("^%s*$") do
        table.remove(lines, sep_index - 1)
        sep_index = sep_index - 1
      end
      local body_lines = vim.split(body, "\n")
      for j = #body_lines, 1, -1 do
        table.insert(lines, sep_index, body_lines[j])
      end
      table.insert(lines, sep_index + #body_lines, "")
      template = table.concat(lines, "\n")
    else
      template = template .. "\n\n" .. body
    end
  end

  -- Insertar enlace a nota madre si existe
  if parent_uid and parent_title then
    local lines = vim.split(template, "\n")
    for i, line in ipairs(lines) do
      if line:match("^##%s*Enlaces") then
        table.insert(lines, i + 1, string.format("[[%s]] %s", parent_uid, parent_title))
        break
      end
    end
    template = table.concat(lines, "\n")
  end

  vim.fn.writefile(vim.split(template, "\n"), filepath)
  vim.cmd("checktime")
  return filepath
end


-----------------------------------------------------------------------
-- Comando: crear nueva nota interactiva
-----------------------------------------------------------------------

local function new_note(opts)
  local title = vim.fn.input("Título: ")
  if title == "" then return end
  local uid = generate_uid()
  local filepath = create_note_file(uid, title, nil, opts.args)

  -- Abrir el archivo recién creado en el buffer
  vim.cmd("edit " .. filepath)
end

-----------------------------------------------------------------------
-- Comando: extraer varias notas desde texto seleccionado
-----------------------------------------------------------------------

function M.extract_from_selection()
  local parent_path = vim.api.nvim_buf_get_name(0)
  local parent_fullname = vim.fn.fnamemodify(parent_path, ":t:r") -- nombre sin extensión
  local parent_uid, parent_title = parent_fullname:match("^(%S+)%s+(.+)$")

  local start_line = vim.fn.line("'<") - 1
  local end_line   = vim.fn.line("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  if #lines == 0 then return end

  local current_title, current_body = nil, {}
  local notes_created = {}

  local function flush_note()
    if not current_title then return end
    local uid = generate_uid()
    create_note_file(uid, current_title, table.concat(current_body, "\n"), nil, parent_uid, parent_title)
    table.insert(notes_created, string.format("[[%s]] %s", uid, current_title))
    current_title, current_body = nil, {}
  end

  for _, line in ipairs(lines) do
    if line:match("^%-%-") then
      flush_note()
      current_title = vim.trim(line:gsub("^%-%-%s*", ""))
    else
      table.insert(current_body, line)
    end
  end
  flush_note()

  vim.api.nvim_buf_set_lines(0, start_line, end_line, false, notes_created)
end

-----------------------------------------------------------------------
-- Registro de comandos
-----------------------------------------------------------------------

function M.register()
  vim.api.nvim_create_user_command("ZettelNew", new_note, { nargs = "?" })
  vim.api.nvim_create_user_command("ZettelExtract", function()
    require("pablo.myzettel.commands").extract_from_selection()
  end, { range = true })
end

-----------------------------------------------------------------------
return M







