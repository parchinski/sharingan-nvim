return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    opts = { flavour = 'mocha', integrations = { blink_cmp = true, snacks = true, which_key = true, flash = true } },
    config = function(_, opts)
      require('catppuccin').setup(opts)
      vim.cmd.colorscheme('catppuccin')
    end,
  },

  {
    'folke/snacks.nvim',
    lazy = false,
    priority = 900,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      image = { enabled = false },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      picker = { enabled = true, ui_select = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      words = { enabled = true },
      terminal = { enabled = true },
    },
    keys = {
      {
        '<M-n>',
        function()
          Snacks.words.jump(vim.v.count1, true)
        end,
        desc = 'Move to next reference',
      },
      {
        '<M-p>',
        function()
          Snacks.words.jump(-vim.v.count1, true)
        end,
        desc = 'Move to previous reference',
      },
      {
        '<leader>*',
        function()
          Snacks.picker.lsp_references()
        end,
        desc = 'Search reference in current project',
      },
      {
        '<leader>sp',
        function()
          Snacks.picker.lsp_definitions()
        end,
        desc = 'Peek symbol definition',
      },
      {
        '<leader>gi',
        function()
          Snacks.picker.gh_issue()
        end,
        desc = 'GitHub issues',
      },
      {
        '<leader>gp',
        function()
          Snacks.picker.gh_pr()
        end,
        desc = 'GitHub pull requests',
      },
      {
        '<leader>gg',
        function()
          Snacks.gitbrowse()
        end,
        desc = 'Open in GitHub',
      },
      {
        '<leader>gw',
        function()
          Snacks.terminal('gh run list')
        end,
        desc = 'GitHub workflows',
      },
    },
  },

  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = {
      options = { theme = 'catppuccin', globalstatus = true, section_separators = '', component_separators = '│' },
    },
  },

  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'helix',
      spec = {
        { '<leader>b', group = 'buffer' },
        { '<leader>c', group = 'code' },
        { '<leader>d', group = 'debug' },
        { '<leader>e', group = 'errors' },
        { '<leader>f', group = 'file' },
        { '<leader>fe', group = 'config' },
        { '<leader>g', group = 'git' },
        { '<leader>j', group = 'jump' },
        { '<leader>m', group = 'marks' },
        { '<leader>p', group = 'project' },
        { '<leader>r', group = 'refactor' },
        { '<leader>s', group = 'symbol' },
        { '<leader>t', group = 'toggle' },
        { '<leader>w', group = 'window' },
      },
    },
  },

  {
    'nvim-mini/mini.icons',
    lazy = true,
    opts = {},
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = 'markdown',
    opts = { completions = { blink = { enabled = true } } },
  },
}
