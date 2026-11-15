.dotfiles
=========
My zsh and Neovim settings

## Setup

### 1. Clone

```sh
git clone --recursive https://github.com/lighttiger2505/dotfiles ~/src/github.com/lighttiger2505/dotfiles
cd ~/src/github.com/lighttiger2505/dotfiles
```

### 2. Install Nix packages (nix-darwin + home-manager)

Install [Determinate Nix](https://determinate.systems/nix-installer/) and Homebrew first.

Personal and work machines are defined as separate hosts in `flake.nix`.
To support another machine, add an entry to `darwinConfigurations`.

```sh
# First time (use the host name defined in flake.nix)
sudo nix run nix-darwin -- switch --flake .#<host>
# After that
sudo darwin-rebuild switch --flake .
```

### 3. Deploy dotfiles

Symlink the dotfiles into `$HOME`.

```sh
make list    # Preview what will be linked
make deploy
```

### 4. Install tools with mise

```sh
gh auth login    # Needed for the GitHub token
make mise-install
```

### 5. (Optional) Link Dropbox-backed directories

```sh
make linkdropbox
```

## Maintenance

```sh
make lint     # Run all linters
make clean    # Remove symlinks created by `make deploy`
```

### Update Nix packages

```sh
nix flake update                      # Update flake.lock (or `nix flake update nixpkgs` for one input)
sudo darwin-rebuild switch --flake .  # Apply
```

To roll back, run `git checkout flake.lock` and switch again.
