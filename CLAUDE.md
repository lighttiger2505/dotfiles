# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles (zsh, Neovim, tmux, terminal emulators, Linux WMs, etc.), not an application. There is no build or test suite (only `make lint`). Comments and READMEs must be written in English (personal OSS under `~/src/github.com/lighttiger2505`).

## Commands

- `make list` — show what `make deploy` will link.
- `make deploy` — symlink every top-level dotfile (`.??*`), each `.config/*` directory, `scripts/`, and each `.claude/*` entry into `$HOME` (`~/.config/<dir>`, `~/scripts`, `~/.claude/<entry>`). Files are therefore live-edited in place; there is nothing to "build".
- `make clean` — remove only symlinks that point back into this repo.
- `make linkdropbox` — link Dropbox-backed vaults/memo dirs (macOS path).
- `make mise-install` — `mise install` with a `gh` token.
- `make lint` — run shellcheck, `zsh -n`, luacheck, jq (JSON) and biome (JSONC) on tracked files; `make lint-<sh|zsh|lua|json|jsonc>` runs a single check.
- `sudo darwin-rebuild switch --flake .` — apply nix-darwin + home-manager (`flake.nix`, `nix/darwin.nix`, `nix/home.nix`). First time: `sudo nix run nix-darwin -- switch --flake .#torano-ana`. Uses Determinate Nix (`nix.enable = false`). Nix is intentionally minimal; dotfiles are still deployed by `make deploy`, not home-manager.

## Architecture

- **Deploy model**: `Makefile` globs top-level dotfiles and `.config/*`, minus `EXCLUSIONS` (`.DS_Store .git .gitmodules .config .claude .claude-private .claude-work`). When adding a new top-level file/dir that should *not* be linked, update `EXCLUSIONS`. `.claude/` is linked entry-by-entry, so `.claude/CLAUDE.md` here is the user's *global* Claude instructions (not this file).
- **zsh**: `.zshrc` is a thin loader. It sources `.zsh/*.zsh` through `src()` (auto-`zcompile` to `.zwc` when stale) and defers `command_hook_lazy.zsh` via `zsh-defer`. Put new logic in `.zsh/*.zsh`, keep startup light, and never edit `.zwc` files. PATH/Go/mise/locale live in `.zsh/path.zsh` and `.zsh/env.zsh`.
- **Neovim** (`.config/nvim`): `init.lua` requires `config.*` modules in order, then lazy.nvim (`config/lazy.lua`, `defaults.lazy = true`) imports every spec in `lua/plugins/*.lua` (one file per theme: lsp, git, ui, ...). Lockfile: `lazy-lock.json`.
- **Tool versions**: `mise` (`.config/mise/config.toml`).
- **Multiple desktops**: macOS (aerospace, ghostty, wezterm, kitty, alacritty) and Linux (i3, sway, hypr, waybar, wofi, dunst) configs coexist; tmux config is split into `.config/tmux/conf.d/*.tmux` sourced from `tmux.conf`.
- **Claude Code config** lives in `.claude/` (`settings.json`, `agents/`, `rules/`, `statusline.sh`, `notification.sh`).
- **Git**: `.gitmessage.txt` / `.gitmessage-ja.txt` are commit templates; `worktrunk` (`wt`) config is in `.config/worktrunk/`.

## Conventions

- Don't refactor or reformat existing config; match the existing style.
- Commit directly to `master` by default; only create a feature branch for breaking changes.
- `AGENTS.md` overlaps with this file; some of its details (e.g. `.claude/skills/`, named scripts) don't match what is committed, so verify before relying on them.
- `dummy` (if present) is a socket file; leave it alone.
