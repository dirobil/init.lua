vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- Перемещение по строкам если vim.opt.wrap == true
if vim.wo.wrap then
	map({ "n", "x" }, "j", "gj", { silent = true }) -- вниз по визуальной строке
	map({ "n", "x" }, "k", "gk", { silent = true }) -- вверх по визуальной строке
end

