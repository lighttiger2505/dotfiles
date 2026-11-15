{ pkgs, ... }:
{
  # Determinate Nix manages the Nix daemon and nix.conf, so nix-darwin must not.
  nix.enable = false;

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "lighttiger2505";
  users.users.lighttiger2505.home = "/Users/lighttiger2505";

  # Use a stable system path (not a store path) so GC or upgrades never break the login shell.
  environment.systemPackages = [ pkgs.zsh ];
  environment.shells = [ "/run/current-system/sw/bin/zsh" ];

  # Set the login shell without making nix-darwin manage the whole user (knownUsers).
  system.activationScripts.postActivation.text = ''
    shell=/run/current-system/sw/bin/zsh
    if [ "$(dscl . -read /Users/lighttiger2505 UserShell | awk '{print $2}')" != "$shell" ]; then
      dscl . -create /Users/lighttiger2505 UserShell "$shell"
    fi
  '';

  # Enable dictation and start it by pressing the right Command key twice.
  system.defaults.CustomUserPreferences = {
    "com.apple.HIToolbox".AppleDictationAutoEnable = true;
    "com.apple.assistant.support"."Dictation Enabled" = true;
    "com.apple.symbolichotkeys".AppleSymbolicHotKeys."164" = {
      enabled = true;
      value = {
        # 18446744073708503023 as unsigned 64-bit; Nix only has signed integers.
        parameters = [ 1048592 (-1048593) ];
        type = "modifier";
      };
    };
  };

  # Homebrew itself must already be installed; nix-darwin only manages casks.
  homebrew = {
    enable = true;
    taps = [ "nikitabobko/tap" "camguillory/tap" ];
    casks = [
      "nikitabobko/tap/aerospace"
      "camguillory/tap/audio-priority-bar"
      "raycast"
      "rambox"
      "raindropio"
      "obsidian"
      "docker-desktop"
      "ghostty"
      "dropbox"
      "1password"
      "google-japanese-ime"
      "claude"
    ];
  };

  # Do not change after the first switch.
  system.stateVersion = 6;
}
