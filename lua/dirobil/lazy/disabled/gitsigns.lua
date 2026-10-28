-- Gitsigns — знаки diff на колонке знаков и построчные git-действия.
-- Дополняет neogit: быстрый inline-статус без открытия окна Git.
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      signs = {
        -- ASCII-знаки: видно без Nerd Font на Windows/Termux
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      signcolumn = true,
      numhl = false,
      linehl = false,
      word_diff = false,
      watch_gitdir = { follow_files = true },
      current_line_blame = false, -- включить, если нужен blame у курсора
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = vim.keymap.set
        map("n", "]c", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gs.next_hunk() end)
          return "<Ignore>"
        end, { expr = true, buffer = bufnr, desc = "Next git hunk" })
        map("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gs.prev_hunk() end)
          return "<Ignore>"
        end, { expr = true, buffer = bufnr, desc = "Prev git hunk" })
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { buffer = bufnr, desc = "Select hunk" })
        map("n", "<leader>hs", gs.stage_hunk, { buffer = bufnr, desc = "Stage hunk" })
        map("n", "<leader>hr", gs.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
        map("n", "<leader>hp", gs.preview_push, { buffer = bufnr, desc = "Preview push" })
        map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { buffer = bufnr, desc = "Stage selected hunk" })
        map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { buffer = bufnr, desc = "Reset selected hunk" })
        map("n", "<leader>hS", gs.stage_buffer, { buffer = bufnr, desc = "Stage buffer" })
        map("n", "<leader>hu", gs.undo_stage_hunk, { buffer = bufnr, desc = "Undo stage hunk" })
        map("n", "<leader>hR", gs.reset_buffer, { buffer = bufnr, desc = "Reset buffer" })
        map("n", "<leader>hb", gs.blame_line, { buffer = bufnr, desc = "Blame line" })
        map("n", "<leader>tb", gs.toggle_current_line_blame, { buffer = bufnr, desc = "Toggle line blame" })
        map("n", "<leader>hd", gs.diffthis, { buffer = bufnr, desc = "Diff against index" })
        map("n", "<leader>td", gs.toggle_deleted, { buffer = bufnr, desc = "Toggle deleted lines preview" })
      end,
    })
  end,
}
