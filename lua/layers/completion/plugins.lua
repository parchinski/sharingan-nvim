local cosmos = require('core.cosmos')
local configs = require('layers.completion.configs')

cosmos.add_plugin('github/copilot.vim', {
  dependencies = { 'hrsh7th/nvim-cmp' },
  event = 'BufRead',
})

cosmos.add_plugin('hrsh7th/nvim-cmp', {
  dependencies = {
    {
      'windwp/nvim-autopairs',
      branch = 'master',
      config = configs.autopairs,
      lazy = true,
    },
    {
      'L3MON4D3/LuaSnip',
      dependencies = {
        {
          'rafamadriz/friendly-snippets',
          lazy = true,
        },
      },
      config = configs.luasnip,
      version = 'v2.3.0',
      build = 'make install_jsregexp',
      lazy = true,
    },
  },
  config = configs.cmp,
  event = 'InsertEnter',
})

cosmos.add_plugin('hrsh7th/cmp-nvim-lua', { dependencies = { 'hrsh7th/nvim-cmp' }, event = 'BufRead' })
cosmos.add_plugin('hrsh7th/cmp-buffer', { dependencies = { 'hrsh7th/nvim-cmp' }, event = 'BufRead' })
cosmos.add_plugin('hrsh7th/cmp-path', { dependencies = { 'hrsh7th/nvim-cmp' }, event = 'BufRead' })
cosmos.add_plugin('hrsh7th/cmp-cmdline', { dependencies = { 'hrsh7th/nvim-cmp' }, event = 'BufRead' })
cosmos.add_plugin('dmitmel/cmp-cmdline-history', { dependencies = { 'hrsh7th/nvim-cmp' }, event = 'BufRead' })

cosmos.add_plugin('saadparwaiz1/cmp_luasnip', { dependencies = { 'hrsh7th/nvim-cmp' }, event = 'BufRead' })

cosmos.add_plugin('jackMort/ChatGPT.nvim', {
  event = 'VeryLazy',
  config = configs.chatgpt,
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    'folke/trouble.nvim',
    'nvim-telescope/telescope.nvim',
  },
})

cosmos.add_plugin('olimorris/codecompanion.nvim', {
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-telescope/telescope.nvim', -- Optional
    {
      'stevearc/dressing.nvim', -- Optional: Improves the default Neovim UI
      opts = {},
    },
  },
  config = function()
    require('codecompanion').setup()
  end,
})

cosmos.add_plugin('yetone/avante.nvim', {
  opts = {
    provider = 'claude',
    gemini = {
      model = "gemini-2.0-flash",
      api_key_name = "GEMINI_API_KEY",
      temperature = 0,
      max_tokens = 1000000,
    },
    claude = {
      model = "claude-3-7-sonnet-20250219",
      api_key_name = "ANTHROPIC_API_KEY"
    },
    openai = {
      model = 'o1-mini',
      api_key_name = "OPENAI_API_KEY", -- the shell command must prefixed with `^cmd:(.*)`
    },
    build = 'make',
    lazy = false,
    version = false,
    event = "VeryLazy",
  },

  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
})
