local configs = {}

function configs.mason()
  -- Configure diagnostic settings first
  vim.diagnostic.config({
    virtual_text = {
      prefix = '●',
      spacing = 4,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      focusable = true,
      style = 'minimal',
      border = 'rounded',
      source = 'always',
      header = '',
      prefix = '',
    },
  })

  require('mason').setup({
    ui = {
      keymaps = {
        toggle_package_expand = '<CR>',
        install_package = 'i',
        update_package = 'u',
        check_package_version = 'c',
        update_all_packages = 'U',
        check_outdated_packages = 'C',
        uninstall_package = 'X',
        cancel_installation = '<C-c>',
        apply_language_filter = '/',
      },
    },
  })

  -- Configure Mason to install only the LSPs/tools we need
  require('mason-lspconfig').setup({
    ensure_installed = {
      'ruff', -- Python linting + formatting
      'eslint', -- JS/TS linting with Prettier integration
      'ts_ls', -- TypeScript/JavaScript language server
    },
    automatic_setup = false, -- We'll manually configure via vim.lsp.config
  })

  -- Setup capabilities for autocompletion
  local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  -- Set global defaults for ALL LSP servers using vim.lsp.config
  vim.lsp.config('*', {
    capabilities = capabilities,
    root_markers = { '.git' },
    flags = {
      debounce_text_changes = 150,
    },
  })

  -- Configure Ruff native server for Python (linting + formatting)
  vim.lsp.config('ruff', {
    cmd = { 'ruff', 'server', '--preview' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'requirements.txt', '.git' },
    settings = {
      args = {},
    },
  })

  -- Configure ESLint with Prettier integration for JS/TS
  vim.lsp.config('eslint', {
    cmd = { 'vscode-eslint-language-server', '--stdio' },
    filetypes = {
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'vue',
      'svelte',
    },
    root_markers = {
      '.eslintrc',
      '.eslintrc.js',
      '.eslintrc.json',
      '.eslintrc.yml',
      'eslint.config.js',
      'package.json',
      '.git',
    },
    settings = {
      format = true,
      packageManager = 'npm',
      codeAction = {
        disableRuleComment = {
          enable = true,
          location = 'separateLine',
        },
        showDocumentation = {
          enable = true,
        },
      },
      codeActionOnSave = {
        enable = true,
        mode = 'all',
      },
      -- ESLint will use Prettier via eslint-config-prettier and eslint-plugin-prettier
    },
  })

  -- Configure TypeScript Language Server
  vim.lsp.config('ts_ls', {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = {
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
    },
    root_markers = {
      'tsconfig.json',
      'jsconfig.json',
      'package.json',
      '.git',
    },
    settings = {
      typescript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
    },
  })

  -- Enable configured servers
  vim.lsp.enable({ 'ruff', 'eslint', 'ts_ls' })

  -- Manual LSP startup using FileType autocmd (more reliable than vim.lsp.enable)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'python' },
    callback = function(args)
      local bufnr = args.buf
      if vim.bo[bufnr].filetype == 'python' then
        -- Start Ruff LSP manually for Python files
        vim.lsp.start({
          name = 'ruff',
          cmd = { 'ruff', 'server', '--preview' },
          filetypes = { 'python' },
          root_dir = vim.fn.getcwd(),
          capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
        })
      end
    end,
  })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    callback = function(args)
      local bufnr = args.buf
      local ft = vim.bo[bufnr].filetype
      if ft == 'javascript' or ft == 'javascriptreact' or ft == 'typescript' or ft == 'typescriptreact' then
        -- Start ESLint LSP manually for JS/TS files
        vim.lsp.start({
          name = 'eslint',
          cmd = { 'vscode-eslint-language-server', '--stdio' },
          filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue', 'svelte' },
          root_dir = vim.fn.getcwd(),
          capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
          settings = {
            format = true,
            packageManager = 'npm',
            codeAction = {
              disableRuleComment = { enable = true, location = 'separateLine' },
              showDocumentation = { enable = true },
            },
            codeActionOnSave = { enable = true, mode = 'all' },
          },
        })

        -- Start TypeScript LSP manually for JS/TS files
        vim.lsp.start({
          name = 'ts_ls',
          cmd = { 'typescript-language-server', '--stdio' },
          filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
          root_dir = vim.fn.getcwd(),
          capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
          settings = {
            typescript = {
              inlayHints = {
                includeInlayEnumMemberValueHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayVariableTypeHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayEnumMemberValueHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayVariableTypeHints = true,
              },
            },
          },
        })
      end
    end,
  })

  -- Setup LspAttach autocmd for buffer-local settings and auto-formatting
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      -- Enable completion triggered by <c-x><c-o>
      vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

      -- Enable inlay hints if supported
      if client.supports_method('textDocument/inlayHint') then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end

      -- LSP key mappings
      local opts = { buffer = bufnr, noremap = true, silent = true }

      -- Navigation
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

      -- Code actions
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
      vim.keymap.set('v', '<leader>ca', vim.lsp.buf.code_action, opts)

      -- Diagnostics
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
      vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)

      -- Formatting
      vim.keymap.set('n', '<leader>f', function()
        vim.lsp.buf.format({ async = true })
      end, opts)

      -- Rename
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

      -- Auto-format on save for Python files using Ruff
      if client.name == 'ruff' and client.supports_method('textDocument/formatting') then
        vim.api.nvim_create_autocmd('BufWritePre', {
          buffer = bufnr,
          group = vim.api.nvim_create_augroup('RuffFormat', { clear = false }),
          callback = function()
            vim.lsp.buf.format({
              bufnr = bufnr,
              id = client.id,
              timeout_ms = 2000,
            })
          end,
        })
      end

      -- Organize imports on save for Python using Ruff
      if client.name == 'ruff' and client.supports_method('textDocument/codeAction') then
        vim.api.nvim_create_autocmd('BufWritePre', {
          buffer = bufnr,
          group = vim.api.nvim_create_augroup('RuffOrganizeImports', { clear = false }),
          callback = function()
            vim.lsp.buf.code_action({
              context = { only = { 'source.organizeImports' } },
              apply = true,
            })
          end,
        })
      end

      -- Auto-fix/format on save for JS/TS files using ESLint
      if client.name == 'eslint' and client.supports_method('textDocument/formatting') then
        vim.api.nvim_create_autocmd('BufWritePre', {
          buffer = bufnr,
          group = vim.api.nvim_create_augroup('EslintFormat', { clear = false }),
          callback = function()
            vim.lsp.buf.format({
              bufnr = bufnr,
              id = client.id,
              timeout_ms = 2000,
            })
          end,
        })
      end
    end,
  })
end

function configs.project()
  local project = require('project_nvim')
  project.setup({
    exclude_dirs = { '*//*' },
    detection_methods = { 'pattern' },
    patterns = { '.git' },
  })
end

function configs.lspsaga()
  local saga = require('lspsaga')
  local ui_options = require('layers.ui.options')
  saga.setup({
    ui = {
      winblend = ui_options.transparency,
    },
    lightbulb = {
      enable = false,
    },
    symbol_in_winbar = {
      enable = false,
    },
    diagnostic = {
      border_follow = false,
      keys = {
        exec_action = 'o',
        quit = 'q',
        go_action = 'g',
      },
    },
    finder = {
      keys = {
        quit = { 'q', '<ESC>' },
      },
    },
    code_action = {
      show_server_name = true,
      keys = {
        quit = { 'q', '<ESC>' },
        exec = '<CR>',
      },
    },
    rename = {
      in_select = false,
      quit = '<ESC>',
      exec = '<CR>',
      confirm = '<CR>',
    },
  })
end

function configs.lspfuzzy()
  local lspfuzzy = require('lspfuzzy')
  lspfuzzy.setup()
end

function configs.treesitter()
  local treesitter = require('nvim-treesitter.configs')
  local ui_options = require('layers.ui.options')
  treesitter.setup({
    autotag = {
      enable = true,
    },
    indent = {
      enable = false,
    },
    -- One of "all", "maintained" (parsers with maintainers), or a list of languages
    ensure_installed = 'all',
    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,
    -- List of parsers to ignore installing
    ignore_install = {},
    playground = {
      enable = true,
      disable = {},
      updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
      persist_queries = false, -- Whether the query persists across vim sessions
      keybindings = {
        toggle_query_editor = 'o',
        toggle_hl_groups = 'i',
        toggle_injected_languages = 't',
        toggle_anonymous_nodes = 'a',
        toggle_language_display = 'I',
        focus_language = 'f',
        unfocus_language = 'F',
        update = 'R',
        goto_node = '<cr>',
        show_help = '?',
      },
    },
    highlight = {
      -- `false` will disable the whole extension
      enable = true,

      -- list of language that will be disabled
      disable = {},

      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = false,
    },
    rainbow = {
      enable = ui_options.enable_rainbow,
      -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
      extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
      max_file_lines = nil, -- Do not enable for files with more than n lines, int
      -- colors = {}, -- table of hex strings
      -- termcolors = {} -- table of colour name strings
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = 'gnn',
        node_incremental = '.',
        scope_incremental = 'grc',
        node_decremental = ',',
      },
    },
    -- textsubjects = {
    --   enable = true,
    --   prev_selection = ',', -- (Optional) keymap to select the previous selection
    --   keymaps = {
    --     ['.'] = 'textsubjects-smart',
    --     -- [';'] = 'textsubjects-container-outer',
    --   },
    -- },

    textobjects = {
      select = {
        enable = true,
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@conditional.outer',
          ['ic'] = '@conditional.inner',
          ['ai'] = '@call.outer',
          ['ii'] = '@call.inner',
          ['ab'] = '@block.outer',
          ['ib'] = '@block.inner',
          ['is'] = '@statement.inner',
          ['as'] = '@statement.outer',
          ['aC'] = '@class.outer',
          ['iC'] = '@class.inner',
          ['al'] = '@loop.outer',
          ['il'] = '@loop.inner',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = { query = '@class.outer', desc = 'Next class start' },
          [']o'] = '@loop.*',
          [']s'] = { query = '@scope', query_group = 'locals', desc = 'Next scope' },
          [']z'] = { query = '@fold', query_group = 'folds', desc = 'Next fold' },
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
        goto_next = {
          [']d'] = '@conditional.outer',
        },
        goto_previous = {
          ['[d'] = '@conditional.outer',
        },
      },
      lsp_interop = {
        enable = true,
        border = 'none',
        peek_definition_code = {
          ['<leader>sd'] = '@function.outer',
          ['<leader>sD'] = '@class.outer',
        },
      },
    },
  })
end

function configs.telescope()
  local telescope = require('telescope')
  local options = require('layers.editor.options')
  local ui_options = require('layers.ui.options')

  local fb_actions = require('telescope').extensions.file_browser.actions

  local previewers = require('telescope.previewers')

  local new_maker = function(filepath, bufnr, opts)
    opts = opts or {}

    filepath = vim.fn.expand(filepath)
    vim.loop.fs_stat(filepath, function(_, stat)
      if not stat then
        return
      end
      if stat.size > 100000 then
        return
      else
        previewers.buffer_previewer_maker(filepath, bufnr, opts)
      end
    end)
  end

  local theme = options.telescope_theme
  telescope.setup({
    defaults = {
      vimgrep_arguments = {
        'rg',
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
      },
      mappings = {
        i = {
          ['<C-a>'] = { '<esc>0i', type = 'command' },
          ['<Esc>'] = require('telescope.actions').close,
        },
      },
      selection_caret = '  ',
      entry_prefix = '  ',
      initial_mode = 'insert',
      selection_strategy = 'reset',
      sorting_strategy = 'ascending',
      layout_strategy = 'horizontal',
      layout_config = {
        horizontal = {
          prompt_position = 'top',
          preview_width = 0.55,
          results_width = 0.8,
        },
        vertical = {
          mirror = false,
        },
        width = 0.87,
        height = 0.80,
        preview_cutoff = 120,
      },
      -- file_sorter = require("telescope.sorters").get_fuzzy_file,
      -- file_ignore_patterns = { "node_modules/", "\\.git/" },
      generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
      path_display = { 'smart' },
      winblend = ui_options.transparency,
      border = {},
      borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
      color_devicons = true,
      use_less = true,
      set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
      file_previewer = require('telescope.previewers').vim_buffer_cat.new,
      grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
      qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
      -- Developer configurations: Not meant for general override
      buffer_previewer_maker = new_maker,
    },
    extensions = {
      ['ui-select'] = {
        -- TODO: specify the cursor theme for codeaction only
        require('telescope.themes').get_cursor({}),
      },
      file_browser = {
        theme = theme,
        mappings = {
          ['i'] = {
            -- your custom insert mode mappings
            ['<C-h>'] = fb_actions.goto_parent_dir,
            ['<C-e>'] = fb_actions.rename,
            ['<C-c>'] = fb_actions.create,
          },
          ['n'] = {
            -- your custom normal mode mappings
          },
        },
      },
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      },
      media_files = {
        -- filetypes whitelist
        -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
        filetypes = { 'png', 'webp', 'jpg', 'jpeg' },
        find_cmd = 'rg', -- find command (defaults to `fd`)
      },
    },
    pickers = {
      buffers = {
        theme = theme,
      },
      find_files = {
        theme = theme,
        hidden = true,
      },
      oldfiles = {
        theme = theme,
        hidden = true,
      },
      live_grep = {
        debounce = 100,
        theme = theme,
        on_input_filter_cb = function(prompt)
          -- AND operator for live_grep like how fzf handles spaces with wildcards in rg
          return { prompt = prompt:gsub('%s', '.*') }
        end,
      },
      current_buffer_fuzzy_find = {
        theme = theme,
      },
      commands = {
        theme = theme,
      },
      lsp_document_symbols = {
        theme = theme,
      },
      diagnostics = {
        theme = theme,
        initial_mode = 'normal',
      },
      lsp_references = {
        theme = 'cursor',
        initial_mode = 'normal',
        layout_config = {
          width = 0.8,
          height = 0.4,
        },
      },
      lsp_code_actions = {
        theme = 'cursor',
        initial_mode = 'normal',
      },
    },
  })

  telescope.load_extension('projects')
end

configs.dap = function()
  local dap = require('dap')
  for name, adapter in pairs(require('layers.editor.utils').get_dap_adapters()) do
    dap.adapters[name] = adapter
  end
  for name, configuration in pairs(require('layers.editor.utils').get_dap_configurations()) do
    dap.configurations[name] = configuration
  end
end

configs.dap_go = function()
  require('dap-go').setup()
end

configs.dapui = function()
  vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })
  vim.fn.sign_define('DapStopped', { text = '👉', texthl = '', linehl = '', numhl = '' })
  local dapui = require('dapui')
  dapui.setup()
end

configs.dap_virtual_text = function()
  local dap_virtual_text = require('nvim-dap-virtual-text')
  dap_virtual_text.setup({ enabled = true, enabled_commands = true, all_frames = true })
end

configs.trouble = function()
  local signs = {
    -- icons / text used for a diagnostic
    error = '󰅚',
    warning = '',
    -- for vim.fn.sign_define
    warn = '',
    hint = '',
    information = '',
    -- for vim.fn.sign_define
    info = '',
    other = '',
  }

  local trouble = require('trouble')
  trouble.setup({})

  for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type:gsub('^%l', string.upper)
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end
end

configs.nvimtree = function()
  local nvimtree = require('nvim-tree')
  nvimtree.setup({
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    renderer = {
      add_trailing = false,
      highlight_git = false,
      highlight_opened_files = 'none',
      root_folder_label = false,
      root_folder_modifier = table.concat({ ':t:gs?$?/..', string.rep(' ', 1000), '?:gs?^??' }),
      icons = {
        show = {
          folder = true,
          file = true,
          git = true,
        },
        glyphs = {
          default = '',
          symlink = '',
          git = {
            deleted = '',
            ignored = '◌',
            renamed = '➜',
            staged = '✓',
            unmerged = '',
            unstaged = '✗',
            untracked = '★',
          },
          folder = {
            default = '',
            empty = '',
            empty_open = '',
            open = '',
            symlink = '',
            symlink_open = '',
          },
        },
      },
      indent_markers = {
        enable = true,
      },
    },
    filters = {
      dotfiles = false,
    },
    disable_netrw = true,
    hijack_netrw = true,
    -- ignore_ft_on_setup = { 'dashboard' },
    open_on_tab = false,
    hijack_cursor = true,
    hijack_unnamed_buffer_when_opening = false,
    update_cwd = true,
    update_focused_file = {
      enable = true,
      update_cwd = false,
      update_root = true,
    },
    diagnostics = {
      enable = true,
      icons = {
        hint = '',
        info = '',
        warning = '',
        error = '',
      },
    },
    git = {
      enable = true,
      ignore = true,
      timeout = 500,
    },
    view = {
      side = 'left',
      width = 30,
    },
    actions = {
      open_file = {
        resize_window = true,
      },
    },
  })
end

configs.toggleterm = function()
  local toggleterm = require('toggleterm')
  toggleterm.setup({
    size = function(term)
      if term.direction == 'horizontal' then
        return 17
      elseif term.direction == 'vertical' then
        return vim.o.columns * 0.4
      end
    end,
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
    start_in_insert = true,
    insert_mappings = false, -- whether or not the open mapping applies in insert mode
    persist_size = false,
    direction = 'horizontal',
    close_on_exit = true,
    shell = vim.o.shell,
  })
end

configs.hop = function()
  local hop = require('hop')
  hop.setup({ keys = 'etovxqpdygfblzhckisuran' })
end

configs.leap = function()
  local leap = require('leap')
  leap.set_default_keymaps()
end

configs.numb = function()
  local numb = require('numb')
  numb.setup()
end

configs.spellsitter = function()
  local spellsitter = require('spellsitter')
  spellsitter.setup({
    enable = true,
  })
end

function configs.osc52()
  local function copy(lines, _)
    require('osc52').copy(table.concat(lines, '\n'))
  end

  local function paste()
    return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
  end

  vim.g.clipboard = {
    name = 'osc52',
    copy = { ['+'] = copy, ['*'] = copy },
    paste = { ['+'] = paste, ['*'] = paste },
  }
  vim.opt.clipboard:append('unnamedplus')
end

function configs.auto_save()
  require('auto-save').setup()
end

function configs.nvim_window()
  require('nvim-window').setup({
    -- The characters available for hinting windows.
    chars = {
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '0',
    },
    -- A group to use for overwriting the Normal highlight group in the floating
    -- window. This can be used to change the background color.
    normal_hl = 'BlackOnLightYellow',
    -- The highlight group to apply to the line that contains the hint characters.
    -- This is used to make them stand out more.
    hint_hl = 'Bold',
    -- The border style to use for the floating window.
    border = 'none',
  })
end

function configs.guess_indent()
  require('guess-indent').setup()
end

function configs.telescope_fzf()
  require('telescope').load_extension('fzf')
end

function configs.telescope_frecency()
  require('telescope').load_extension('frecency')
end

function configs.telescope_media_files()
  require('telescope').load_extension('media_files')
end

function configs.telescope_file_browser()
  require('telescope').load_extension('file_browser')
end

function configs.telescope_zoxide()
  require('telescope').load_extension('zoxide')
end

function configs.telescope_dap()
  require('telescope').load_extension('dap')
end

function configs.telescope_ui_select()
  require('telescope').load_extension('ui-select')
end

function configs.comment()
  require('Comment').setup()
end

function configs.glance()
  local glance = require('glance')
  local actions = glance.actions
  glance.setup({
    mappings = {
      list = {
        ['j'] = actions.next, -- Bring the cursor to the next item in the list
        ['k'] = actions.previous, -- Bring the cursor to the previous item in the list
        ['<C-n>'] = actions.next_location, -- Bring the cursor to the next item in the list
        ['<C-p>'] = actions.previous_location, -- Bring the cursor to the previous item in the list
        ['<Down>'] = actions.next,
        ['<Up>'] = actions.previous,
        ['<Tab>'] = actions.next, -- Bring the cursor to the next location skipping groups in the list
        ['<S-Tab>'] = actions.previous, -- Bring the cursor to the previous location skipping groups in the list
        ['<C-u>'] = actions.preview_scroll_win(5),
        ['<C-d>'] = actions.preview_scroll_win(-5),
        ['v'] = actions.jump_vsplit,
        ['s'] = actions.jump_split,
        ['t'] = actions.jump_tab,
        ['<CR>'] = actions.jump,
        ['<C-m>'] = actions.jump,
        ['o'] = actions.jump,
        ['<leader>l'] = actions.enter_win('preview'), -- Focus preview window
        ['q'] = actions.close,
        ['Q'] = actions.close,
        ['<Esc>'] = actions.close,
        -- ['<Esc>'] = false -- disable a mapping
      },
      preview = {
        ['Q'] = actions.close,
        ['<Tab>'] = actions.next_location,
        ['<S-Tab>'] = actions.previous_location,
        ['<leader>l'] = actions.enter_win('list'), -- Focus list window
      },
    },
  })
end

function configs.readline()
  local readline = require('readline')
  vim.keymap.set('!', '<M-f>', readline.forward_word)
  vim.keymap.set('!', '<M-b>', readline.backward_word)
  vim.keymap.set('!', '<C-a>', readline.beginning_of_line)
  vim.keymap.set('!', '<C-e>', readline.end_of_line)
  vim.keymap.set('!', '<M-d>', readline.kill_word)
  vim.keymap.set('!', '<M-BS>', readline.backward_kill_word)
  vim.keymap.set('!', '<C-w>', readline.unix_word_rubout)
  vim.keymap.set('!', '<C-k>', readline.kill_line)
  vim.keymap.set('!', '<C-u>', readline.backward_kill_line)
end

function configs.inlay_hints()
  require('inlay-hints').setup()
end

function configs.bookmarks()
  require('bookmarks').setup({
    json_db_path = vim.fs.normalize(vim.fn.stdpath('config') .. '/bookmarks.db.json'),
  })
end

function configs.refactoring()
  require('refactoring').setup()
end

function configs.smart_open()
  require('telescope').load_extension('smart_open')
end

function configs.ts_context_commentstring()
  require('ts_context_commentstring').setup()
end

return configs
