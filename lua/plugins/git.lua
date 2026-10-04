return {
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },
  {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' },
    opts = { integrations = { diffview = true, snacks = true } },
    keys = {
      {
        '<leader>gs',
        function()
          require('neogit').open()
        end,
        desc = 'Magit status',
      },
    },
  },
}
