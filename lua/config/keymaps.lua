-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local opt = { silent = true, noremap = true }
-- hjkl
map({ "n", "x", "o" }, "H", "^", opt)
map({ "n", "x", "o" }, "n", "j", opt)
map({ "n", "x", "o" }, "N", "j", opt)
map({ "n", "x", "o" }, "e", "k", opt)
map({ "n", "x", "o" }, "E", "K", opt)
map({ "n", "x", "o" }, "i", "l", opt)
map({ "n", "x", "o" }, "I", "$", opt)
map({ "n", "x", "o" }, "gn", "gj", opt)
map({ "n", "x", "o" }, "ge", "gk", opt)
-- n
map({ "n", "x", "o" }, "k", "n", opt)
map({ "n", "x", "o" }, "K", "N", opt)
-- u
map({ "n", "x", "o" }, "l", "u", opt)
map({ "n", "x", "o" }, "L", "U", opt)
-- i
map({ "n", "x", "o" }, "u", "i", opt)
map({ "n", "x", "o" }, "U", "I", opt)
-- e
map({ "n", "x", "o" }, "j", "e", opt)
map({ "n", "x", "o" }, "J", "E", opt)
-- windows
map({ "n" }, "<C-w>n", "<C-w>j", opt)
map({ "n" }, "<C-w>e", "<C-w>k", opt)
map({ "n" }, "<C-w>i", "<C-w>l", opt)
map({ "n" }, "<C-w><C-n>", "<C-w><C-j>", opt)
map({ "n" }, "<C-w><C-e>", "<C-w><C-k>", opt)
map({ "n" }, "<C-w><C-i>", "<C-w><C-l>", opt)
-- emacs
map("i", "<C-d>", "<Del>", opt)
map("i", "<C-h>", "<Backspace>", opt)
map("i", "<C-b>", "<Left>", opt)
map("i", "<C-f>", "<Right>", opt)
map("i", "<C-a>", "<ESC>^i", opt)
map("i", "<C-e>", "<End>", opt)
map("i", "<C-j>", "<Down>", opt)
map("i", "<C-k>", "<Up>", opt)

vim.keymap.del("n", "<C-h>")
vim.keymap.del("n", "<C-j>")
vim.keymap.del("n", "<C-k>")
vim.keymap.del("n", "<C-l>")
map("n", "<C-j>", "J", opt)

vim.cmd([[highlight MyGroup0 ctermbg=green guibg=green]])
vim.cmd([[highlight MyGroup1 ctermbg=red guibg=red]])
vim.cmd([[highlight MyGroup2 ctermbg=blue guibg=blue]])
vim.cmd([[highlight MyGroup3 ctermbg=yellow guibg=yellow]])
local match_count = 1
local match_meta = {}
map("n", "g.", function()
  if vim.v.count1 > 1 then
    -- clear all
    for k, v in pairs(match_meta) do
      vim.fn.matchdelete(v)
    end
    match_meta = {}
  else
    -- toggle current
    local cw = vim.fn.expand("<cword>")
    if match_meta[cw] then
      -- clear current
      vim.fn.matchdelete(match_meta[cw])
      match_meta[cw] = nil
    else
      -- highlight current
      local id = vim.fn.matchadd(string.format("MyGroup%s", match_count), string.format("\\<%s\\>", cw))
      match_meta[cw] = id
      match_count = match_count + 1
      match_count = match_count % 4
    end
  end
end)
map("n", "g/", [[:execute "match Visual /" . @/ . "/"<CR>]])

-- alt-keys
-- https://vi.stackexchange.com/questions/2350/how-to-map-alt-key
local map_alt = function(mode, key, value, opt)
  opt = opt or {}
  local character = vim.fn.matchlist(key, [[<M-\(.*\)>]])
  if #character > 0 then
    local char = character[2]
    vim.cmd(string.format([[set %s=\e%s]], key, char))
    map(mode, key, value, opt)
  end
end
map_alt("i", "<M-j>", "<CMD>move +1<CR>") -- move line down
map_alt("i", "<M-k>", "<CMD>move -2<CR>") -- move line up
map_alt("i", "<M-f>", "<Esc>lwi", opt) -- forward-word
map_alt("i", "<M-b>", "<Esc>bi", opt) -- backward-word

vim.keymap.del("t", "<Esc><Esc>")
vim.keymap.del("t", "<C-h>")
vim.keymap.del("t", "<C-j>")
vim.keymap.del("t", "<C-k>")
vim.keymap.del("t", "<C-l>")

local range_search = function()
  local language_tree = vim.treesitter.get_parser(0)
  language_tree:parse()
  local cw = vim.fn.expand("<cword>")
  local pattern = vim.fn.input("Search in current function: ", cw)
  local ts_utils = require("nvim-treesitter.ts_utils")
  local node = ts_utils.get_node_at_cursor(0)
  if not node then
    return
  end

  local root = ts_utils.get_root_for_node(node)
  local range_start = nil
  local range_end = nil
  while node and node ~= root do
    local _match = function()
      return #vim.fn.matchstr(node:type(), [[\(function\|method\)]]) > 0
    end
    if _match() then
      range_start, _, range_end, _ = node:range()
      break
    else
      node = node:parent()
    end
  end
  if range_start and range_end then
    vim.print({ range_start = range_start, range_end = range_end })
    vim.cmd(string.format([[/\%%>%sl\%%<%sl%s]], range_start + 1, range_end + 1, pattern))
  else
    vim.cmd(string.format("/%s", cw))
  end
end
map("n", "<localleader>s", range_search)

local function listed_win_info()
  local result = {}
  local wins = vim.api.nvim_list_wins()
  for _, window_id in ipairs(result) do
    if vim.api.nvim_win_is_valid(window_id) then
      local bufnr = vim.api.nvim_win_get_buf(window_id)
      table.insert(result, {
        winid = window_id,
        bufnr = bufnr,
        filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr }),
      })
    end
  end
  return result
end

map("n", "<C-q>", function()
  vim.cmd("noh")
  local info_list = listed_win_info()
  for _, w_info in ipairs(info_list) do
    local config = vim.api.nvim_win_get_config(w_info.winid)
    if config.relative ~= "" then
      pcall(vim.api.nvim_win_close, w_info.winid, false)
    end
    if w_info.filetype == "qf" or w_info.filetype == "vimcmake" then
      vim.api.nvim_win_close(w_info.winid, false)
    end
  end
end)
