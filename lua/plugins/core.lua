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
    },
  config = function(_, opts)
  end

  NOTE: opts和config的关系：opts覆盖默认的opts之后，会作为第二个参数传入config函数
--]]

-- example of sync vim.ui.input
-- https://www.reddit.com/r/neovim/comments/1857guh/how_can_i_use_vimuiinput_synchronously/
-- local get_input = function(prompt)
--   local co = coroutine.running()
--   assert(co, "must be running under a coroutine")
--
--   vim.ui.input({ prompt = prompt, completion = "file", default = vim.uv.cwd() }, function(str)
--     -- (2) the asynchronous callback called when user inputs something
--     coroutine.resume(co, str)
--   end)
--
--   -- (1) Suspends the execution of the current coroutine, context switching occurs
--   local input = coroutine.yield()
--
--   -- (3) return the function
--   return input
-- end
-- local co = coroutine.wrap(function()
--   local path = get_input()
--   return vim.cmd(string.format([[:call VimuxRunCommand("cd %s")<Left><Left>]], path))
-- end)

local my_colorscheme_override = function()
  vim.cmd([[highlight! link FlashLabel Error]])
  vim.cmd([[highlight! LspSignatureActiveParameter guibg=gray]])
  vim.cmd([[highlight! BufferLineIndicatorSelected guifg='#FFC0CB']])
  vim.cmd([[highlight! ModeLinefileinfo cterm=bold gui=bold guifg=white guibg=#282828]])
  vim.cmd([[highlight! ModeLinemode cterm=bold gui=bold guifg=white guibg=#282828]])
  -- vim.cmd([[highlight! link GlancePreviewNormal Visual]])
end

return {
  { import = "lazyvim.plugins.extras.util.project" },
  { import = "lazyvim.plugins.extras.dap.core" },
  { import = "lazyvim.plugins.extras.dap.nlua" },
  { import = "lazyvim.plugins.extras.coding.yanky" },
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.coding.neogen" },
  { import = "lazyvim.plugins.extras.coding.luasnip" },
  { import = "lazyvim.plugins.extras.editor.dial" },
  { import = "lazyvim.plugins.extras.editor.harpoon2" },
  {
    "EtiamNullam/deferred-clipboard.nvim",
    lazy = false,
    config = function()
      require("deferred-clipboard").setup({
        lazy = true,
      })
    end,
  },
  {
    "nvimdev/modeline.nvim",
    event = "VeryLazy",
    config = function()
      require("modeline").setup()
      vim.schedule(my_colorscheme_override)
    end,
  },
  {
    "ej-shafran/compile-mode.nvim",
    branch = "nightly",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      vim.g.compile_mode = {
        -- to add ANSI escape code support
        baleia_setup = true,
      }
    end,
  },
  {
    "X3eRo0/dired.nvim",
    dependencies = "MunifTanjim/nui.nvim",
    event = "VeryLazy",
    config = function()
      require("dired").setup({
        path_separator = "/",
        show_banner = false,
        show_icons = false,
        show_hidden = true,
        show_dot_dirs = true,
        show_colors = true,
      })
    end,
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      {
        "sindrets/diffview.nvim",
        dependencies = {
          "nvim-tree/nvim-web-devicons",
        },
      }, -- optional - Diff integration
      "nvim-telescope/telescope.nvim", -- optional
    },
    config = true,
  },
  {
    "altermo/ultimate-autopair.nvim",
    event = { "InsertEnter", "CmdlineEnter" },
    branch = "v0.6", --recommended as each new version will have breaking changes
    config = true,
    opts = {},
  },
  {
    "tpope/vim-scriptease",
    cmd = "Messages",
  },
  {
    "LazyVim/LazyVim",
    version = false,
    opts = {
      -- colorscheme = "default",
      -- colorscheme = "moonfly",
      -- colorscheme = "github_dark_colorblind",
      colorscheme = "gruber-darker",
    },
  },
  {
    "gbprod/yanky.nvim",
    keys = {
      { "gp", false },
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
  {
    "projekt0n/github-nvim-theme",
    config = function()
      require("github-theme").setup({
        -- groups = {
        --   github_dark = {
        --     Normal = {bg = "#0a0a0a"},
        --     NormalNC = {bg = "#171616"}, -- non-active window
        --     NormalFloat = {bg = "#1c1a1a"}, -- float window, like lazy window and terminals
        --   }
        -- },
      })
      vim.schedule(my_colorscheme_override)
    end,
  },
  {
    "bluz71/vim-moonfly-colors",
    config = function()
      vim.api.nvim_create_autocmd("colorScheme", {
        callback = my_colorscheme_override,
      })
    end,
  },
  {
    "behemothbucket/gruber-darker-theme.nvim",
    config = function()
      require("gruber-darker").setup()
      vim.schedule(my_colorscheme_override)
    end,
  },
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
    event = { "InsertEnter", "CmdlineEnter" },
    opts = function(_, opts)
      opts.experimental.ghost_text = false
      opts.enabled = function()
        return vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= "prompt" or require("cmp_dap").is_dap_buffer()
      end
      opts.mapping["<C-a>"] = require("cmp").mapping.close()
      opts.mapping["<CR>"] = nil
    end,
    dependencies = {
      {
        "rcarriga/cmp-dap", -- or use `CTRL-X CTRL-O` to trigger the omnifunc completion
        config = function()
          require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
            sources = {
              { name = "dap" },
            },
          })
        end,
      },
      {
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
        map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "uh", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        vim.cmd("nnoremap <expr> <silent> <buffer> ]c &diff ? ']c' : '<Cmd>Gitsigns next_hunk<CR>'")
        vim.cmd("nnoremap <expr> <silent> <buffer> [c &diff ? '[c' : '<Cmd>Gitsigns prev_hunk<CR>'")
      end,
    },
  },
  {
    "akinsho/bufferline.nvim",
    keys = {
      { "<S-h>", false },
      { "<S-l>", false },
      { "<C-f>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" }, -- NOTE:don't use <Tab>, <C-i> will be overrided
      { "<C-b>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "<M-0>", '<cmd>lua require("bufferline").go_to_buffer(-1, true)<cr>' },
      { "<M-1>", '<cmd>lua require("bufferline").go_to_buffer(1, true)<cr>' },
      { "<M-2>", '<cmd>lua require("bufferline").go_to_buffer(2, true)<cr>' },
      { "<M-3>", '<cmd>lua require("bufferline").go_to_buffer(3, true)<cr>' },
      { "<M-4>", '<cmd>lua require("bufferline").go_to_buffer(4, true)<cr>' },
      { "<M-5>", '<cmd>lua require("bufferline").go_to_buffer(5, true)<cr>' },
      { "<M-6>", '<cmd>lua require("bufferline").go_to_buffer(6, true)<cr>' },
      { "<M-7>", '<cmd>lua require("bufferline").go_to_buffer(7, true)<cr>' },
      { "<M-8>", '<cmd>lua require("bufferline").go_to_buffer(8, true)<cr>' },
      { "<M-9>", '<cmd>lua require("bufferline").go_to_buffer(9, true)<cr>' },
    },
    opts = {
      options = {
        always_show_bufferline = true,
        numbers = "ordinal",
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
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "SmiteshP/nvim-navic",

        init = function()
          LazyVim.lsp.on_attach(function(client, buffer)
            if client.supports_method("textDocument/documentSymbol") then
              require("nvim-navic").attach(client, buffer)
              -- NOTE:这个功能比较慢，要有，但不能频繁调用，按需用keybind获取就行
              -- vim.wo.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
              vim.keymap.set("n", "<C-g>", function()
                local loc = require("nvim-navic").get_location()
                print(string.format("%s -> %s", vim.fn.expand("%"), loc))
              end, { buffer = buffer })
            end
          end)
        end,
      },
    },
    opts = function(_, opts)
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

      -- see full opts: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/init.lua
      opts.inlay_hints.enabled = true
      opts.document_highlight.enabled = true
      -- opts.diagnostics.signs = nil
      -- opts.diagnostics.update_in_insert = false
      opts.setup = {
        -- NOTE: per-server settings
        ["basedpyright"] = function(server, opts)
          opts.settings = {
            python = {
              analysis = {
                autoImportCompletions = true,
              },
            },
          }
          LazyVim.lsp.on_attach(function(client, buffer)
            client.server_capabilities.semanticTokensProvider = nil
          end)
        end,
        ["pyright"] = function(server, opts)
          LazyVim.lsp.on_attach(function(client, buffer)
            vim.print("pyright support semanticTokensProvider? ", client.server_capabilities.semanticTokensProvider)
            client.server_capabilities.semanticTokensProvider = nil
          end)
        end,
        ["*"] = function(server, opts) -- NOTE: override the opts for all servers
          require("lspconfig")[server].setup(opts)
          LazyVim.lsp.on_attach(function(client, buffer)
            vim.print(server, " support semanticTokensProvider? ", client.server_capabilities.semanticTokensProvider)
          end)
        end,
      }
      opts.servers["ruff"] = { enabled = true }
      opts.servers["ruff_lsp"] = { enabled = false }

      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "gd", false }
      keys[#keys + 1] = { "gi", false }
      keys[#keys + 1] = { "gr", false }
      keys[#keys + 1] = { "gy", false }
      keys[#keys + 1] = { "K", false }
      keys[#keys + 1] = { "gK", false }
      keys[#keys + 1] = { "E", vim.lsp.buf.hover, desc = "Hover" }
      keys[#keys + 1] = { "gE", vim.lsp.buf.signature_help, desc = "Signature Help", has = "signatureHelp" }
      keys[#keys + 1] = { "gt", require("telescope.builtin").lsp_document_symbols, desc = "goto symbol" }
      keys[#keys + 1] = {
        "]r",
        function()
          LazyVim.lsp.words.jump(vim.v.count1)
        end,
        has = "documentHighlight",
        desc = "Next Reference",
        cond = function()
          return LazyVim.lsp.words.enabled
        end,
      }
      keys[#keys + 1] = {
        "[r",
        function()
          LazyVim.lsp.words.jump(-vim.v.count1)
        end,
        has = "documentHighlight",
        desc = "Prev Reference",
        cond = function()
          return LazyVim.lsp.words.enabled
        end,
      }
      keys[#keys + 1] = { "gd", "<cmd>Glance definitions<cr>", { desc = "Preview definitions" } }
      keys[#keys + 1] = { "gr", "<cmd>Glance references<cr>", { desc = "Preview references" } }
      keys[#keys + 1] = { "gy", "<cmd>Glance type_definitions<cr>", { desc = "Preview type_definitions" } }
      keys[#keys + 1] = { "gi", "<cmd>Glance implementations<cr>", { desc = "Preview implementations" } }
      keys[#keys + 1] = { "[[", false }
      keys[#keys + 1] = { "]]", false }

    end,
  },
  {
    "nvim-lualine/lualine.nvim",
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
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>fa",
        "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
        desc = "Find Plugin File",
      },
    },
    opts = function(_, opts)
      local actions = require("telescope.actions")
      opts.defaults.layout_strategy = "vertical"
      opts.defaults.mappings.i["<Up>"] = actions.cycle_history_prev
      opts.defaults.mappings.i["<Down>"] = actions.cycle_history_next
      opts.defaults.preview = { treesitter = false }
    end,
  },
  {
    "tpope/vim-surround",
    event = "BufEnter",
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      -- NOTE:get package path:
      -- local path = require("mason-registry").get_package("php-debug-adapter"):get_install_path()
      vim.list_extend(opts.ensure_installed, {
        "stylua",
        "shellcheck",
        "ruff",
        "basedpyright",
        "lua-language-server",
        "json-lsp",
        "pylance",
        "clangd"
      })
      opts.registries = { "github:fecet/mason-registry" }
    end,
    config = function(_, opts)
      require("mason").setup(opts)
    end,
    init = function()
      vim.env["NODE_TLS_REJECT_UNAUTHORIZED"] = "0"
    end,
  },
  {
    "monkoose/matchparen.nvim",
    event = "BufEnter",
    config = true,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {},
    opts = function(_, opts)
      opts.textobjects = {
        select = {
          enable = true,
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["af"] = "@function.outer",
            ["uf"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["uc"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ua"] = "@parameter.inner",
          },
        },
        swap = {
          enable = true,
          swap_next = { ["<leader>a"] = "@parameter.inner" },
          swap_previous = { ["<leader>A"] = "@parameter.inner" },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]]"] = "@class.outer",
            ["]a"] = "@parameter.inner",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]["] = "@class.outer",
            ["]A"] = "@parameter.inner",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[["] = "@class.outer",
            ["[a"] = "@parameter.inner",
          },

          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[]"] = "@class.outer",
            ["[A"] = "@parameter.inner",
          },
        },
      }
    end,
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
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<leader>db", false },
    },
    config = function()
      ----------------- lazyvim config
      -- load mason-nvim-dap here, after all adapters have been setup
      if LazyVim.has("mason-nvim-dap.nvim") then
        require("mason-nvim-dap").setup(LazyVim.opts("mason-nvim-dap.nvim"))
      end

      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      for name, sign in pairs(LazyVim.config.icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end

      -- setup dap config by VsCode launch.json file
      local vscode = require("dap.ext.vscode")
      local json = require("plenary.json")
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end

      -- Extends dap.configurations with entries read from .vscode/launch.json

      if vim.fn.filereadable(".vscode/launch.json") then
        vscode.load_launchjs()
      end

      ----------------- mine config
      local dap = require("dap")
      dap.defaults.fallback.terminal_win_cmd = "tabnew"
      -- except for python:
      dap.defaults.python.terminal_win_cmd = "vsplit new"
      dap.defaults.fallback.exception_breakpoints = { "uncaught" }

      dap.listeners.after.event_initialized["kk"] = function()
        require("dap").repl.open()
      end
      dap.listeners.before.event_terminated["kk"] = function()
        require("dap").repl.close()
      end
      dap.listeners.before.event_exited["kk"] = function()
        require("dap").repl.close()
      end
    end,
    dependencies = {
      "rcarriga/cmp-dap",
      {
        "ofirgall/goto-breakpoints.nvim",
        keys = {
          { "<localleader>dn", "<cmd>lua require('goto-breakpoints').next()<cr>", desc = "Goto dap next breakpoint" },
          { "<localleader>de", "<cmd>lua require('goto-breakpoints').prev()<cr>", desc = "Goto dap prev breakpoint" },
          { "<localleader>dd", "<cmd>lua require('goto-breakpoints').stopped()<cr>", desc = "Goto dap stopped line" },
        },
      },
    },
  },
  {
    "folke/todo-comments.nvim",
    opts = {
      signs = false,
      keywords = {
        NOTE = {
          alt = { "UC_NOTE" },
        },
        TODO = {
          alt = { "UC_TODO" },
        },
        FIX = {
          icon = " ",
          color = "error",
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "MAYBE" },
          signs = true,
        },
      },
    },
  },
  {

    "preservim/vimux",
    lazy = false,
    config = function()
      vim.api.nvim_create_user_command("Debug", function(a)
        if a.args == "current" then
          a.args = vim.fn.expand("%")
        end
        vim.fn.call("VimuxRunCommand", { "./debug.sh " .. a.args })
        vim.api.nvim_input("<F5>")
      end, {
          complete = function()
            return { "server", "new", "old", "current" }
          end,
          nargs = "?",
        })
      vim.schedule(function()
        vim.notify("local vimrc loaded")
      end)
      vim.g.VimuxUseNearest = false
      vim.g.VimuxRunnerName = "VimUx"
      vim.api.nvim_create_user_command("VimuxRunCommand", function(args)
        local input = ""
        for i = 1, #args.fargs do
          if i == 1 then
            input = args.fargs[1]
          else
            input = input .. " " .. args.fargs[i]
          end
        end
        vim.fn.VimuxRunCommand(input)
      end, { force = true, complete = "file", nargs = "*" })

      vim.api.nvim_create_user_command("VimuxSendText", function(args)
        local input = ""
        for i = 1, #args.fargs do
          if i == 1 then
            input = args.fargs[1]
          else
            input = input .. " " .. args.fargs[i]
          end
        end
        input = input:sub(1, -1) .. "\r"
        vim.fn.VimuxSendText(input)
      end, { force = true, complete = "file", nargs = "*" })
    end,
    init = function()
      vim.g.kill_vimux = true
      vim.keymap.set("n", "<leader>uk", function()
        vim.g.kill_vimux = not vim.g.kill_vimux
        vim.notify(string.format("kill_vimux? %s", vim.g.kill_vimux))
      end, { desc = "Togglle kill_tmux" })
      vim.api.nvim_create_user_command("KeepTmux", function()
        vim.g.kill_vimux = false
      end, {})
      vim.api.nvim_create_user_command("HandleTmuxS", function()
        vim.g.VimuxOrientation = "v"
        vim.g.VimuxRunnerType = "pane"
        vim.api.nvim_input("<space>tt")
      end, {})
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          if vim.g.kill_vimux then
            pcall(function()
              vim.cmd([[VimuxCloseRunner]])
            end)
          end
        end,

        desc = "Close vimux runner",
      })
      vim.api.nvim_create_user_command("Runpython", function(a)
        local convert_file = function(s)
          if s == "%" then
            s = vim.fn.expand("%")
          end
          return s
        end

        local convert_dir = function(s)
          if s == "$root" then
            s = vim.uv.cwd()
          elseif s == "$folder" then
            s = vim.fn.expand("%:p:h")
          elseif s:sub(1, 1) == "$" then
            s = vim.env[s:sub(2, -1)]
          end
          return s
        end

        local dir = vim.fn.expand("%:p:h")
        local python_file = vim.fn.expand("%:t")

        if #a.fargs == 1 then
          python_file = convert_file(a.fargs[1])
        elseif #a.fargs == 2 then
          dir = convert_dir(a.fargs[1])
          python_file = convert_file(a.fargs[2])
        end
        vim.g.VimuxRunnerType = "pane"
        vim.cmd(string.format("VimuxRunCommand source set_env.sh ; python %s", python_file))
      end, { nargs = "*", complete = "file" })

      -- NOTE: use g:VimuxRunnerIndex to check if opened
      -- NOTE: use g:VimuxRunnerType to check if showed in current window
      local wk = require("which-key")
      wk.add({
        mode = "n",
        { "<leader>t", group = "Tmux" },
        {
          "<leader>tr",
          function()
            return [[:<C-u>VimuxRunCommand ]]
          end,
          desc = "Run command",
          expr = true,
          silent = false,
        },
        {
          "<leader>to",
          function()
            vim.g.VimuxRunnerType = "pane"
            vim.cmd([[VimuxOpenRunner]])
          end,
          desc = "Open runner(Deprecated), use toggle instead",
          silent = false,
        },
        {
          "<leader>tt",
          function()
            -- error handle
            local ok, _ = pcall(function()
              if vim.fn.exists("g:VimuxRunnerIndex") > 0 then
                vim.cmd([[VimuxTogglePane]])
              else
                vim.cmd([[VimuxOpenRunner]])
              end
            end)
            if not ok then
              vim.g.VimuxRunnerType = "pane"
              vim.cmd([[VimuxOpenRunner]])
            end
          end,
          desc = "Toggle pane",
          silent = false,
        },
        {
          "<leader>ts",
          function()
            if vim.fn.exists("g:VimuxRunnerIndex") <= 0 then
              vim.cmd([[VimuxOpenRunner]])
            end

            return ":<C-u>VimuxSendText "
          end,
          desc = "Send text",
          expr = true,
          silent = false,
        },
        {
          "<leader>tc",
          function()
            vim.g.VimuxRunnerType = "pane"
            vim.cmd([[VimuxCloseRunner]])
            vim.g.VimuxRunnerIndex = nil
          end,
          desc = "Close runner",
        },
        {
          "<leader>tz",
          "<cmd>VimuxZoomRunner<cr>",
          desc = "Zoom runner",
        },
        {
          "<leader>tl",
          "<cmd>VimuxRunLastComman<cr>",
          desc = "Run last command",
        },
      })
      vim.keymap.set("n", "<leader>tp", "<cmd>KeepTmux<cr>", { desc = "Do not kill tmux when quit vim" })
    end,
  },
  {
    "jedrzejboczar/exrc.nvim",
    lazy = false,
    config = true,
    opts = {
      exrc_name = ".nvim.lua",
    },
  },
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = { { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" } },
  },
  {
    "dnlhc/glance.nvim",
    cmd = "Glance",
    config = function()
      local glance = require("glance")
      local actions = glance.actions
      glance.setup({
        border = {
          enable = true, -- Show window borders. Only horizontal borders allowed
          top_char = "―",
          bottom_char = "―",
        },
        mappings = {
          list = {
            ["n"] = actions.next, -- Bring the cursor to the next item in the list
            ["e"] = actions.previous, -- Bring the cursor to the previous item in the list
            ["j"] = actions.next, -- Bring the cursor to the next item in the list
            ["k"] = actions.previous, -- Bring the cursor to the previous item in the list
            ["<Down>"] = actions.next,
            ["<Up>"] = actions.previous,
            ["<Tab>"] = false, -- Bring the cursor to the next location skipping groups in the list
            ["<S-Tab>"] = false, -- Bring the cursor to the previous location skipping groups in the list
            ["<C-n>"] = actions.next_location, -- Bring the cursor to the next location skipping groups in the list
            ["<C-p>"] = actions.previous_location, -- Bring the cursor to the previous location skipping groups in the list
            ["<C-u>"] = actions.preview_scroll_win(5),
            ["<C-d>"] = actions.preview_scroll_win(-5),
            ["v"] = actions.jump_vsplit,
            ["s"] = actions.jump_split,
            ["t"] = actions.jump_tab,
            ["<CR>"] = actions.jump,
            ["o"] = actions.jump,
            ["l"] = actions.open_fold,
            ["h"] = actions.close_fold,
            ["<C-e>"] = actions.enter_win("preview"), -- Focus preview window
            ["q"] = actions.close,
            ["Q"] = actions.close,
            ["<Esc>"] = actions.close,
            ["<C-q>"] = actions.quickfix,
          },
          preview = {
            ["Q"] = actions.close,
            ["<C-n>"] = actions.next_location, -- Bring the cursor to the next location skipping groups in the list
            ["<C-p>"] = actions.previous_location, -- Bring the cursor to the previous location skipping groups in the list
            ["<Tab>"] = false,
            ["<S-Tab>"] = false,
            ["<C-e>"] = actions.enter_win("list"), -- Focus list window
          },
        },
      })
    end,
  },
}
