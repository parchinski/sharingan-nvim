-- sharingan-nvim: neovim 0.12+ config
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.options')
require('config.keymaps')

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error('lazy.nvim clone failed:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
  -- lockfile lives in the repo so plugin versions are pinned and reviewable
  lockfile = vim.fn.stdpath('config') .. '/lazy-lock.json',
  install = { colorscheme = { 'catppuccin' } },
  checker = { enabled = false },
  change_detection = { notify = false },
  rocks = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = { 'gzip', 'netrwPlugin', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin' },
    },
  },
})

require('config.lsp')
