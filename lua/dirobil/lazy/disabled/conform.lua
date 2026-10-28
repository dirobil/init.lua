-- Conform.nvim — форматирование при сохранении (как Format on Save в VS Code).
-- Pure Lua; форматтеры (prettier, stylua, black...) ставятся через :Mason или npm/pip.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    { "<leader>f", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format buffer" },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "black" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      json = { "jq" },
      sh = { "shfmt" },
    },
    format_on_save = { timeout_ms = 500, lsp_fallback = true },
  },
}
