# dirobil/init.lua — Neovim конфиг в стиле VS Code

Lua-конфиг Neovim с lazy.nvim. Работает на **Windows** и **Termux (Android)**.
Включает: файловое дерево, поиск, LSP+автодополнение, Git-интерфейс, терминал,
форматирование, тему Catppuccin и собственный плагин недавних проектов.

## Состав

| Плагин | Назначение | Аналог в VS Code |
|---|---|---|
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | дерево файлов (netrw отключён) | Explorer |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | поиск файлов/grep/буферов | Ctrl+P / Ctrl+Shift+F |
| [catppuccin](https://github.com/catppuccin/nvim) | тема оформления | темы |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | иконки файлов | file icons |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | встроенные терминалы | Integrated Terminal |
| [neogit](https://github.com/NeogitOrg/neogit) + gitsigns + diffview | Git: статус, staging, коммит | Source Control |
| mason + lspconfig + nvim-cmp + LuaSnip | LSP, автодополнение, сниппеты | IntelliSense |
| conform.nvim + nvim-lint | форматирование при сохранении, линтинг | Format on Save / ESLint |
| treesitter | точная подсветка синтаксиса | TextMate grammars |
| lualine, which-key, Comment.nvim | статус-бар, подсказки клавиш, комментарии | status bar и т.п. |
| `dirobil.projects` (локальный) | недавние проекты: `<leader>pl` | Recent Projects |

## Требования

**Windows**
- Neovim ≥ 0.9 (рекомендуется; на 0.7/0.8 neogit автоматически зафиксируется на v1.4.4)
- `git` (Git for Windows), `ripgrep` (`winget install BurntSushi.ripgrep.MSVC`)
- Для treesitter-парсеров и build-шагов toggleterm: любой C-компилятор
  (`winget install zig.zig` или Visual Studio Build Tools + `choco install make`).
  Без компилятора конфиг запускается — просто не соберутся парсеры/snakemind.
- Шрифт Nerd Font для иконок (например, JetBrainsMono Nerd Font).

**Termux**
```
pkg install neovim git ripgrep nodejs termux-api
# опционально (treesitter/snakemind): pkg install clang make
```
Шрифт: `pkg install font-jetbrains-mono-nerd` либо скопируйте .ttf в `~/.termux/font.ttf`.

## Установка

```
git clone https://github.com/dirobil/init.lua.git ~/.config/nvim   # Termux
git clone https://github.com/dirobil/init.lua.git %LOCALAPPDATA%\nvim  # Windows
```

При первом запуске lazy.nvim сам установит все плагины. LSP-серверы и
форматтеры ставятся вручную через `:Mason` (чтобы не качать лишнее на мобильном трафике).

## Горячие клавиши (основное)

| Клавиши | Действие |
|---|---|
| `<leader>e` / `<C-h/j/k/l>` | дерево файлов / навигация по сплитам |
| `<leader>ff` `fg` `fb` `fr` | telescope: файлы / grep / буферы / недавние |
| `<leader>pl` `pa` `pd` | проекты: список / добавить / удалить |
| `<leader>gs` `gc` `gp` `gP` `gb` | neogit: статус / коммит / pull / push / branch |
| `<leader>hs` `hr` `hb` | gitsigns: stage/reset hunk, blame |
| `<C-\>` / `<leader>tf` / `<leader>tg` | терминал снизу / плавающий / git-терминал |
| `gd` `gr` `K` `<leader>rn` `<leader>ca` | LSP: definition / references / hover / rename / code action |
| `<Tab>`/`<S-Tab>` | переключение буферов / пункты автодополнения |
| `<leader>f` | форматировать текущий буфер |
| `<Esc>` | снять подсветку поиска |

Полный список подсказок — по `<leader>` (which-key).

## Примечания про netrw

netrw полностью отключён (`lua/dirobil/set.lua`: `loaded_netrw`,
`loaded_netrwPlugin`), поэтому nvim-tree работает без конфликтов.
Наш `dirobil.projects` при переходе в проект открывает nvim-tree, если он
загружен; иначе Telescope; иначе запасной вариант.
