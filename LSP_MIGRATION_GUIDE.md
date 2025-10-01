# LSP Migration Guide - Neovim 0.11+

## ✅ What Was Changed

Your LSP configuration has been migrated from the deprecated `require('lspconfig')` framework to the new `vim.lsp.config()` API in Neovim 0.11+.

### Key Changes:

1. **Removed deprecated lspconfig setup**
   - Old: `require('lspconfig')[server].setup()`
   - New: `vim.lsp.config(server, opts)` + `vim.lsp.enable(server)`

2. **Simplified to only required LSPs/formatters:**
   - **Ruff** (Python linting + formatting)
   - **ESLint** (JS/TS linting with Prettier integration)

3. **Removed unnecessary dependencies:**
   - ❌ `null-ls` (no longer needed)
   - ❌ `mason-null-ls` (no longer needed)
   - ❌ `black`, `isort`, `pylint` (replaced by Ruff)
   - ❌ `biome`, `formatter.nvim` (replaced by ESLint + Prettier)
   - ❌ Old lspconfig framework dependencies

4. **Benefits:**
   - ✅ No more deprecation warnings
   - ✅ Faster native Ruff server (written in Rust)
   - ✅ Simpler, cleaner configuration
   - ✅ Auto-formatting on save for Python and JS/TS
   - ✅ Future-proof (uses Neovim 0.11+ native APIs)

## 📦 Installation Steps

### 1. Install Required Tools

You need to install Ruff and ensure ESLint + Prettier are available in your projects.

#### Option A: Via Mason (Automatic)

When you restart Neovim, Mason will automatically install:

- `ruff` (Python)
- `eslint` (JS/TS)

Or manually install via Mason:

```vim
:Mason
" Then search for 'ruff' and 'eslint' and press 'i' to install
```

#### Option B: System-wide Installation

**Ruff (Python):**

```bash
# Via pip
pip install ruff

# Via pipx (recommended)
pipx install ruff

# Verify installation
ruff --version  # Should be v0.4.5 or later
```

**ESLint + Prettier (JS/TS - per project):**

```bash
# In your JS/TS project directory
npm install --save-dev eslint prettier eslint-config-prettier eslint-plugin-prettier

# Or with yarn
yarn add --dev eslint prettier eslint-config-prettier eslint-plugin-prettier
```

### 2. Configure ESLint + Prettier (for JS/TS projects)

Create `.eslintrc.json` in your project root:

```json
{
  "extends": ["eslint:recommended", "plugin:prettier/recommended"],
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "rules": {
    "prettier/prettier": "error"
  }
}
```

Create `.prettierrc` in your project root:

```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2
}
```

### 3. Configure Ruff (for Python projects)

Create `pyproject.toml` in your project root (optional, Ruff works without it):

```toml
[tool.ruff]
# Set the maximum line length
line-length = 100

# Enable pycodestyle (`E`) and Pyflakes (`F`) codes by default
select = ["E", "F"]

# Allow fix for all enabled rules (when `--fix` is provided)
fixable = ["ALL"]

# Exclude specific directories
exclude = [
    ".bzr",
    ".direnv",
    ".eggs",
    ".git",
    ".git-rewrite",
    ".hg",
    ".mypy_cache",
    ".nox",
    ".pants.d",
    ".pytype",
    ".ruff_cache",
    ".svn",
    ".tox",
    ".venv",
    "__pypackages__",
    "_build",
    "buck-out",
    "build",
    "dist",
    "node_modules",
    "venv",
]

[tool.ruff.format]
# Use double quotes for strings
quote-style = "double"

# Indent with spaces
indent-style = "space"
```

### 4. Restart Neovim

```bash
# Close all Neovim instances
nvim
```

### 5. Verify Installation

Check that LSP is working:

**For Python files:**

```vim
:checkhealth vim.lsp
```

**For JavaScript/TypeScript files:**

```vim
:checkhealth vim.lsp
```

You should see:

- `ruff` attached to Python buffers
- `eslint` attached to JS/TS buffers

## 🔧 Usage

### Python (Ruff)

- **Linting**: Diagnostics appear automatically as you type
- **Format on save**: Automatic (configured)
- **Organize imports on save**: Automatic (configured)
- **Manual format**: `:lua vim.lsp.buf.format()`
- **Code actions**: `gra` (default Neovim 0.11 mapping)

### JavaScript/TypeScript (ESLint + Prettier)

- **Linting**: Diagnostics appear automatically as you type
- **Format on save**: Automatic (configured)
- **Manual format**: `:lua vim.lsp.buf.format()`
- **Code actions**: `gra` (default Neovim 0.11 mapping)
- **Auto-fix**: Happens automatically on save

## 🎯 Default Keymaps (Neovim 0.11+)

These are built-in to Neovim 0.11:

- `gra` - Code action
- `grn` - Rename
- `grr` - References
- `gri` - Implementation
- `grt` - Type definition
- `gO` - Document symbols
- `K` - Hover documentation
- `<C-s>` (Insert mode) - Signature help

## 🐛 Troubleshooting

### "ruff: command not found"

Install Ruff: `pip install ruff` or use Mason: `:Mason` → search 'ruff' → 'i'

### "eslint: command not found"

Install ESLint in your project: `npm install --save-dev eslint`

### ESLint not formatting with Prettier

Make sure you have:

1. `eslint-config-prettier` installed
2. `eslint-plugin-prettier` installed
3. `.eslintrc.json` extends `plugin:prettier/recommended`

### Deprecation warning still appearing

Make sure you've restarted Neovim completely. The old lspconfig code has been removed.

### Formatting not working on save

Check `:LspInfo` to see if the server is attached. Make sure the file is in a project with proper root markers (`.git`, `package.json`, `pyproject.toml`, etc.)

### Multiple formatters running

If you have other formatters configured (like in your editor settings), they might conflict. The LSP formatters should take precedence.

## 📝 Backup

A backup of your old configuration was saved to:

```
~/.config/nvim/lua/layers/editor/configs.lua.backup
```

## 🔗 Resources

- [Neovim LSP Documentation](https://neovim.io/doc/user/lsp.html)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [ESLint Documentation](https://eslint.org/)
- [Prettier Documentation](https://prettier.io/)
