--[[
reference: https://www.lazyvim.org/configuration/plugins
The following `keys` will be `merged` into the LazyVim defaults:
    cmd: the list of commands will be extended with your custom commands
    event: the list of events will be extended with your custom events
    ft: the list of filetypes will be extended with your custom filetypes
    keys: the list of keymaps will be extended with your custom keymaps
    opts: your custom opts will be merged with the default opts
    dependencies: the list of dependencies will be extended with your custom dependencies

Other property will `override` the defaults

For ft, event, keys, cmd and opts,you can instead also specify a `values` function:
that can make changes to the default values, or return new values to be used instead.
Example:
    opts = function(_, lazyvim_defaults_opts)
        -- do anything with the lazyvim_defaults_opts
    end,
    keys = {}, -- remove all default keymaps
    keys = function(_, default_keys){ -- totally use my own keymaps
        return {
            {"<leader>fs", "<cmd>Telescope find_files<cr>"}
        }
    }
--]]

return {
  {
    "LazyVim/LazyVim",
    version = false,
    opts = {
      -- colorscheme = "github_dark",
      colorscheme = "moonfly",
    },
  },
  {
    "folke/noice.nvim",
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
  { "projekt0n/github-nvim-theme" },
  {
    "bluz71/vim-moonfly-colors",
    config = function()
      vim.api.nvim_create_autocmd("colorScheme", {
        callback = function()
          vim.cmd([[highlight! BufferLineIndicatorSelected guifg='#FFC0CB']])
        end,
      })
    end,
  },
  { import = "lazyvim.plugins.extras.util.project" },
  { import = "lazyvim.plugins.extras.coding.luasnip" },
  {
    "L3MON4D3/LuaSnip",
    opts = function(_, opts)
      local types = require("luasnip.util.types")
      opts.ext_opts = {
        [types.insertNode] = {
          active = { hl_group = "LspInfoTip" },
          visited = { hl_group = "Visual" },
          passive = { hl_group = "Visual" },
          snippet_passive = { hl_group = "Visual" },
        },
        [types.choiceNode] = {
          active = { hl_group = "Visual" },
          unvisited = { hl_group = "Visual" },
        },
        [types.snippet] = {
          -- passive = { hl_group = 'LspInfoTip' }
        },
      }
    end,
    config = function(opts)
      require("luasnip").setup(opts)
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets/vscode", vim.fn.stdpath("data") .. "/lazy/friendly-snippets" },
      })
      require("luasnip.loaders.from_lua").lazy_load({ paths = vim.fn.stdpath("config") .. "/snippets" })
      vim.keymap.set({ "n", "s" }, "<localleader>\\", function()
        require("luasnip").unlink_current()
      end, { silent = false, desc = "De-activate current snippet" })
    end,
  },
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
      require("project_nvim").setup({
        manual_mode = false,
        detection_methods = { "pattern" },
        patterns = {
          ".vscode",
          ".clangd",
          ".git",
          ".project",
          "pyproject.toml",
          "pyrightconfig.json",
        },
        exclude_dirs = {},
        show_hidden = false,
        silent_chdir = true,
        datapath = vim.fn.stdpath("data"),
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-cmdline",
      config = function()
        local cmp = require("cmp")
        -- `/` cmdline setup.
        cmp.setup.cmdline("/", {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
            { name = "buffer" },
          },
        })
        -- `:` cmdline setup.
        cmp.setup.cmdline(":", {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({ name = "path" }, {
            {
              name = "cmdline",
              -- option = {
              --   ignore_cmds = { "Man", "!" },
              -- },
            },
          }),
        })
      end,
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

      -- stylua: ignore start
      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next Hunk")
      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Prev Hunk")
      map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
      map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
      map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
      map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
      map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
      map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
      map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
      map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
      map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
      map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
      map("n", "<leader>ghd", gs.diffthis, "Diff This")
      map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
      map({ "o", "x" }, "uh", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  {
    "mini.ai",
    enabled = false,
  },
  {
    "akinsho/bufferline.nvim",
    keys = {
      { "<S-h>", false },
      { "<S-l>", false },
      { "<C-f>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" }, -- NOTE:don't use <Tab>, <C-i> will be overrided
      { "<C-b>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    },
    opts = {
      options = {
        diagnostics = false,
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        mappings = {
          ["e"] = "none",
        },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      experimental = {
        ghost_text = false,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- disable lsp keymaps(on_attach)
      keys[#keys + 1] = { "K", false }
      keys[#keys + 1] = { "gK", false }
      -- insert lsp keymaps(on_attach)
      keys[#keys + 1] = { "E", vim.lsp.buf.hover, desc = "Hover" }
      keys[#keys + 1] = { "gE", vim.lsp.buf.signature_help, desc = "Signature Help", has = "signatureHelp" }
      keys[#keys + 1] = { "gt", require("telescope.builtin").lsp_document_symbols, desc = "goto symbol" }
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local root = function()
        local root, method = require("project_nvim.project").get_project_root()
        return root
      end
      local filename = function()
        local root, method = require("project_nvim.project").get_project_root()
        local current = vim.fn.expand("%:p")
        local relative = current:gsub(root .. "/", "")
        return relative
      end
      opts.sections.lualine_c = { root, filename }
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      local actions = require("telescope.actions")
      opts.defaults.layout_strategy = "vertical"
      opts.defaults.mappings.i["<Up>"] = actions.cycle_history_prev
      opts.defaults.mappings.i["<Down>"] = actions.cycle_history_next
    end,
  },
  {
    "tpope/vim-surround",
    event = "BufEnter",
  },
}
