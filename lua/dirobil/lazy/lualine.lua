-- Lualine — статус-бар в стиле VS Code (мод, файл, git-ветка, LSP, позиция).
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    local ok_devicons = pcall(require, "nvim-web-devicons")
    require("lualine").setup({
      options = {
        theme = "auto", -- подхватит catppuccin
        globalstatus = true,
        component_separators = "|",
        section_separators = "",
        icons_enabled = ok_devicons,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
