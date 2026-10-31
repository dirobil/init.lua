-- Файловое дерево в стиле VS Code Explorer. Pure Lua.
-- netrw отключён в lua/dirobil/set.lua (g:loaded_netrw / g:netrw_plugin),
-- поэтому конфликтов между деревом и netrw не будет.
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Explorer: toggle tree" },
--    { "<leader>rf", "<cmd>NvimTreeFindFile<CR>", desc = "Explorer: reveal current file" },
  },
  config = function()
    local ok, nvim_tree = pcall(require, "nvim-tree")
    if not ok then
      return
    end

    local has_devicons = pcall(require, "nvim-web-devicons")

    -- Изменить мапы клавиш
--    local function on_attach(bufnr)
--      local api = require("nvim-tree.api")
--
--      local function opts(desc)
--        return {
--          desc = "NvimTree: " .. desc,
--          buffer = bufnr,
--          noremap = true,
--          silent = true,
--          nowait = true,
--        }
--      end
--
--      -- Оставляем дефолтные клавиши
--      api.config.mappings.default_on_attach(bufnr)
--
--      -- Более удобные клавиши для Termux
--      vim.keymap.set("n", "v", api.node.open.vertical, opts("Открыть вертикально"))
--      vim.keymap.set("n", "s", api.node.open.horizontal, opts("Открыть горизонтально"))
--      vim.keymap.set("n", "t", api.node.open.tab, opts("Открыть в новой вкладке"))
--      vim.keymap.set("n", "q", api.tree.close, opts("Закрыть дерево"))
--      vim.keymap.set("n", "?", api.tree.toggle_help, opts("Справка"))
--
--      -- Если хочешь полностью убрать старые неудобные клавиши:
--      -- раскомментируй строки ниже
--      --
--      -- pcall(vim.keymap.del, "n", "<C-v>", { buffer = bufnr })
--      -- pcall(vim.keymap.del, "n", "<C-x>", { buffer = bufnr })
--      -- pcall(vim.keymap.del, "n", "<C-t>", { buffer = bufnr })
--    end 

    nvim_tree.setup({
      sort_by = "case_sensitive",

      view = {
        width = 30, -- termux можно изменить
        side = "left",
        relativenumber = false,
      },

      renderer = {
        group_empty = true,
        icons = {
          show = {
            file = has_devicons,
            folder = has_devicons,
            folder_arrow = true,
--            git = true,
          },
        },
      },

      --filters = {
      --  -- .git скрыт из дерева; node_modules остаётся видимым
      --  custom = { "^\\.git$" },
      --  exclude = { "node_modules" },
      --},

      actions = {
        open_file = {
          window_picker = { enable = false }, -- всегда открывать в текущем окне
          quit_on_open = true, -- закрывать при открытие файла
        },
      },

      filesystem_watchers = {
--        ignore_dirs = { "node_modules", ".git", ".cache", "build", "dist", ".next", ".gradle", "target" }, -- меньше нагрузки на Windows/Termux
        enable = false, -- отключаем слежение за файлами
      },

      update_focused_file = {
        enable = true, -- показывать директорию файла
        update_root = true, -- изменить корень
      },
--      diagnostics = {
--        enable = true, -- требует LSP; без него просто молча ничего не подсвечивает
--      },
    -- Изменить мапы клавиш
--      on_attach = on_attach,
    })
  end,
}
