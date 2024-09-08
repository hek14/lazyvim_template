-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local group_terminal_buffer = vim.api.nvim_create_augroup("kk-terminal", { clear = true })
local function setup_terminal(buf)
  vim.api.nvim_set_option_value("number", false, { win = vim.api.nvim_get_current_win() })
  vim.cmd([[startinsert]])
  vim.keymap.set("n", "cc", "a<C-u>", { buffer = true })
  vim.keymap.set("i", "<C-w>h", "<Esc><C-w>h", { buffer = true })
  vim.keymap.set("i", "<C-w>n", "<Esc><C-w>j", { buffer = true })
  vim.keymap.set("i", "<C-w>e", "<Esc><C-w>k", { buffer = true })
  vim.keymap.set("i", "<C-w>i", "<Esc><C-w>l", { buffer = true })
  vim.keymap.set("t", "jj", "<C-\\><C-n>", { buffer = true })
  vim.api.nvim_create_autocmd("BufLeave", {
    group = group_terminal_buffer,
    callback = function()
      vim.cmd([[stopinsert]])
    end,
    buffer = buf,
    once = true,
  })
end

vim.api.nvim_create_autocmd("TermOpen", {
  group = group_terminal_buffer,
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    setup_terminal(buf)
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = group_terminal_buffer,
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)
    local buf_type = vim.api.nvim_get_option_value("buftype", { buf = buf })
    local _match = function()
      return #vim.fn.matchstr(buf_type, "terminal") > 0 or #vim.fn.matchstr(name, [[\(^term://\|dap-repl\)]]) > 0
    end
    if _match() then
      setup_terminal(buf)
    end
  end,
})

vim.g.last_word = ""
vim.g.last_win = nil
vim.api.nvim_create_autocmd("WinLeave", {
  callback = function()
    pcall(function()
      local buf = vim.api.nvim_get_current_buf()
      local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
      if #vim.fn.matchstr(ft, [[\(Telescope\|Prompt\)]]) > 0 then
        return
      end
      vim.g.last_word = vim.fn.expand("<cword>")
      vim.cmd(string.format(":call setreg('c','%s')", vim.g.last_word))

      local win = vim.api.nvim_get_current_win()
      local config = vim.api.nvim_win_get_config(win)
      if config.relative == "" then
        vim.g.last_win = win
      end
    end)
  end,
})
vim.keymap.set("n", "<C-w>l", function()
  pcall(vim.api.nvim_set_current_win, vim.g.last_win)
end, { desc = "focus on last window" })
