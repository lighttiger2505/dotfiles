{ ... }:
{
  # Determinate Nix manages the Nix daemon and nix.conf, so nix-darwin must not.
  nix.enable = false;

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "lighttiger2505";
  users.users.lighttiger2505.home = "/Users/lighttiger2505";

  # Homebrew itself must already be installed; nix-darwin only manages casks.
  homebrew = {
    enable = true;
    taps = [ "nikitabobko/tap" ];
    casks = [
      "nikitabobko/tap/aerospace"
      "raycast"
      "rambox"
      "raindropio"
      "obsidian"
      "docker-desktop"
      "ghostty"
      "dropbox"
      "1password"
      "google-japanese-ime"
    ];
  };

  # Do not change after the first switch.
  system.stateVersion = 6;
}
