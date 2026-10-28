-- Базовые настройки редактора. Одинаково работают на Windows и Termux.

-- Отключаем netrw ДО его загрузки: файловое дерево даёт nvim-tree.lua,
-- так `:Explore`/netrw не будет конфликтовать с tree-буферами.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt

-- Линейки и строка состояния
opt.number = true            -- абсолютные номера строк
opt.relativenumber = true    -- относительные (быстрые motion: 5j, 12k)
opt.showmode = false         -- режим и так виден в статусбаре (lualine)
opt.ruler = false

-- Мышь и буфер обмена.
-- В Termux для системного буфера обмена установите: pkg install termux-api
-- (тогда neovim найдёт termux-clipboard-set/get). Без него clipboard тихо
-- работает через внутренний регистр 0 — конфиг не падает ни там, ни там.
opt.mouse = "a"
opt.clipboard = "unnamedplus"

-- Отступы как в VS Code по умолчанию
opt.expandtab = true         -- Tab -> пробелы
opt.shiftwidth = 2           -- размер отступа автоформатирования
opt.tabstop = 2              -- ширина табуляции при отображении
opt.smartindent = true
opt.softtabstop = -1

-- Поиск
opt.ignorecase = true        -- игнорировать регистр...
opt.smartcase = true         -- ...если в запросе есть заглавные — искать точно
opt.hlsearch = true
opt.incsearch = true         -- подсветка совпадений при наборе (как find в VS Code)
opt.wrapscan = true

-- Окна/сплиты
opt.splitright = true        -- вертикальный сплит справа
opt.splitbelow = true        -- горизонтальный сплит снизу
opt.scrolloff = 8            -- держать 8 строк над/под курсором
opt.sidescrolloff = 8
opt.signcolumn = "yes"       -- всегда резервировать колонку знаков (gitsigns/neogit/LSP)

-- Надёжность: отменяемые изменения сохраняются между сессиями
opt.undofile = true
opt.swapfile = false

-- Поведение ввода
opt.completeopt = "menu,menuone,noselect"
opt.backspace = "indent,eol,start"
opt.formatoptions:remove({ "c", "r", "o" }) -- не автокомментировать продолжения строк

-- Скорость реакций
opt.updatetime = 250         -- быстрее срабатывают CursorHold/SignColumn
opt.timeoutlen = 500         -- время на добор multi-key комбинаций (<leader>gd ...)
opt.ttimeoutlen = 50

-- Внешний вид
opt.termguicolors = true     -- truecolor (Termux поддерживает; Windows Terminal тоже)
opt.cursorline = true        -- подсветка текущей строки
opt.colorcolumn = "100"      -- ориентир ширины строки
opt.wrap = false             -- без переноса длинных строк (VS Code default)

-- Диалоги/меню
opt.pumheight = 10           -- максимум пунктов в popup-меню автодополнения
opt.confirm = true           -- спрашивать подтверждение при выходе с несохранённым

-- Буферы: cwd меняет dirobil.projects (:cd) и ProjectList; autochdir off,
-- чтобы nvim-tree/telescope не «прыгали» при открытии файлов из других папок.
opt.autochdir = false
