-- Neogit — Magit-подобный Git-интерфейс (статус, staging, коммит, log).
-- https://github.com/NeogitOrg/neogit
--
-- Требования: git (Windows: Git for Windows; Termux: pkg install git).
-- Новые релизы neogit требуют Neovim >= 0.9. Чтобы конфиг работал и на более
-- старых сборках, закреплён последний tag, совместимый с nvim 0.7/0.8 (v1.4.4).
-- Если у вас Neovim >= 0.9 — поменяйте version на "*" для свежих фич.
return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim", -- просмотр diff/истории из буферов neogit
  },
  -- nvim 0.7/0.8 -> v1.4.4 (последний совместимый tag); nvim >= 0.9 -> последний релиз.
  version = (vim.version().major == 0 and vim.version().minor < 9) and "v1.4.4" or "*",
  cmd = { "Neogit", "NeogitCommitMessage", "NeogitResetState" },
  keys = {
    { "<leader>gs", "<cmd>Neogit kind=split<CR>", desc = "Git: status (neogit)" },
    { "<leader>gc", "<cmd>Neogit commit<CR>", desc = "Git: commit" },
    { "<leader>gp", "<cmd>Neogit pull<CR>", desc = "Git: pull" },
    { "<leader>gP", "<cmd>Neogit push<CR>", desc = "Git: push" },
    { "<leader>gb", "<cmd>Neogit branch<CR>", desc = "Git: branch" },
  },
  config = function()
    local ok, neogit = pcall(require, "neogit")
    if not ok then
      return
    end

    neogit.setup({
      disable_context_highlighting = false,
      disable_commit_confirmation = false,
      auto_refresh = true,
      signs = {
        -- Односимвольные ASCII-знаки: гарантированно отображаются и на
        -- Windows-консоли, и в Termux даже без Nerd Font.
        difference = { added = "+", deleted = "-", changed = "~" },
        view = { closed = ">", open = "v" },
      },
      integrations = {
        diffview = true, -- из буферов neogit открывать diff через diffview
      },
    })
  end,
}
