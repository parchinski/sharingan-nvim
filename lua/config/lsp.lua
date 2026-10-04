-- Native LSP (vim.lsp.config / vim.lsp.enable). Server definitions come from
-- nvim-lspconfig's lsp/ directory. Binaries are preferred from signed Arch
-- packages; mason only fills gaps and is appended to PATH so it never shadows
-- a system binary. Servers whose binary is missing simply never start.

vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  root_markers = { '.git' },
})

local inlay_ts = {
  inlayHints = {
    includeInlayEnumMemberValueHints = true,
    includeInlayFunctionLikeReturnTypeHints = true,
    includeInlayFunctionParameterTypeHints = true,
    includeInlayParameterNameHints = 'all',
    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
    includeInlayPropertyDeclarationTypeHints = true,
    includeInlayVariableTypeHints = true,
  },
}
vim.lsp.config('ts_ls', { settings = { typescript = inlay_ts, javascript = inlay_ts } })
vim.lsp.config('ruff', { init_options = { settings = { lineLength = 100 } } })
-- ruff owns lint/imports; pyright only does types
vim.lsp.config('pyright', {
  settings = {
    pyright = { disableOrganizeImports = true },
    python = { analysis = { ignore = { '*' } } },
  },
})
vim.lsp.config('gopls', {
  settings = {
    gopls = { gofumpt = true, staticcheck = true, hints = { parameterNames = true, assignVariableTypes = true } },
  },
})
vim.lsp.config('lua_ls', { settings = { Lua = { hint = { enable = true } } } })
vim.lsp.config('yamlls', { settings = { yaml = { schemaStore = { enable = true } } } })
-- upstream falls back to any .git root; only attach in real tailwind projects
vim.lsp.config('tailwindcss', {
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local cfg = vim.fs.find(function(name)
      return name:match('^tailwind%.config%.') or name:match('^postcss%.config%.')
    end, { path = fname, upward = true })[1]
    if cfg then
      return on_dir(vim.fs.dirname(cfg))
    end
    local pkg = vim.fs.find('package.json', { path = fname, upward = true })[1]
    if pkg then
      local ok, txt = pcall(vim.fn.readfile, pkg)
      if ok and table.concat(txt, '\n'):find('"tailwindcss"', 1, true) then
        on_dir(vim.fs.dirname(pkg))
      end
    end
  end,
})

vim.lsp.enable({
  -- web
  'ts_ls',
  'eslint',
  'html',
  'cssls',
  'jsonls',
  'tailwindcss',
  -- systems
  'gopls',
  'rust_analyzer',
  'clangd',
  'zls',
  -- scripting
  'pyright',
  'ruff',
  'lua_ls',
  'bashls',
  -- config / data / docs
  'yamlls',
  'taplo',
  'marksman',
  'dockerls',
  'terraformls',
  'buf_ls',
  -- jvm (start only if installed)
  'jdtls',
  'kotlin_language_server',
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('sharingan-lsp', { clear = true }),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    if client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
    if client.name == 'ruff' then
      client.server_capabilities.hoverProvider = false -- pyright hovers
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = ev.buf,
        group = vim.api.nvim_create_augroup('sharingan-ruff-' .. ev.buf, { clear = true }),
        callback = function()
          vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 2000 })
        end,
      })
    end
  end,
})
