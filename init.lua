-- bootstrap lazy.nvim, LazyVim and your plugins
_G.ENV = {
  os_name = vim.uv.os_uname().sysname,
  is_mac = vim.uv.os_uname().sysname == "Darwin",
  is_linux = vim.uv.os_uname().sysname == "Linux",
  is_windows = vim.uv.os_uname().sysname == "Windows",
}
local config_bin_path = vim.fn.stdpath("config") .. "/bin:"
vim.env["PATH"] = config_bin_path .. vim.env["PATH"]
require("config.lazy")
