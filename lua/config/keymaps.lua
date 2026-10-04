-- Every mapping from the old cosmos layers, re-homed. Plugin-specific
-- motions (flash, textobjects, dap, git) live with their plugin specs.
local map = vim.keymap.set
local function leader(lhs, rhs, desc, mode)
  map(mode or 'n', '<leader>' .. lhs, rhs, { desc = desc, silent = true })
end
local function pick(name, opts)
  return function()
    Snacks.picker[name](opts)
  end
end

-- windows
for i = 1, 6 do
  leader(tostring(i), i .. '<C-w><C-w>', 'Select window ' .. i)
end
leader('ws', '<C-w>s', 'Split window below')
leader('w-', '<C-w>s', 'Split window below')
leader('wv', '<C-w>v', 'Split window right')
leader('w/', '<C-w>v', 'Split window right')
leader('ww', '<C-w>w', 'Other window')
leader('wj', '<C-w>j', 'Go to the down window')
leader('wk', '<C-w>k', 'Go to the up window')
leader('wh', '<C-w>h', 'Go to the left window')
leader('wl', '<C-w>l', 'Go to the right window')
leader('wd', '<C-w>c', 'Delete window')
leader('wm', '<C-w>o', 'Maximize window')
leader('wp', function()
  local wins = vim.tbl_filter(function(w)
    return vim.api.nvim_win_get_config(w).relative == ''
  end, vim.api.nvim_tabpage_list_wins(0))
  local labels = {}
  for i, w in ipairs(wins) do
    labels[#labels + 1] = i .. ':' .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w)), ':t')
  end
  vim.api.nvim_echo({ { 'Pick window  ' .. table.concat(labels, '  ') } }, false, {})
  local n = tonumber(vim.fn.getcharstr())
  vim.cmd.echo("''")
  if n and wins[n] then
    vim.api.nvim_set_current_win(wins[n])
  end
end, 'Pick Window')

-- buffers
leader('bb', pick('buffers', { current = false }), 'List buffers')
leader('bn', '<cmd>bnext<cr>', 'Next buffer')
leader('bp', '<cmd>bprevious<cr>', 'Previous buffer')
leader('bd', function()
  Snacks.bufdelete()
end, 'Delete buffer')
leader('<Tab>', '<cmd>b#<cr>', 'Last buffer')

-- files / projects / search
leader('<Space>', pick('smart'), 'Smart Open')
leader('ff', function()
  local dir = vim.fn.expand('%:p:h')
  Snacks.picker.files({ cwd = dir ~= '' and dir or vim.uv.cwd(), title = 'Files in ' .. dir })
end, 'Find file in current directory')
leader('fb', function()
  Snacks.explorer()
end, 'File browser')
leader('ft', function()
  Snacks.explorer()
end, 'File tree')
leader('fr', pick('recent'), 'Open recent file')
leader('fed', '<cmd>edit $MYVIMRC<cr>', 'Open configuration file')
leader('feD', pick('files', { cwd = vim.fn.stdpath('config') }), 'Open config source files')
leader('feR', '<cmd>restart<cr>', 'Restart neovim')
leader('pp', pick('projects'), 'Switch project')
leader('pf', pick('files'), 'Find project files')
leader('/', pick('grep'), 'Search text in current project')
leader('ss', pick('lines'), 'Search current buffer')
leader('ji', pick('lsp_symbols'), 'Jump to a symbol')
leader('rl', pick('resume'), 'Resume popup window')
leader('tp', pick('colorschemes'), 'Theme pick')

-- symbols / diagnostics
leader('se', vim.lsp.buf.rename, 'Edit symbol')
leader('sd', function()
  Snacks.picker.lsp_definitions()
end, 'Peek definition')
leader('sD', function()
  Snacks.picker.lsp_type_definitions()
end, 'Peek type definition')
leader('sh', vim.lsp.buf.hover, 'Hover symbol')
leader('sH', vim.lsp.buf.signature_help, 'Show symbol signature')
leader('el', pick('diagnostics_buffer'), 'List errors')
leader('eL', pick('diagnostics'), 'List workspace errors')
leader('en', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, 'Next error')
leader('ep', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, 'Previous error')
leader('ef', vim.lsp.buf.code_action, 'Fix error')

-- terminal / repl
leader("'", function()
  Snacks.terminal.toggle(nil, { count = vim.v.count1 })
end, 'Open shell')
map('t', '<M-d>', function()
  Snacks.terminal.toggle(nil, { count = vim.v.count1 })
end, { desc = 'Toggle shell' })
leader('lr', function()
  Snacks.scratch({ ft = 'lua', name = 'Lua REPL' })
end, 'Open Lua REPL (<cr> runs)')

-- bookmarks: global marks A-Z through the picker
leader('mm', function()
  local used = {}
  for _, m in ipairs(vim.fn.getmarklist()) do
    used[m.mark:sub(2)] = true
  end
  for c = ('A'):byte(), ('Z'):byte() do
    local ch = string.char(c)
    if not used[ch] then
      vim.cmd('normal! m' .. ch)
      return vim.notify('Marked line as ' .. ch)
    end
  end
  vim.notify('All global marks A-Z in use', vim.log.levels.WARN)
end, 'Mark current line')
leader('mo', pick('marks', { global = true, ['local'] = false }), 'Go to bookmark')
leader('ma', pick('marks'), 'Find a mark')

-- comment shortcuts
map('n', '<leader>;;', 'gcc', { remap = true, desc = 'Comment line' })
map('v', '<leader>;', 'gcc<Esc>', { remap = true, desc = 'Comment line' })
map('v', '<leader>;;', 'gcc<Esc>', { remap = true, desc = 'Comment line' })

-- treesitter incremental selection (native in 0.12: an / in)
map('n', 'gnn', 'van', { remap = true, desc = 'Start selecting nodes' })
-- old textsubjects keys mapped onto native node selection
map({ 'x', 'o' }, '.', 'an', { remap = true, desc = 'Grow selection' })
map({ 'x', 'o' }, ';', 'an', { remap = true, desc = 'Select outer node' })
map({ 'x', 'o' }, 'i;', 'in', { remap = true, desc = 'Select inner node' })
map({ 'x', 'o' }, ',', 'in', { remap = true, desc = 'Shrink selection' })
map('x', 'grc', 'an', { remap = true, desc = 'Grow selection (scope)' })

-- readline-style editing in insert and cmdline
map('!', '<C-a>', '<Home>')
map('!', '<C-e>', '<End>')
map('!', '<M-f>', '<S-Right>')
map('!', '<M-b>', '<S-Left>')
map('!', '<M-BS>', '<C-w>')
map('i', '<C-k>', '<C-o>D')
map('i', '<M-d>', '<C-o>dw')
map('c', '<C-k>', function()
  local pos = vim.fn.getcmdpos()
  vim.fn.setcmdline(vim.fn.getcmdline():sub(1, pos - 1), pos)
end)
map('c', '<M-d>', function()
  local line, pos = vim.fn.getcmdline(), vim.fn.getcmdpos()
  local rest = line:sub(pos):gsub('^%s*[%w_]*', '', 1)
  vim.fn.setcmdline(line:sub(1, pos - 1) .. rest, pos)
end)

-- LSP buffer maps (kept from the old setup)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('sharingan-lsp-keys', { clear = true }),
  callback = function(ev)
    local o = function(desc)
      return { buffer = ev.buf, silent = true, desc = desc }
    end
    map('n', 'gd', vim.lsp.buf.definition, o('Definition'))
    map('n', 'gD', vim.lsp.buf.declaration, o('Declaration'))
    map('n', 'gi', vim.lsp.buf.implementation, o('Implementation'))
    map('n', 'gr', vim.lsp.buf.references, o('References'))
    map('n', 'K', vim.lsp.buf.hover, o('Hover'))
    map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, o('Code action'))
    map('n', '<leader>d', vim.diagnostic.open_float, o('Line diagnostics'))
    map('n', '<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, o('Format'))
    map('n', '<leader>rn', vim.lsp.buf.rename, o('Rename'))
    map('n', '[d', function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, o('Prev diagnostic'))
    map('n', ']d', function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, o('Next diagnostic'))
  end,
})
