vim.cmd([[
command Format :lua vim.lsp.buf.formatting()
]])

-- Format on save
vim.api.nvim_exec([[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost *.js,*.jsx,*.ts,*.tsx FormatWrite
augroup END
]], true)
