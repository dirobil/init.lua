-- Comment.nvim — комментирование по gc (visual) / gcc (строка), как Ctrl+/ в VS Code.
return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    padding = true,
    sticky = true,
    toggler = { line = "gcc", block = "gbc" },
    opleader = { line = "gc", block = "gb" },
    mappings = { operator = false, visualline = false }, -- gc уже оператор; не перекрываем gb
  },
}
