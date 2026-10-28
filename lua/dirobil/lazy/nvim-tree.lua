-- Файловое дерево в стиле VS Code Explorer. Pure Lua.
-- netrw отключён в lua/dirobil/set.lua (g:loaded_netrw / g:netrw_plugin),
-- поэтому конфликтов между деревом и netrw не будет.
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Explorer: toggle tree" },
    { "<leader>rf", "<cmd>NvimTreeFindFile<CR>", desc = "Explorer: reveal current file" },
  },
  config = function()
    local ok, nvim_tree = pcall(require, "nvim-tree")
    if not ok then
      return
    end

    local has_devicons = pcall(require, "nvim-web-devicons")

    nvim_tree.setup({
      sort_by = "case_sensitive",
      view = {
        width = 30,
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
            git = true,
          },
        },
      },
      filter = {
        -- .git скрыт из дерева; node_modules остаётся видимым
        custom = { "\\.git$" },
        exclude = { "node_modules" },
      },
      actions = {
        open_file = {
          window_picker = { enable = false }, -- всегда открывать в текущем окне
          quit_on_open = false,
        },
      },
      filesystem_watchers = {
        ignore_dirs = { "node_modules" }, -- меньше нагрузки на Windows/Termux
      },
      update_focused_file = {
        enable = true,
        update_cwd = false,
      },
      diagnostics = {
        enable = true, -- требует LSP; без него просто молча ничего не подсвечивает
      },
    })
  end,
}
