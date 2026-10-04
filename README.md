# sharingan-nvim

Lean Neovim 0.12+ config. Plain lazy.nvim specs, native LSP (`vim.lsp.config`/`vim.lsp.enable`), nvim-treesitter `main`, blink.cmp, snacks.nvim.

```
init.lua               bootstrap lazy.nvim (lockfile pinned in repo)
lua/config/options.lua options, autocmds, WSL clipboard
lua/config/keymaps.lua leader maps (all original keybinds kept)
lua/config/lsp.lua     servers + per-server settings
lua/plugins/*.lua      ui, editor, completion, treesitter, git
```

## LSP binaries

Install from your distro first (signed packages); mason (`:Mason`) is only a gap-filler and is appended to `PATH`, so it never shadows system binaries. Servers with no binary simply don't start.

Arch:

```sh
pacman -S --needed typescript typescript-language-server vscode-{css,html,json}-languageserver \
  yaml-language-server bash-language-server shellcheck shfmt taplo-cli marksman \
  tailwindcss-language-server dockerfile-language-server gopls rust-analyzer \
  lua-language-server pyright ruff clang tree-sitter-cli
```

Needs: `git`, a C compiler and `tree-sitter` CLI (parsers), `cargo` (blink.cmp builds its fuzzy matcher from the pinned tag), `rg`/`fd` (pickers).
