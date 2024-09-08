-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
opt.expandtab = true -- NOTE:In Insert mode: Use the appropriate number of spaces to insert a <Tab>
-- opt.tabstop = 4 -- NOTE:Number of spaces that a <Tab> in the file counts for
-- opt.shiftwidth = 4 -- NOTE: indent spaces count
opt.autoindent = true
opt.cursorline = false
opt.relativenumber = false
