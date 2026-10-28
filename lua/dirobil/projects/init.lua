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

-- Namespace для подсветки окна (создаётся один раз)
local HIGHLIGHT_NS = vim.api.nvim_create_namespace("dirobil_projects")

-- Буфер, показывающий окно в данный момент (для корректной перерисовки).
-- Нужен, чтобы не искать буфер по имени и не вызывать :file для уже названного буфера.
local current_buf = nil

-- Актуальная карта "номер строки -> путь" для обработчиков keymap'ов
-- (обновляется при каждой перерисовке окна).
local active_meta = nil

-- Буферы, на которые уже повешены локальные keymap'ы.
local maps_installed = {}

-- Найти наш буфер по прямому перебору имён (без bufnr("#..."), который может
-- вернуть -1 или устаревший номер и привести к E95/E13).
local function find_own_buf()
  if current_buf and vim.api.nvim_buf_is_valid(current_buf) then
    return current_buf
  end
  local title = M.config.window_title
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) and vim.fn.bufname(b) == title then
      current_buf = b
      return b
    end
  end
  return nil
end

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
local augroup_defined = false

function M.show_window()
  local list = M.get_list()
  local title = M.config.window_title

  -- Ищем ТОЛЬКО наш собственный буфер (по номеру из current_buf либо по имени).
  -- Раньше использовался bufnr("#"..title): альтернативный файл окна может
  -- случайно называться так же, а :file на уже названном буфере падал с E95.
  local buf = find_own_buf()
  if buf then
    -- Буфер жив: показываем его в текущем окне (без :file и без новых буферов).
    if vim.api.nvim_win_get_buf(0) ~= buf then
      vim.api.nvim_win_set_buf(0, buf)
    end
  else
    -- Нашего буфера нет — создаём новый чистый.
    -- Если текущий буфер безымянный и пустой — переиспользуем его (как :enew),
    -- иначе открываем новый сплит, чтобы не «съе» пользовательский буфер.
    local cur = vim.api.nvim_get_current_buf()
    local shown_elsewhere = false
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if w ~= 0 and vim.api.nvim_win_get_buf(w) == cur then
        shown_elsewhere = true
        break
      end
    end
    local reusable = vim.bo[cur].buftype == ""
      and vim.fn.bufname(cur) == ""
      and #vim.api.nvim_buf_get_lines(cur, 0, -1, false) <= 1
      and not shown_elsewhere
    if reusable then
      buf = cur
    else
      vim.cmd("split | enew")
      buf = vim.api.nvim_get_current_buf()
    end
    current_buf = buf
    -- Имя задаём через pcall: если вдруг буфер с таким именем уже есть
    -- (например, пользователь сам назвал буфер "Projects"), просто работаем
    -- без имени — это лучше, чем падение с E95.
    pcall(vim.api.nvim_buf_set_name, buf, title)
  end

  vim.bo[buf].modifiable = true
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
  -- Ставим один раз на наш буфер; обработчики читают актуальные meta/buf
  -- через upvalue-переменные, которые обновляются при каждой перерисовке.
  -----------------------------------------------------------------
  active_meta = meta

  if not maps_installed[buf] then
    maps_installed[buf] = true

    local function current_dir()
      local lnum = vim.api.nvim_win_get_cursor(0)[1]
      return active_meta and active_meta[lnum]
    end

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

    local function delete_project()
      local dir = current_dir()
      if dir then
        M.remove(dir)
        M.show_window() -- перерисовать
      end
    end

    local keyopts = { noremap = true, silent = true, nowait = true }

    vim.keymap.set("n", "<CR>", function()
      local dir = current_dir()
      if dir then open_project(dir) end
    end, vim.tbl_extend("error", keyopts, { buffer = buf, desc = "Open project" }))

    vim.keymap.set("n", "o", function()
      local dir = current_dir()
      if dir then open_project(dir) end
    end, vim.tbl_extend("error", keyopts, { buffer = buf, desc = "Open project" }))

    vim.keymap.set("n", "x", delete_project,
      vim.tbl_extend("error", keyopts, { buffer = buf, desc = "Delete from list" }))
    vim.keymap.set("n", "<DEL>", delete_project,
      vim.tbl_extend("error", keyopts, { buffer = buf, desc = "Delete from list" }))
    vim.keymap.set("n", "d", delete_project,
      vim.tbl_extend("error", keyopts, { buffer = buf, desc = "Delete from list" }))

    vim.keymap.set("n", "a", function()
      -- vim.input нельзя вызывать прямо из ключевой последовательности надёжно —
      -- оборачиваем в vim.schedule (чинит «нажатие a ничего не делает» на некоторых сборках).
      vim.schedule(function()
        local input = vim.fn.input("Add directory: ", vim.fn.getcwd() .. "/", "dir")
        if input and input ~= "" then
          M.add(input)
          M.show_window()
        end
      end)
    end, vim.tbl_extend("error", keyopts, { buffer = buf, desc = "Add project" }))

    vim.keymap.set("n", "q", function()
      vim.cmd("bdelete!")
    end, vim.tbl_extend("error", keyopts, { buffer = buf, desc = "Close window" }))

    -- Закрытие окна по Escape тоже
    vim.keymap.set("n", "<Esc>", function()
      vim.cmd("bdelete!")
    end, vim.tbl_extend("error", keyopts, { buffer = buf }))
  end

  -- При выходе из буфера сбрасываем modifiable, чтобы не мешал bdelete,
  -- и забываем номер буфера / карту нажатых клавиш.
  if not augroup_defined then
    augroup_defined = true
    vim.api.nvim_create_autocmd("BufUnload", {
      group = vim.api.nvim_create_augroup("DirobilProjects", { clear = true }),
      pattern = M.config.window_title,
      callback = function(ev)
        if vim.api.nvim_buf_is_valid(ev.buf) then
          pcall(function() vim.bo[ev.buf].modifiable = true end)
        end
        if ev.buf == current_buf then
          current_buf = nil
        end
        maps_installed[ev.buf] = nil
      end,
    })
  end
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

  vim.api.nvim_create_user_command("ProjectList", function()
    M.show_window()
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
