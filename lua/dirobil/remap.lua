-- Горячие клавиши ядра конфига.
-- Клавиши плагинов объявляются локально в lua/dirobil/lazy/*.lua (секция keys),
-- здесь только базовые вещи, не зависящие от внешних плагинов.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- Окно проектов (dirobil.projects) — наш собственный плагин
map("n", "<leader>pl", ":ProjectList<CR>", { noremap = true, silent = true, desc = "Projects: list" })
map("n", "<leader>pa", ":ProjectAdd ", { noremap = true, desc = "Projects: add (введите путь)" })
map("n", "<leader>pd", ":ProjectRemove ", { noremap = true, desc = "Projects: remove (введите путь)" })
-- <leader>pv больше не netrw-Explore: дерево теперь nvim-tree (<leader>e).
map("n", "<leader>pv", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "Explorer: toggle tree" })

-- Буферы: переключение как табы в VS Code (Ctrl+PgUp/PgDn дублирует <S-Tab>)
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { noremap = true, silent = true, desc = "Prev buffer" })
map("n", "<Tab>", "<cmd>bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { noremap = true, silent = true, desc = "Delete buffer" })

-- Быстрое сохранение/выход
map("n", "<leader>w", "<cmd>write<CR>", { noremap = true, silent = true, desc = "Save" })
map("n", "<leader>q", "<cmd>quit<CR>", { noremap = true, silent = true, desc = "Quit window" })

-- Очистка подсветки поиска по <Esc> (как в VS Code после Ctrl+F)
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { noremap = true, silent = true, desc = "Clear search highlight" })

-- Перемещение между сплитами без префикса
map("n", "<C-h>", "<C-w>h", { noremap = true, silent = true, desc = "Focus left window" })
map("n", "<C-j>", "<C-w>j", { noremap = true, silent = true, desc = "Focus lower window" })
map("n", "<C-k>", "<C-w>k", { noremap = true, silent = true, desc = "Focus upper window" })
map("n", "<C-l>", "<C-w>l", { noremap = true, silent = true, desc = "Focus right window" })

-- Закрыть текущее окно (VS Code: Ctrl+W)
map("n", "<C-w>", "<cmd>quit<CR>", { noremap = true, silent = true, desc = "Close window" })

-- Скролл с прыжком на полстраницы меньше, чем Ctrl-F/D по умолчанию
map("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true, desc = "Scroll down half-page (centered)" })
map("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true, desc = "Scroll up half-page (centered)" })
map("n", "n", "nzzzv", { noremap = true, silent = true, desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { noremap = true, silent = true, desc = "Prev search result (centered)" })

-- Не терять выделение при сдвиге текста в visual-режиме
map("v", "<", "<gv", { noremap = true, silent = true, desc = "Indent (keep selection)" })
map("v", ">", ">gv", { noremap = true, silent = true, desc = "Outdent (keep selection)" })

-- J объединяет строки, но курсор остаётся на месте
map("x", "J", 'mzJ`z', { noremap = true, silent = true, desc = "Join lines, keep cursor" })
