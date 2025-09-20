local config = require("pablo.myzettel.config")
local M = {}



-- Convierte nombre de archivo en enlace [[UID]] Título
local function format_link(filename)
  local name = vim.fn.fnamemodify(filename, ":t:r")
  local uid, title = name:match("^(%w+)%s(.+)$")
  if not uid then
    -- fallback: si no hay título separado
    return string.format("[[%s]]", name)
  end
  return string.format("[[%s]] %s", uid, title)
end


function M.insert_link()
  local builtin = require("telescope.builtin")

  builtin.find_files({
    prompt_title = "Insertar enlace Zettel",
    cwd = vim.fn.expand(config.options.dir),
    attach_mappings = function(_, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local function insert_selected(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        local selections = picker:get_multi_selection()
        actions.close(prompt_bufnr)

        if #selections == 0 then
          local selection = action_state.get_selected_entry()
          if selection then
            local row = unpack(vim.api.nvim_win_get_cursor(0))
            row = row - 1  -- índice 0-based para API
            vim.api.nvim_buf_set_text(0, row, 0, row, -1, { format_link(selection.path) })
          end
        else
          for _, sel in ipairs(selections) do
            local row = unpack(vim.api.nvim_win_get_cursor(0))
            row = row - 1
            for i, sel in ipairs(selections) do
              vim.api.nvim_buf_set_text(0, row + (i - 1), 0, row + (i - 1), -1, { format_link(sel.path) })
            end
          end
        end
      end

      map("i", "<CR>", insert_selected)
      map("n", "<CR>", insert_selected)
      return true
    end,
  })
end

return M
