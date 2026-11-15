{ pkgs, ... }:
{
  # Do not change after the first switch.
  home.stateVersion = "26.11";

  programs.home-manager.enable = true;

  # Keep this minimal; dotfiles are still deployed by `make deploy`.
  home.packages = with pkgs; [
    hello
  ];
}
