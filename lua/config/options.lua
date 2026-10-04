local opt = vim.opt

vim.g.python3_host_prog = '/usr/bin/python3'
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

opt.mouse = 'a'
opt.number = true
opt.relativenumber = true
opt.signcolumn = 'yes'
opt.termguicolors = true
opt.linebreak = true
opt.showbreak = '+++'
opt.showmatch = true
opt.visualbell = true
opt.list = true
opt.listchars = 'tab:»·,trail:·,nbsp:·'
opt.ignorecase = true
opt.smartcase = true
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.undofile = true
opt.timeoutlen = 300
opt.ttimeoutlen = 10
opt.updatetime = 250
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 4
opt.complete = ''
opt.shell = vim.env.SHELL or 'bash'
opt.winborder = 'rounded'
opt.clipboard = 'unnamedplus'

-- WSL: system clipboard via Windows tools (no X/Wayland clipboard here)
if vim.fn.has('wsl') == 1 then
  vim.g.clipboard = {
    name = 'wsl',
    copy = { ['+'] = 'clip.exe', ['*'] = 'clip.exe' },
    paste = {
      ['+'] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ['*'] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
end

vim.diagnostic.config({
  virtual_text = { prefix = '●', spacing = 4 },
  severity_sort = true,
  float = { source = true },
})

local au = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup('sharingan', { clear = true })
au('FileType', { group = group, pattern = { 'make', 'go' }, command = 'setlocal noexpandtab' })
au('TextYankPost', {
  group = group,
  callback = function()
    vim.hl.on_yank()
  end,
})
-- restore last cursor position
au('BufReadPost', {
  group = group,
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
