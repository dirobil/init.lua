-- WhichKey — всплывающая подсказка клавиш после <leader> (как Command Palette-подсказки).
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = { spelling = false },
    icons = { breadcrumb = "»", separator = "➜ ", group = " " },
    win = { border = "single", padding = { 1, 1, 1, 1 } },
    timeout = 500,
  },
  keys = {},
}
