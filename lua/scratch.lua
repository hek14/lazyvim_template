-- debug example: log to files
-- vim.cmd [[redir >> /Users/hk/nvim_log.txt]]
-- vim.print({client_id = client_id, response = err_result, remaining_requests = remaining_requests })
-- vim.cmd [[redir END]]



_G.any_client_attached = function (bufnr)
  bufnr = bufnr or vim.fn.bufnr()
  -- local clients = vim.lsp.get_active_clients()
  -- local attached = {}
  -- for i,client in ipairs(clients) do
  --   if vim.lsp.buf_is_attached(bufnr,client.id) then
  --     table.insert(attached,{id=client.id,name=client.name})
  --   end
  -- end
  local attached = {}
  local clients = vim.lsp.get_active_clients({bufnr = bufnr}) or {}
  for id,client in pairs(clients) do
    if client.name~='null-ls' then
      table.insert(attached,{id=id,name=client.name})
    end
  end
end

vim.keymap.set("n", "y:", function()
  local ed_str = " | redir END"
  local left_cnt = #ed_str
  local left = ""
  for i = 1,left_cnt do
    left = left .. "<Left>"
  end
  local result = [[:let @a="" | redir @A |  | redir END]] .. left
  return result
end , {expr = true, silent = false})

local api = vim.api
local lsp = vim.lsp
local protocol = lsp.protocol
local ms = protocol.Methods
local win = api.nvim_get_current_win()
local cursor_row, cursor_col = unpack(api.nvim_win_get_cursor(win)) --- @type integer, integer
local line = api.nvim_get_current_line()
local line_to_cursor = line:sub(1, cursor_col)
local word_boundary = vim.fn.match(line_to_cursor, '\\k*$')
local start_time = vim.uv.hrtime()
local bufnr = vim.fn.bufnr()
local client = vim.lsp.get_active_clients({bufnr = bufnr})[1]
local params = lsp.util.make_position_params(win, client.offset_encoding)

local cancel_request = vim.lsp.buf_request(bufnr,ms.textDocument_completion, params, function(err, responses)
  vim.print("get response: ", responses)
end)
