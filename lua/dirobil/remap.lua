vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- Перемещение по строкам если vim.opt.wrap == true
if vim.wo.wrap then
	map({ "n", "x" }, "j", "gj", { silent = true }) -- вниз по визуальной строке
	map({ "n", "x" }, "k", "gk", { silent = true }) -- вверх по визуальной строке
end

-- Изменение клавиш для Visual Block
vim.keymap.set('n', '<leader>v', '<C-v>', { noremap = true, desc = 'Visual Block' })

-- Буфер обмена
vim.keymap.set('v', '<C-c>', '"+y', { noremap = true, silent = true, desc = "Копировать" })
vim.keymap.set('n', '<C-v>', '"+p', { noremap = true, silent = true, desc = "Вставить" })
