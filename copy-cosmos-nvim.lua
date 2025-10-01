local cosmos = require('core.cosmos')

return {
  layers = {
    'editor',
    'git',
    {
      'ui',
      theme = 'catppuccin',
      enable_beacon = false,
      enable_smooth_scrolling = false,
    },
    'completion',
  },
  options = {
    -- python3_host_prog = '~/.pyenv/versions/nvim-py3/bin/python',
    clipboard = 'unnamedplus', -- Enable system clipboard
    timeoutlen = 300, -- Reduce the timeout for key sequences
    ttimeoutlen = 10, -- Reduce the timeout for key codes
  },
  before_setup = function()
    -- cosmos.add_plugin('wakatime/vim-wakatime')
  end,
  after_setup = function()
    -- cosmos.add_leader_keymapping('n|aw', { '<cmd>WakaTimeToday<cr>', name = 'WakaTime Today' })
  end,
}
