return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ensure = {
        'bash',
        'c',
        'cpp',
        'css',
        'diff',
        'dockerfile',
        'go',
        'gomod',
        'gosum',
        'hcl',
        'html',
        'java',
        'javascript',
        'jsdoc',
        'json',
        'kotlin',
        'lua',
        'luadoc',
        'make',
        'markdown',
        'markdown_inline',
        'proto',
        'python',
        'query',
        'regex',
        'ruby',
        'rust',
        'scss',
        'sql',
        'swift',
        'terraform',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'xml',
        'yaml',
      }
      local ts = require('nvim-treesitter')
      local missing = vim.tbl_filter(function(l)
        return not vim.list_contains(ts.get_installed(), l)
      end, ensure)
      if #missing > 0 then
        ts.install(missing)
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('sharingan-ts', { clear = true }),
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = 'VeryLazy',
    config = function()
      require('nvim-treesitter-textobjects').setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })
      local sel = require('nvim-treesitter-textobjects.select').select_textobject
      local mv = require('nvim-treesitter-textobjects.move')
      local sw = require('nvim-treesitter-textobjects.swap')
      local map = vim.keymap.set

      for lhs, q in pairs({
        af = '@function.outer',
        ['if'] = '@function.inner',
        ac = '@conditional.outer',
        ic = '@conditional.inner',
        ai = '@call.outer',
        ii = '@call.inner',
        ab = '@block.outer',
        ib = '@block.inner',
        as = '@statement.outer',
        is = '@statement.inner',
        aC = '@class.outer',
        iC = '@class.inner',
        al = '@loop.outer',
        il = '@loop.inner',
      }) do
        map({ 'x', 'o' }, lhs, function()
          sel(q, 'textobjects')
        end, { desc = 'Select ' .. q })
      end

      local moves = {
        { ']m', 'goto_next_start', '@function.outer' },
        { ']]', 'goto_next_start', '@class.outer' },
        { ']o', 'goto_next_start', { '@loop.inner', '@loop.outer' } },
        { ']s', 'goto_next_start', '@local.scope', 'locals' },
        { ']z', 'goto_next_start', '@fold', 'folds' },
        { ']M', 'goto_next_end', '@function.outer' },
        { '][', 'goto_next_end', '@class.outer' },
        { '[m', 'goto_previous_start', '@function.outer' },
        { '[[', 'goto_previous_start', '@class.outer' },
        { '[M', 'goto_previous_end', '@function.outer' },
        { '[]', 'goto_previous_end', '@class.outer' },
      }
      for _, m in ipairs(moves) do
        map({ 'n', 'x', 'o' }, m[1], function()
          mv[m[2]](m[3], m[4] or 'textobjects')
        end, { desc = m[2]:gsub('_', ' ') .. ' ' .. vim.inspect(m[3]) })
      end
      map({ 'x', 'o' }, ']d', function()
        mv.goto_next('@conditional.outer', 'textobjects')
      end, { desc = 'Next conditional' })
      map({ 'x', 'o' }, '[d', function()
        mv.goto_previous('@conditional.outer', 'textobjects')
      end, { desc = 'Prev conditional' })

      map('n', '<leader>a', function()
        sw.swap_next('@parameter.inner')
      end, { desc = 'Swap next parameter' })
      map('n', '<leader>A', function()
        sw.swap_previous('@parameter.inner')
      end, { desc = 'Swap previous parameter' })
    end,
  },
}
