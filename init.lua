require("pablo.core.options")
require("pablo.core.keymaps")
require("pablo.lazy")
require("pablo.core.colorscheme")
require("config.highlights").setup()

-- hace que el cursor parpadee en todos los modos
vim.opt.guicursor = {
  'n-v-c:block-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100',
  'i-ci:ver25-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100',
  'r:hor50-Cursor/lCursor-blinkwait100-blinkon100-blinkoff100'
}
