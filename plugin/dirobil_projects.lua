-- Загружаем локальный self-contained плагин dirobil.projects как обычный vim-плагин.
-- Файл в plugin/ выполняется при старте Neovim, поэтому команды и автокоманды
-- регистрируются без явного require() в конфиге.
require("dirobil.projects").setup()
