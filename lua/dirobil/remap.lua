vim.g.mapleader = " "

-- Список недавних проектов (dirobil.projects)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex) -- классическая клавиша из starter-конфига
vim.keymap.set("n", "<leader>pl", ":ProjectList<CR>", { noremap = true, silent = true, desc = "Projects: list" })
vim.keymap.set("n", "<leader>pa", ":ProjectAdd ", { noremap = true, desc = "Projects: add (введите путь)" })
vim.keymap.set("n", "<leader>pd", ":ProjectRemove ", { noremap = true, desc = "Projects: remove (введите путь)" })
