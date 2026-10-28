local P = require("dirobil.projects")
P.setup()
vim.cmd("ProjectAdd /tmp/projB")
vim.cmd("ProjectList")
print("cwd:", vim.fn.getcwd())
print("bufname percent:", vim.fn.bufname("%"))
vim.api.nvim_win_set_cursor(0, { 2, 0 })
print("lnum:", vim.api.nvim_win_get_cursor(0)[1])

-- прямой вызов удаления через API
P.remove(P.get_list()[1])
print("after direct remove:", vim.inspect(P.get_list()))

-- перерисовка окна (должна работать без ошибок)
P.show_window()
print("window lines:", #vim.api.nvim_buf_get_lines(0, 0, -1, false))

-- найдём keymap x и вызовем callback напрямую на пустом списке (не должно упасть)
local b = vim.api.nvim_get_current_buf()
for _, m in ipairs(vim.api.nvim_buf_get_keymap(b, "n")) do
  if m.lhs == "x" then
    print("calling x callback at lnum", vim.api.nvim_win_get_cursor(0)[1])
    local ok, err = pcall(m.callback)
    print("callback ok:", ok, err)
  end
end
print("final list:", vim.inspect(P.get_list()))
