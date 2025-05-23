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
  event = 'VeryLazy', -- Moved from opts, standard lazy.nvim practice
  version = false, -- Moved from opts, standard lazy.nvim practice
  build = 'make', -- Moved from opts, standard lazy.nvim practice
  opts = {
    provider = 'claude',
    gemini = {
      model = 'gemini-2.5-pro-preview-05-06',
      api_key_name = 'GEMINI_API_KEY',
      temperature = 0,
      max_tokens = 1048576,
    },
    claude = {
      model = 'claude-sonnet-4-20250514',
      api_key_name = 'ANTHROPIC_API_KEY',
    },
    openai = {
      model = 'o4-mini',
      api_key_name = 'OPENAI_API_KEY', -- the shell command must prefixed with `^cmd:(.*)`
    },
    -- UI Customizations for the sidebar and internal windows
    windows = {
      width = 35, -- Example: Set sidebar width to 35%
      edit = {
        border = 'rounded', -- Use rounded borders for the edit window
        start_insert = true, -- This is a default, kept for clarity
      },
      ask = {
        border = 'rounded', -- Use rounded borders for the ask window
        start_insert = true, -- This is a default, kept for clarity
        floating = false, -- This is a default, kept for clarity
      },
      -- Other window defaults from avante.nvim/lua/avante/config.lua will apply
    },
  },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    --- The below dependencies are optional,
    'echasnovski/mini.pick', -- for file_selector provider mini.pick
    'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
    'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
    'ibhagwan/fzf-lua', -- for file_selector provider fzf
    'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    'zbirenbaum/copilot.lua', -- for providers='copilot'
    {
      -- support for image pasting
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
})
