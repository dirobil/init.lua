-- Иконки файлов для nvim-tree, telescope и др. Pure Lua.
-- Требует шрифт Nerd Font, иначе вместо иконок будут «тофу»/кракозябры:
--   Windows: скачайте с https://www.nerdfonts.com (например, JetBrainsMonoNLNerdFont)
--            и установите, затем выберите шрифт в терминале/GUI.
--   Termux:  pkg install font-jetbrains-mono-nerd  (или скопируйте .ttf в ~/.termux/font.ttf)
return {
  "nvim-tree/nvim-web-devicons",
  lazy = true,
  config = function()
    require("nvim-web-devicons").setup({
      default = true, -- иконка-заглушка для неизвестных расширений
    })
  end,
}
