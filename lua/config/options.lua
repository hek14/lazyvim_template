-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
local g = vim.g
opt.expandtab = true -- NOTE:In Insert mode: Use the appropriate number of spaces to insert a <Tab>
-- opt.tabstop = 4 -- NOTE:Number of spaces that a <Tab> in the file counts for
-- opt.shiftwidth = 4 -- NOTE: indent spaces count
opt.autoindent = true
opt.cursorline = false
opt.relativenumber = false

-- Set to "basedpyright" to use basedpyright instead of pyright.
-- g.lazyvim_python_lsp = "basedpyright"
g.lazyvim_python_lsp = "pylance"
-- g.lazyvim_python_lsp = "jedi_language_server"

g.lazyvim_python_ruff = "ruff"
g.autoformat = false
