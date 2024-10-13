-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("kk_" .. name, { clear = true })
end

-- vim.api.nvim_create_autocmd("TermOpen", {
--   group = augroup("terminal"),
--   callback = function()
--     local buf = vim.api.nvim_get_current_buf()
--     setup_terminal(buf)
--   end,
-- })


vim.api.nvim_create_autocmd("FileType", {
  group = augroup("dap_keymap"),
  pattern = 'dap-repl',
  callback = function()
    vim.keymap.set("n", "cc", "A<C-u>", { buffer = true })
    vim.keymap.set("i", "<C-w>h", "<Esc><C-w>h", { buffer = true })
    vim.keymap.set("i", "<C-w>n", "<Esc><C-w>j", { buffer = true })
    vim.keymap.set("i", "<C-w>e", "<Esc><C-w>k", { buffer = true })
    vim.keymap.set("i", "<C-w>i", "<Esc><C-w>l", { buffer = true })
    vim.keymap.set("t", "jj", "<C-\\><C-n>", { buffer = true })
    vim.api.nvim_set_option_value("number", false, { win = vim.api.nvim_get_current_win() })
    vim.keymap.set("i", "<CR>", function() -- NOTE:测试一下能用feedkeys模拟一连串键入事件
      local key = vim.api.nvim_replace_termcodes("<CR><ESC>?dap><CR>nzz:noh<CR>", true, false, true)
      print("key: ", key)
      vim.api.nvim_feedkeys(key, "n", false)
    end, {buffer = true, desc = "go back to last command"})
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("dap_float"),
  pattern = 'dap-float',
  callback = function()
    vim.keymap.set("n", "q", ":close<cr>", { buffer = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("dap-terminal"),
  pattern = 'dap-terminal',
  callback = function()
    vim.keymap.set("t", "<C-w>h", "<C-\\><C-N><C-w>h", { buffer = true })
    vim.keymap.set("t", "<C-w>n", "<C-\\><C-N><C-w>j", { buffer = true })
    vim.keymap.set("t", "<C-w>e", "<C-\\><C-N><C-w>k", { buffer = true })
    vim.keymap.set("t", "<C-w>i", "<C-\\><C-N><C-w>l", { buffer = true })
  end,
})



vim.api.nvim_create_autocmd("FileType", {
  group = augroup("qflist"),
  pattern = 'qf',
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.cmd[[set modifiable]]
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    local buffers = vim.api.nvim_list_bufs()
    for i, buf in ipairs(buffers) do
      local name = vim.api.nvim_get_option_value('filetype', {buf = buf})
      if name == 'qf' then
        vim.cmd(string.format(":%sbd!", buf))
      end
    end
  end,
  desc = "ignore qf buffer",
})

-- vim.api.nvim_create_autocmd({"WinEnter","BufWinEnter"}, {
--   group = augroup("dap_repl_enter"),
--   callback = function(args)
--     local buf = vim.api.nvim_get_current_buf()
--     local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
--     if ft == 'dap-repl' then
--       -- vim.print("dap-repal enter", args) -- NOTE: debug the triggered event
--       vim.cmd[[startinsert]]
--     end
--   end,
-- })

--
-- vim.api.nvim_create_autocmd({"WinLeave", "BufWinLeave"}, {
--   group = augroup("dap_repl_leave"),
--   callback = function()
--     local buf = vim.api.nvim_get_current_buf()
--     local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
--     if ft == 'dap-repl' then
--       -- print("dap-repal leave")
--       vim.cmd([[stopinsert]])
--     end
--   end,
-- })

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

vim.api.nvim_del_augroup_by_name("lazyvim_last_loc")
vim.api.nvim_create_autocmd("BufReadPost",{
  group = augroup("last_loc"),
  desc="Return to last edit position when opening files",
  callback=function ()
    if vim.fn.line("'\"")>0 and vim.fn.line("'\"")<=vim.fn.line("$") then
      vim.cmd [[ exe "normal! g`\"" ]]
    end
  end
})

-- vim.api.nvim_create_autocmd("CursorMoved", {
--   callback = function()
--     vim.cmd[[noautocmd normal! zz]]
--   end,
-- })
