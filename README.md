.dotfiles
=========
My zsh and Neovim settings

## Nix (nix-darwin + home-manager)

```sh
# First time
sudo nix run nix-darwin -- switch --flake .#torano-ana
# After that
sudo darwin-rebuild switch --flake .
```
