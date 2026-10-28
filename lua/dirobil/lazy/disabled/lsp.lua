-- LSP + автодополнение + линтинг/форматирование.
-- Серверы ставит mason.nvim: Windows и Termux поддерживаются официально
-- (в Termux нужны nodejs: pkg install nodejs).
return {
  -- Менеджер установок LSP/линтеров/форматтеров
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate", -- в Termux/Windows просто скачивает бинарники, компилятор не нужен
    config = function()
      require("mason").setup({
        PATH = "append",
        ui = { border = "single" },
      })
    end,
  },
  -- Мост mason -> nvim-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require("mason-lspconfig").setup({
        ensure_installed = {}, -- пустой: ставьте серверы вручную через :Mason (экономия трафика на Termux)
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({ capabilities = capabilities })
          end,
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      vim.diagnostic.config({
        virtual_text = true,
        signs = { text = { "[E]", "[W]", "[I]", "[H]" } }, -- ASCII, видно без Nerd Font
        severity_sort = true,
        float = { border = "single" },
      })
      -- LSP keymaps появятся после подключения первого сервера
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local map = vim.keymap.set
          map("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Goto definition" })
          map("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "References" })
          map("n", "gI", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Implementation" })
          map("n", "<leader>D", vim.lsp.buf.type_definition, { buffer = bufnr, desc = "Type definition" })
          map("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename symbol" })
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
          map("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover docs" })
          map("i", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "Signature help" })
          map("n", "[d", vim.diagnostic.goto_prev, { buffer = bufnr, desc = "Prev diagnostic" })
          map("n", "]d", vim.diagnostic.goto_next, { buffer = bufnr, desc = "Next diagnostic" })
          map("n", "<leader>e", vim.diagnostic.open_float, { buffer = bufnr, desc = "Line diagnostics" })
          map("n", "<leader>q", vim.diagnostic.setloclist, { buffer = bufnr, desc = "Diagnostics to loclist" })
        end,
      })
    end,
  },
  -- Движок автодополнения
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
        window = { completion = { border = "single" }, documentation = { border = "single" } },
      })
    end,
  },
  -- Линтинг (не блокирует старт: lint-on-save, серверы качаются через :Mason)
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "flake8" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          pcall(lint.try_lint)
        end,
      })
    end,
  },
}
