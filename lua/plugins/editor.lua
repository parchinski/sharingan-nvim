return {
  { 'neovim/nvim-lspconfig', lazy = false }, -- server definitions only (lsp/*.lua)

  {
    'mason-org/mason.nvim',
    cmd = 'Mason',
    -- gap-filler only: appended to PATH so signed system binaries always win
    opts = { PATH = 'append' },
    init = function()
      vim.env.PATH = vim.env.PATH .. ':' .. vim.fn.stdpath('data') .. '/mason/bin'
    end,
  },

  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = { modes = { char = { enabled = false } } },
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        'S',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
      },
      {
        'R',
        mode = { 'o', 'x' },
        function()
          require('flash').treesitter_search()
        end,
        desc = 'Treesitter Search',
      },
      {
        '<C-s>',
        mode = 'c',
        function()
          require('flash').toggle()
        end,
        desc = 'Toggle Flash Search',
      },
      {
        '<leader>jj',
        mode = { 'n', 'v', 'o' },
        function()
          require('flash').remote()
        end,
        desc = 'Jump to a char',
      },
      {
        '<leader>jl',
        function()
          require('flash').jump({
            search = { mode = 'search', max_length = 0 },
            label = { after = { 0, 0 } },
            pattern = '^',
          })
        end,
        desc = 'Jump to a line',
      },
    },
  },

  { 'kylechui/nvim-surround', version = '^3', event = 'VeryLazy', opts = {} }, -- ys / cs / ds / S
  { 'wellle/targets.vim', event = 'VeryLazy' }, -- A / I / an etc. with seeking
  {
    'numToStr/Comment.nvim', -- gb block comments + gco/gcO/gcA (native gc covers the rest)
    event = 'VeryLazy',
    opts = {},
  },
  {
    'monaqa/dial.nvim', -- <C-a>/<C-x> on dates, bools, hex etc.
    keys = {
      {
        '<C-a>',
        function()
          require('dial.map').manipulate('increment', 'normal')
        end,
        desc = 'Increment',
      },
      {
        '<C-x>',
        function()
          require('dial.map').manipulate('decrement', 'normal')
        end,
        desc = 'Decrement',
      },
      {
        '<C-a>',
        function()
          require('dial.map').manipulate('increment', 'visual')
        end,
        mode = 'x',
        desc = 'Increment',
      },
      {
        '<C-x>',
        function()
          require('dial.map').manipulate('decrement', 'visual')
        end,
        mode = 'x',
        desc = 'Decrement',
      },
    },
  },
  {
    'nvim-mini/mini.bracketed',
    event = 'VeryLazy',
    opts = { diagnostic = { suffix = '' }, comment = { suffix = '' } },
  },

  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = 'Refactor',
    opts = {},
    keys = {
      { '<leader>ref', ':Refactor extract ', mode = 'x', desc = 'Refactor extract to function' },
      { '<leader>reF', ':Refactor extract_to_file ', mode = 'x', desc = 'Refactor extract to file' },
      { '<leader>rev', ':Refactor extract_var ', mode = 'x', desc = 'Refactor extract variable' },
      { '<leader>rebf', ':Refactor extract_block<cr>', desc = 'Refactor extract block to function' },
      { '<leader>rebF', ':Refactor extract_block_to_file<cr>', desc = 'Refactor extract block to file' },
      { '<leader>riv', ':Refactor inline_var<cr>', mode = { 'n', 'x' }, desc = 'Refactor inline variable' },
      { '<leader>rif', ':Refactor inline_func<cr>', desc = 'Refactor inline function' },
    },
  },

  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' }, opts = {} },
      { 'theHamsta/nvim-dap-virtual-text', opts = {} },
      { 'leoluz/nvim-dap-go', opts = {} },
    },
    keys = function()
      local dap = function()
        return require('dap')
      end
      local ui = function()
        return require('dapui')
      end
      return {
        {
          '<leader>db',
          function()
            dap().toggle_breakpoint()
          end,
          desc = 'Toggle breakpoint',
        },
        {
          '<leader>dc',
          function()
            dap().continue()
          end,
          desc = 'Continue',
        },
        {
          '<leader>dP',
          function()
            dap().pause()
          end,
          desc = 'Pause',
        },
        {
          '<leader>dn',
          function()
            dap().step_over()
          end,
          desc = 'Step over',
        },
        {
          '<leader>ds',
          function()
            dap().step_into()
          end,
          desc = 'Step into',
        },
        {
          '<leader>do',
          function()
            dap().step_out()
          end,
          desc = 'Step out',
        },
        {
          '<leader>dl',
          function()
            require('dap.ext.vscode').load_launchjs()
          end,
          desc = 'Load launch.json',
        },
        {
          '<leader>dr',
          function()
            dap().continue()
            ui().open()
          end,
          desc = 'Run',
        },
        {
          '<leader>dS',
          function()
            dap().terminate()
            dap().repl.close()
            ui().close()
          end,
          desc = 'Stop',
        },
        {
          '<leader>dK',
          function()
            ui().float_element()
          end,
          desc = 'Float element',
        },
        {
          '<leader>dR',
          function()
            ui().float_element('repl')
          end,
          desc = 'REPL',
        },
        {
          '<leader>dt',
          function()
            ui().toggle()
          end,
          desc = 'Toggle',
        },
        {
          '<leader>dC',
          function()
            ui().close()
          end,
          desc = 'Close',
        },
      }
    end,
  },
}
