-- Catppuccin — мягкая скруглённая тема. Pure Lua, работает на Windows и Termux.
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000, -- загрузить до остальных плагинов, чтобы тема применилась сразу
  config = function()
    require("catppuccin").setup({
      flavour = "macchiato", -- latte | frappe | macchiato | mocha
      background = {        -- выбор флаура по vim.o.background
        light = "latte",
        dark = "macchiato",
      },
      term_colors = true,   -- раскрасить ANSI-цвета терминала (важно для toggleterm)
    })
    vim.cmd.colorscheme("catppuccin")
  end,
}
