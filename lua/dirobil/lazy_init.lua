-- Инициализация lazy.nvim + общий setup всех плагинов из lua/dirobil/lazy/*.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { tostring(vim.v.shell_error), "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "dirobil.lazy" } },
  install = { colorscheme = { "catppuccin", "habamax" } }, -- habamax — встроенная запасная тема
  checker = { enabled = false },   -- не гоняем фоновые проверки сети (Termux/слабый интернет)
  change_detection = { notify = false },
  rocks = { enabled = false },     -- luarocks не обязателен: все плагины pure-Lua или с fallback
})
