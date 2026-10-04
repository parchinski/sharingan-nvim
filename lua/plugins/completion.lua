return {
  {
    'saghen/blink.cmp',
    version = '1.*',
    -- build the fuzzy matcher from the pinned tag (--locked) instead of downloading a binary
    build = 'cargo build --release --locked',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = { 'rafamadriz/friendly-snippets' },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'none',
        ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<C-c>'] = { 'cancel', 'fallback' },
        ['<C-g>'] = { 'cancel', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-s>'] = { 'show_signature', 'hide_signature', 'fallback' },
      },
      completion = {
        list = { selection = { preselect = false, auto_insert = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 300 },
        accept = { auto_brackets = { enabled = true } },
      },
      signature = { enabled = true },
      sources = {
        default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      cmdline = { keymap = { preset = 'cmdline' }, completion = { menu = { auto_show = true } } },
      fuzzy = { implementation = 'prefer_rust_with_warning', prebuilt_binaries = { download = false } },
    },
  },

  { 'folke/lazydev.nvim', ft = 'lua', opts = { library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } } } },

  { 'nvim-mini/mini.pairs', event = 'InsertEnter', opts = {} },
}
