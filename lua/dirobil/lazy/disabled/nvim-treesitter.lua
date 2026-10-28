-- Treesitter — точная подсветка/indentation. Требует C-компилятор для сборки
-- парсеров: Windows — через `winget install zig.zig` или MSVC + `choco install make`,
-- Termux — `pkg install clang`. Без компилятора плагины просто не соберут
-- отдельные parsers (подсветка деградирует до regex-syntax, конфиг работает).
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ok, ts = pcall(require, "nvim-treesitter.configs")
    if not ok then return end
    ts.setup({
      ensure_installed = { "lua", "vim", "vimdoc", "bash", "python", "json", "yaml", "toml", "markdown", "markdown_inline" },
      auto_install = false, -- включите вручную, когда есть компилятор
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
