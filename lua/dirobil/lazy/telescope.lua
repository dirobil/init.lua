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
        { "<leader>fb", "<cmd>Telescope buffers previewer=false<CR>", desc = "Switch buffer" },
        { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help" },
        { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
        { "<leader>fj", function()
            require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ")}) 
        end, 
        desc = "Grep (Input)"
        },
    },
    config = function()
        local is_mobile = vim.o.columns < 80 or vim.o.lines < 30

        require('telescope').setup({
            defaults = {
                layout_strategy = is_mobile and "vertical" or "horizontal",
                layout_config = is_mobile
                    and { prompt_position = "top", width = 0.98, height = 0.95 }
                    or { prompt_position = "top", width = 0.95, height = 0.85 },
                sorting_strategy = "ascending",
                path_display = { "smart" },
                file_ignore_patterns = { "%.git/", "node_modules/", "__pycache__/", "%.lock$" },
            },
            pickers = is_mobile and {
                find_files = { previewer = false },
                live_grep = { previewer = false },
                help_tags = { previewer = false },
                oldfiles = { previewer = false },
                grep_string = { previewer = false },
            } or {},
--            pickers = {
--                find_files = { hidden = false },
--            },
        })

        local preview_utils = require("telescope.previewers.utils")
        preview_utils.ts_highlighter = function(bufnr, ft)
            local lang = vim.treesitter.language.get_lang(ft) or ft
            if not lang or lang == "" then
                return false
            end

            return pcall(vim.treesitter.start, bufnr, lang)
        end

    end
}

