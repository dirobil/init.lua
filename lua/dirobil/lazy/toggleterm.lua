-- Встроенные терминалы/плавающие окна в стиле VS Code Integrated Terminal.
--
-- Важно про build: toggleterm содержит C-расширение (snakemind, таймер для
-- shell-интеграции). На машинах без компилятора (частый случай на Windows и
-- в Termux без `pkg install clang`) сборка падает, но сам плагин полностью
-- работоспособен и без неё. Поэтому build обёрнут в pcall и не блокирует
-- установку остальных плагинов.
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  build = function()
    -- Не считаем отсутствие компилятора критичной ошибкой.
    pcall(vim.cmd, "ToggleTermBuildSnakemind")
  end,
  keys = {
    { "<C-\\>", [[<Cmd>ToggleTerm direction=horizontal<CR>]], mode = { "n", "t" }, desc = "Terminal: toggle bottom" },
    { "<leader>tf", [[<Cmd>lua _FLOAT_TERM():toggle()<CR>]], desc = "Terminal: floating" },
    { "<leader>tg", [[<Cmd>lua _GIT_TERM():toggle()<CR>]], desc = "Terminal: git (lazygit/neogit CLI)" },
  },
  config = function()
    require("toggleterm").setup({
      size = 12, -- строк для горизонтального терминала
      open_mode = "split",
      direction = "horizontal",
      shell = vim.o.shell, -- bash на Windows (WSL/Git-Bash), zsh/sh в Termux
      close_on_exit = true,
      auto_scroll = true,
      persist_size = true,
      hide_numbers = true,
      terminal_mappings = true, -- <Esc> выходит из терминала в normal-режим
      start_insert = true,      -- сразу вставать в insert-режим (как в VS Code)
      -- Тонкая грань между окнами терминала
      highlights = {
        Normal = { link = "Normal" },
        NormalNC = { link = "NormalNC" },
        SignColumn = { link = "SignColumn" },
      },
    })

    -- Ленивые глобальные конструкторы: объекты создаются только при первом
    -- нажатии клавиши (v:lua-колбэки требуют глобалов вида _NAME()).
    _G._FLOAT_TERM = setmetatable({}, {
      __call = function(self)
        if not self.term then
          self.term = require("toggleterm.terminal").Terminal:new({
            cmd = vim.o.shell,
            dir = "cwd",
            direction = "float",
            float_opts = { border = "curved" },
          })
        end
        return self.term
      end,
    })

    _G._GIT_TERM = setmetatable({}, {
      __call = function(self)
        if not self.term then
          local cmd = "bash"
          if vim.fn.executable("lazygit") == 1 then
            cmd = "lazygit"
          elseif vim.fn.has("win32") == 1 then
            cmd = "git status" -- на Windows без lazygit — хотя бы статус
          else
            cmd = "sh -c 'git status; exec sh'"
          end
          self.term = require("toggleterm.terminal").Terminal:new({
            cmd = cmd,
            dir = "git_dir",
            direction = "float",
            float_opts = { border = "curved" },
          })
        end
        return self.term
      end,
    })
  end,
}
