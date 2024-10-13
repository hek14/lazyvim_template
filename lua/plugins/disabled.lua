return {
  {
    "rcarriga/nvim-notify",
    enabled = false,
  },
  {
    "nvim-lualine/lualine.nvim",
    enabled = false,
    opts = function(_, opts)
      local need_update = {}
      local cached = {}
      local wrapper = function(event, fn, id)
        vim.api.nvim_create_autocmd(event, {
          callback = function(_)
            need_update[id] = true
          end,
        })
        return function(args)
          if need_update[id] then
            need_update[id] = false
            cached[id] = fn(args)
            return cached[id]
          else
            return cached[id] or ""
          end
        end
      end

      local lualine_root = wrapper("BufEnter", function()
        local root, method = require("project_nvim.project").get_project_root()
        return root
      end, "lualine_c_root")

      local lualine_filename = wrapper("BufEnter", function()
        local root, method = require("project_nvim.project").get_project_root()
        root = root:gsub("%-", "%%-")
        local current = vim.fn.expand("%:p")
        local relative = current:gsub(root .. "/", "")
        return relative
      end, "lualine_c_file")

      opts.sections.lualine_c = { lualine_root, lualine_filename }
      -- opts.options.theme = "base16"
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = false,
  },
  {
    "folke/noice.nvim",
    enabled = false,
    keys = {
      { "<C-f>", false },
      { "<C-b>", false },
      {
        "<Esc>",
        function()
          vim.cmd([[NoiceDismiss]])
          vim.cmd([[noh]])
        end,
      },
    },
  },
  {
    "echasnovski/mini.icons",
    enabled = false,
  },
  {
    "nvimdev/dashboard-nvim",
    enabled = false,
  },
  {
    "echasnovski/mini.pairs",
    enabled = false,
  },
  {
    "mfussenegger/nvim-lint",
    enabled = false,
  },
  {
    "folke/trouble.nvim",
    enabled = false,
  },
  {
    "mini.ai",
    enabled = false,
  },
  {

    "nvim-treesitter/nvim-treesitter-refactor",
    enabled = false,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    enabled = false,
  },
  {
    "rcarriga/nvim-dap-ui",
    enabled = false,
    opts = {
      mappings = {
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "<C-e>",
        repl = "r",
      },
      layouts = {
        {
          elements = {
            -- {
            --   id = "scopes",
            --   size = 0.25,
            -- },
            {
              id = "breakpoints",
              size = 0.33,
            },
            {
              id = "stacks",
              size = 0.33,
            },
            {
              id = "watches",
              size = 0.34,
            },
          },
          position = "left",
          size = 40,
        },
        {
          elements = {
            {
              id = "repl",
              size = 0.5,
            },
            {
              id = "console",
              size = 0.5,
            },
          },
          position = "right",
          size = 100,
        },
      },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)
    end,
  },
}
