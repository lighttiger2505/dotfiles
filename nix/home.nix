{ pkgs, lig, ... }:
{
  # Do not change after the first switch.
  home.stateVersion = "26.11";

  programs.home-manager.enable = true;

  # Keep this minimal; dotfiles are still deployed by `make deploy`.
  home.packages = with pkgs; [
    hello
    ripgrep
    stylua
    lua-language-server
    zoxide
    atuin
    sd
    gh
    delta
    jq
    fzf
    shellcheck
    worktrunk
    bat
    fd
    ghq
    eza
    tig
    rtk
    tmux
    deja
    zsh-patina
    hackgen-nf-font
    lig.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
