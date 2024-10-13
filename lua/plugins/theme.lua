local my_colorscheme_override = function()
  vim.cmd([[highlight! link FlashLabel Error]])
  vim.cmd([[highlight! LspSignatureActiveParameter guibg=gray]])
  vim.cmd([[highlight! BufferLineIndicatorSelected guifg='#FFC0CB']])
  vim.cmd([[highlight! ModeLinefileinfo cterm=bold gui=bold guifg=white guibg=#282828]])
  vim.cmd([[highlight! ModeLinemode cterm=bold gui=bold guifg=white guibg=#282828]])
  -- vim.cmd([[highlight! link GlancePreviewNormal Visual]])
end

return {
  {
    "behemothbucket/gruber-darker-theme.nvim",
    config = function()
      require("gruber-darker").setup()
      vim.schedule(my_colorscheme_override)
    end,
  },
  {
    "projekt0n/github-nvim-theme",
    config = function()
      require("github-theme").setup()
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
}
