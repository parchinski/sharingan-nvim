local cosmos = require('core.cosmos')
local configs = require('layers.completion.configs')

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

cosmos.add_plugin('yetone/avante.nvim', {
  dev = local_avante_dir_exists,
  dir = local_avante_dir_exists and local_avante_dir or nil,
  event = 'VeryLazy',
  build = 'make',
  opts = {
    debug = false,
    mode = 'agentic',
    web_search_engine = {
      provider = 'serpapi',
    },
    rag_service = {
      enabled = false, -- Enables the rag service, requires OPENAI_API_KEY to be set
      provider = 'ollama',
      llm_model = 'llama3.2',
      embed_model = 'nomic-embed-text',
      endpoint = 'http://10.0.0.244:11434',
    },
    -- The system_prompt type supports both a string and a function that returns a string. Using a function here allows dynamically updating the prompt with mcphub
    -- system_prompt = function()
    --   local hub = require('mcphub').get_hub_instance()
    --   return hub:get_active_servers_prompt()
    -- end,
    -- -- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
    -- custom_tools = function()
    --   return {
    --     require('mcphub.extensions.avante').mcp_tool(),
    --   }
    -- end,
    provider = 'gemini_fast',
    -- provider = 'copilot_gemini',
    -- provider = 'copilot_openai',
    -- provider = 'copilot:gpt-4.1',
    -- provider = 'openai-gpt-4o-mini',
    selector = {
      provider = 'telescope',
    },
    history = {
      -- carried_entry_count = 3,
    },
    providers = {
      gemini = {
        model = 'gemini-2.5-pro-preview-05-06',
        api_key_name = 'GEMINI_API_KEY',
      },
      gemini_lite = {
        model = 'gemini-2.5-flash-lite-preview-06-17',
        api_key_name = 'GEMINI_API_KEY',
        __inherited_from = "gemini",
      },
      gemini_fast = {
        model = 'gemini-2.5-flash',
        api_key_name = 'GEMINI_API_KEY',
        __inherited_from = "gemini",
      },
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
