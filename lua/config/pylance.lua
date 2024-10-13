local util = require("lspconfig.util")
local root_files = {
  "pyproject.toml",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  "Pipfile",
  "pyrightconfig.json",
  "project.md",
}
local default_config = {
  name = "pylance",
  autostart = true,
  single_file_support = true,
  cmd = { 'pylance', "--stdio" },
  filetypes = { "python" },
  root_dir = function(fname)
    return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname) or util.path.dirname(fname)
  end,
  settings = {
    python = {
      analysis = vim.empty_dict(),
    },
    telemetry = {
      telemetryLevel = "off",
    },
  },
}
require("lspconfig.configs")['pylance'] = {
  default_config = vim.tbl_extend("force", util.default_config, default_config),
}
