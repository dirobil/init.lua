-- dirobil.projects — лёгкий self-contained плагин "недавние проекты".
--
-- Возможности:
--   * Автоскан: при старте Neovim текущая директория добавляется в список,
--     если это git-репозиторий (настраивается).
--   * :ProjectAdd [dir]   — добавить директорию в список.
--   * :ProjectList        — открыть демонстрационное окно со списком.
--   * :ProjectRemove [dir]— удалить директорию из списка.
--   * :ProjectClear       — очистить весь список.
--   * В окне: <CR>/o — перейти в директорию, x/<Del> — удалить, a — добавить, q — закрыть.
--
-- Pure Lua, без внешних зависимостей. Одинаково работает на Windows и Termux.

local M = {}

-- Служебные таблицы состояния окна (см. show_window)
M._win_meta = {}       -- _win_meta[buf] = { [lnum] = путь } для текущей отрисовки
M._keymapped_bufs = {} -- буферы, для которых keymap'ы уже установлены
M._ft_autocmd_done = false

-- Namespace для подсветки окна (создаётся один раз)
local HIGHLIGHT_NS = vim.api.nvim_create_namespace("dirobil_projects")

---------------------------------------------------------------------------
-- Настройки по умолчанию
---------------------------------------------------------------------------
M.config = {
  max_entries = 100,      -- максимум записей (0 = без лимита)
  auto_scan_cwd = true,   -- автодобавление cwd при старте
  detect_git_repo = true, -- считать проектом директорию с .git
  window_title = "Projects",
}

---------------------------------------------------------------------------
-- Хранилище: JSON-файл в stdpath("data")
---------------------------------------------------------------------------
local storage_path_cache = nil

local function get_storage_path()
  if not storage_path_cache then
    storage_path_cache = vim.fn.stdpath("data") .. "/dirobil_projects.json"
  end
  return storage_path_cache
end

local function load_list()
  local path = get_storage_path()
  if vim.fn.filereadable(path) == 0 then
    return {}
  end
  local ok, decoded = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(path), "\n"))
  if not ok or type(decoded) ~= "table" then
    return {}
  end
  local result = {}
  for _, v in ipairs(decoded) do
    if type(v) == "string" and v ~= "" then
      table.insert(result, v)
    end
  end
  return result
end

local function save_list(list)
  local path = get_storage_path()
  local dir = vim.fn.fnamemodify(path, ":h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
  local ok, encoded = pcall(vim.fn.json_encode, list)
  if not ok then
    vim.notify("[projects] failed to encode list: " .. tostring(encoded), vim.log.levels.ERROR)
    return
  end
  vim.fn.writefile({ encoded }, path)
end

-- Нормализация пути: абсолютный, без завершающего разделителя
local function normalize(dir)
  local norm = vim.fn.fnamemodify(dir, ":p")
  norm = norm:gsub("[/\\]+$", "")
  return norm
end

---------------------------------------------------------------------------
-- API
---------------------------------------------------------------------------

-- Похожа ли директория на проект?
function M.is_project(dir)
  if not dir or dir == "" then
    return false
  end
  if M.config.detect_git_repo then
    -- finddir с ";" поднимается вверх по дереву — ловим и вложенные репозитории
    return vim.fn.finddir(".git", vim.fn.fnameescape(dir) .. ";") ~= ""
  end
  return true
end

-- Добавить директорию (дубликат поднимается наверх — MRU)
function M.add(dir, opts)
  opts = opts or {}
  if not dir or dir == "" then
    return
  end
  local norm = normalize(dir)
  if norm == "" then
    return
  end

  local list = load_list()
  for i, v in ipairs(list) do
    if v == norm then
      table.remove(list, i)
      break
    end
  end
  table.insert(list, 1, norm)

  if M.config.max_entries and M.config.max_entries > 0 then
    while #list > M.config.max_entries do
      table.remove(list)
    end
  end

  save_list(list)

  if not opts.silent then
    vim.notify("[projects] added: " .. norm, vim.log.levels.INFO)
  end
end

-- Удалить директорию из списка
function M.remove(dir)
  local norm = normalize(dir or "")
  local list = load_list()
  for i, v in ipairs(list) do
    if v == norm then
      table.remove(list, i)
      save_list(list)
      vim.notify("[projects] removed: " .. norm, vim.log.levels.INFO)
      return true
    end
  end
  vim.notify("[projects] not found in list: " .. norm, vim.log.levels.WARN)
  return false
end

function M.get_list()
  return load_list()
end

function M.clear()
  save_list({})
  vim.notify("[projects] list cleared", vim.log.levels.INFO)
end

---------------------------------------------------------------------------
-- Демонстрационное окно
---------------------------------------------------------------------------
-- Ссылка на буфер окна: валидна и пока окно открыто, и после bdelete!
-- (bufhidden=wipe удаляет буфер целиком — тогда nvim_buf_is_valid = false).
-- Это надёжнее поиска по имени буфера.
local window_buf = nil

-- Найти существующий валидный буфер с именем window_title.
-- Важно: НЕ используем "#" / "%" в аргументе bufnr() — эти символы имеют
-- спец-значение и ломают поиск; перебираем буферы напрямую.
local function find_existing_buf(title)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b)
      and vim.bo[b].buftype == "nofile"
      and vim.api.nvim_buf_get_name(b) == title then
      return b
    end
  end
  return nil
end

function M.show_window()
  local list = M.get_list()

  local title = M.config.window_title

  -- Переиспользуем буфер, если он ещё жив (окно закрыто через q/Esc при
  -- bufhidden=hide, либо просто неактивен)
  local buf = nil
  if window_buf and vim.api.nvim_buf_is_valid(window_buf) then
    buf = window_buf
  else
    buf = find_existing_buf(title)
  end

  if buf then
    window_buf = buf
    -- Окно может быть неактивным (bufhidden=hide) — modifiable нужно
    -- вернуть вручную, BufUnload-автокоманда больше не используется
    vim.bo[buf].modifiable = true
    vim.cmd("buffer " .. buf)
  else
    vim.cmd("enew")
    buf = vim.api.nvim_get_current_buf()
    window_buf = buf
    -- fnameescape защищает от спецсимволов; ":file" задаёт имя без привязки к диску
    vim.cmd("file " .. vim.fn.fnameescape(title))
  end

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].filetype = "dirobil_projects"

  -- Копим строки; meta[lnum] = путь для строк-проектов
  local lines = {}
  local meta = {}
  table.insert(lines, ("Recent projects (%d)"):format(#list))
  table.insert(lines, "")
  if #list == 0 then
    table.insert(lines, '  (empty — press "a" to add a directory)')
  end
  for i, dir in ipairs(list) do
    table.insert(lines, ("%2d. %s%s"):format(i, dir, M.is_project(dir) and "   [git]" or ""))
    meta[i + 2] = dir
  end
  table.insert(lines, "")
  table.insert(lines, " <cr>/o open | x/<del> delete | a add | q quit")

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  -- Сохраняем актуальную карту "номер строки -> путь" для коллбэков keymap'ов
  M._win_meta[buf] = meta

  -- Подсветка
  vim.api.nvim_set_hl(0, "DirobilProjectsTitle", { link = "Function", default = true })
  vim.api.nvim_set_hl(0, "DirobilProjectsPath", { link = "Directory", default = true })
  vim.api.nvim_set_hl(0, "DirobilProjectsHint", { link = "Comment", default = true })
  vim.api.nvim_buf_clear_namespace(buf, HIGHLIGHT_NS, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, HIGHLIGHT_NS, "DirobilProjectsTitle", 0, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, HIGHLIGHT_NS, "DirobilProjectsHint", #lines - 1, 0, -1)
  for lnum in pairs(meta) do
    vim.api.nvim_buf_add_highlight(buf, HIGHLIGHT_NS, "DirobilProjectsPath", lnum - 1, 4, -1)
  end

  -----------------------------------------------------------------
  -- Локальные keymap'ы окна.
  -- Карты буфера живут в самом буфере, поэтому перерегистрация при каждой
  -- перерисовке не нужна. Коллбэки обращаются к актуальной таблице
  -- M._win_meta[buf], а не к снимку локальной переменной — иначе после
  -- удаления элемента («x») курсор мог попасть на строку подсказки,
  -- dir стал nil, перерисовка не произошла и повторное открытие окна
  -- падало с E95 (буфер с таким именем уже существовал).
  -----------------------------------------------------------------
  local function open_project(dir)
    -- Обновляем MRU
    M.add(dir, { silent = true })
    vim.cmd("cd " .. vim.fn.fnameescape(dir))
    -- Чистим текущий буфер от старых файлов и открываем новую директорию
    vim.cmd("silent! %bdelete!")
    if package.loaded["nvim-tree.api"] then
      require("nvim-tree.api").tree.open()
    elseif vim.fn.exists(":Telescope") == 2 then
      vim.schedule(function()
        pcall(require("telescope.builtin").find_files, { cwd = dir })
      end)
    else
      vim.cmd("Explore " .. vim.fn.fnameescape(dir))
    end
    vim.notify("[projects] cd -> " .. dir, vim.log.levels.INFO)
  end

  -- Действия работают по НОМЕРУ СТОКИ буфера, а не по снимку meta:
  -- актуальная таблица всегда лежит в M._win_meta[buf].
  local function action_open()
    local b = vim.api.nvim_get_current_buf()
    local dir = M._win_meta[b] and M._win_meta[b][vim.api.nvim_win_get_cursor(0)[1]]
    if dir then
      open_project(dir)
    else
      vim.notify("[projects] this line is not a project", vim.log.levels.WARN)
    end
  end

  local function action_delete()
    local b = vim.api.nvim_get_current_buf()
    local dir = M._win_meta[b] and M._win_meta[b][vim.api.nvim_win_get_cursor(0)[1]]
    if not dir then
      vim.notify("[projects] this line is not a project", vim.log.levels.WARN)
      return
    end
    -- Удаление и перерисовку откладываем до конца обработки нажатия:
    -- nvim_buf_set_lines внутри callback keymap'а недопустим (ошибка E5560),
    -- поэтому через vim.schedule.
    vim.schedule(function()
      M.remove(dir)
      local cur = vim.api.nvim_win_get_cursor(0)[1]
      local maxrow = math.max(3, #M.get_list() + 2)
      pcall(vim.api.nvim_win_set_cursor, 0, { math.min(cur, maxrow), 0 })
      M.show_window() -- перерисовать
    end)
  end

  local function action_add()
    -- input() тоже нельзя вызывать из callback во время обработки клавиш
    vim.schedule(function()
      local input = vim.fn.input("Add directory: ", vim.fn.getcwd() .. "/", "dir")
      if input and input ~= "" then
        M.add(input)
        M.show_window()
      end
    end)
  end

  local function action_close()
    vim.cmd("bdelete!")
  end

  local actions = {
    open = action_open,
    delete = action_delete,
    add = action_add,
    close = action_close,
  }

  -- Регистрация карт — один раз на буфер. Карты храним в самом буфере
  -- (buf.bexpr через v:lua), поэтому перерегистрация при перерисовке не нужна.
  local function apply_keymaps(b)
    if M._keymapped_bufs[b] then return end
    M._keymapped_bufs[b] = true
    local keyopts = { noremap = true, silent = true, nowait = true, buffer = b }
    vim.keymap.set("n", "<CR>",   'v:lua.dirobil_projects_act("open")',   vim.tbl_extend("error", keyopts, { desc = "Open project" }))
    vim.keymap.set("n", "o",      'v:lua.dirobil_projects_act("open")',   vim.tbl_extend("error", keyopts, { desc = "Open project" }))
    vim.keymap.set("n", "x",      'v:lua.dirobil_projects_act("delete")', vim.tbl_extend("error", keyopts, { desc = "Delete from list" }))
    vim.keymap.set("n", "<DEL>",  'v:lua.dirobil_projects_act("delete")', vim.tbl_extend("error", keyopts, { desc = "Delete from list" }))
    vim.keymap.set("n", "d",      'v:lua.dirobil_projects_act("delete")', vim.tbl_extend("error", keyopts, { desc = "Delete from list" }))
    vim.keymap.set("n", "a",      'v:lua.dirobil_projects_act("add")',    vim.tbl_extend("error", keyopts, { desc = "Add project" }))
    vim.keymap.set("n", "q",      'v:lua.dirobil_projects_act("close")',  vim.tbl_extend("error", keyopts, { desc = "Close window" }))
    vim.keymap.set("n", "<Esc>",  'v:lua.dirobil_projects_act("close")',  vim.tbl_extend("error", keyopts, { desc = "Close window" }))
  end

  -- Глобальный диспетчер для v:lua-выражений в keymap'ах
  _G.dirobil_projects_act = function(name)
    local A = M._actions
    if A and A[name] then A[name]() end
  end

  M._actions = actions

  if not M._ft_autocmd_done then
    M._ft_autocmd_done = true
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("DirobilProjects", { clear = true }),
      pattern = "dirobil_projects",
      callback = function(ev)
        apply_keymaps(ev.buf)
      end,
    })
  end

  -- Ставим карты сразу (идемпотентно): если filetype уже был выставлен
  -- на предыдущей перерисовке, FileType-событие сейчас не произойдёт
  apply_keymaps(buf)
end

---------------------------------------------------------------------------
-- setup()
---------------------------------------------------------------------------
function M.setup(user_config)
  if user_config then
    M.config = vim.tbl_deep_extend("force", M.config, user_config)
  end

  vim.api.nvim_create_user_command("ProjectAdd", function(opts)
    local dir = opts.args
    if dir == "" then
      dir = vim.fn.input("Add directory: ", vim.fn.getcwd() .. "/", "dir")
    end
    M.add(dir)
  end, { nargs = "?", complete = "dir", desc = "Add a project directory to the list" })

  -- Окно перерисовывается из callback'ов keymap'ов (x/a), поэтому сам
  -- show_window должен уметь запускаться из любой точки — оборачиваем в pcall
  -- и при E95/E5560 повторяем в следующем тике event loop.
  vim.api.nvim_create_user_command("ProjectList", function()
    local ok, err = pcall(M.show_window)
    if not ok and tostring(err):match("E95") then
      -- буфер с таким именем уже существует, но не был найден — чистим имя
      -- текущего буфера и пробуем снова уже вне обработки клавиш
      vim.schedule(function()
        pcall(vim.cmd, "enew | file " .. vim.fn.fnameescape(M.config.window_title))
        pcall(M.show_window)
      end)
    elseif not ok then
      vim.notify("[projects] " .. tostring(err), vim.log.levels.ERROR)
    end
  end, { desc = "Show recent projects window" })

  vim.api.nvim_create_user_command("ProjectRemove", function(opts)
    local dir = opts.args
    if dir == "" then
      dir = vim.fn.input("Remove directory: ", "", "dir")
    end
    if dir and dir ~= "" then
      M.remove(dir)
    end
  end, { nargs = "?", complete = "dir", desc = "Remove a directory from the list" })

  vim.api.nvim_create_user_command("ProjectClear", function()
    if vim.fn.confirm("Clear all saved projects?", "&Yes\n&No", 2) == 1 then
      M.clear()
    end
  end, { desc = "Clear the whole projects list" })

  -- Автодобавление текущей директории при старте
  if M.config.auto_scan_cwd then
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("DirobilProjectsAutoScan", { clear = true }),
      pattern = "*",
      once = true,
      callback = function()
        -- аргументом мог быть файл — берём его директорию
        local target = vim.fn.getcwd()
        if M.is_project(target) then
          M.add(target, { silent = true })
        end
      end,
    })
  end
end

return M
