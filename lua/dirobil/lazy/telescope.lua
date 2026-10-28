-- Telescope — поиск файлов/строк/буферов в стиле Ctrl+P / Ctrl+Shift+F.
return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- fzf-native требует make+C-компилятор; оставляем опциональным:
    -- { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files (Ctrl+P)" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Grep in project (Ctrl+Shift+F)" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Switch buffer" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help" },
    { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
    { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "LSP diagnostics" },
  },
  config = function()
    local ok, telescope = pcall(require, "telescope")
    if not ok then
      return
    end

    telescope.setup({
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top", width = 0.95, height = 0.85 },
        sorting_strategy = "ascending",
        path_display = { "smart" },
        file_ignore_patterns = { "%.git/", "node_modules/", "__pycache__/", "%.lock$" },
      },
      pickers = {
        find_files = { hidden = false },
      },
    })

    -- pcall на случай, если fzf-native всё же раскомментировали и собрали
    pcall(telescope.load_extension, "fzf")
  end,
}
