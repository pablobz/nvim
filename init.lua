require("pablo.myzettel").setup({
  dir = "~/zettelkasten",    -- tu directorio
  template = "default",      -- nombre de la plantilla (sin extensión .md)
  uid_scheme = "custom"      -- para luego poder elegir otro sistema si lo deseas
})
require("pablo.core.options")
require("pablo.core.keymaps")
require("pablo.lazy")
require("pablo.core.colorscheme")

