# AGENTS.md

## What this repo is

Personal dotfiles repository for zsh, Neovim, and various tool configurations. Not an application codebase.

## Key commands

- `make deploy` — Symlinks all dotfiles and `.config/*` into `$HOME`. Review `Makefile` when adding new top-level dotfiles or config directories.
- `make list` — Shows which files will be deployed.
- `make linkdropbox` — Links Dropbox-backed vaults and memo directories.
- `sudo darwin-rebuild switch --flake .` — Applies nix-darwin + home-manager config (`flake.nix`, `nix/`). Uses Determinate Nix, so `nix.enable = false`.

## Architecture notes

### zsh
- `.zshrc` is a thin loader: sources files from `.zsh/` via `src()` (auto-compiles to `.zwc`) and `zsh-defer` for lazy loading.
- Add new zsh logic in `.zsh/*.zsh`, not directly in `.zshrc`.
- `.zsh/path.zsh` and `.zsh/env.zsh` set up PATH, Go, mise, and locale.

### Neovim
- Lua-based config in `.config/nvim/`. Entry point: `init.lua`.
- Uses `lazy.nvim` (lockfile: `.config/nvim/lazy-lock.json`). Plugins declared in `.config/nvim/lua/plugins/`.

### Tool management
- `mise` manages language versions and CLI tools. Config: `.config/mise/config.toml`.
- Notable tools pinned: Go 1.26.2, Node 25, pnpm 10.12.2, Python 3.14.2, uv 0.9.25, Bun 1.3.12.

### Claude Code self-configuration
- `.claude/` contains Claude Code's own settings: `CLAUDE.md`, `settings.json`, `agents/`, `rules/`, `skills/`.
- `settings.json` references shell scripts in `scripts/` (e.g., `claude-notification`, `claude_statusline.sh`).
- `.claude/skills/` includes custom skills (e.g., `tmux-workflow`, `commit-push-pr`, `failure-log`).

## Style conventions

- **Comments and READMEs must be in English** for any personal OSS repos under `~/src/github.com/lighttiger2505` (per `.claude/CLAUDE.md`).
- Do not refactor or reformat existing config files unless asked; match existing style.

## What not to change

- Do not modify `.zwc` compiled files; they are regenerated automatically.
- Do not add heavy startup logic to `.zshrc`; use `.zsh/` modules.
- `dummy` is a socket file; leave it untouched.

## Git workflow

- `.gitmessage.txt` and `.gitmessage-ja.txt` are commit message templates.
- `worktrunk` (`wt`) is used for git worktree workflows (see `.claude/skills/tmux-workflow/`).
- `scripts/` contains helper utilities used by shell hooks and Claude Code hooks.

## Missing context

If the user wants to add new dotfiles or configs, check whether the `Makefile` `EXCLUSIONS` list needs updating.
