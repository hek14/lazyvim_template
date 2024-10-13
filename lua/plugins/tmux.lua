return {
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
}
