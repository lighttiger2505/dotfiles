{
  description = "lighttiger2505's nix-darwin and home-manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lig = {
      url = "github:KevenGoncalves/lig";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nix-darwin, home-manager, lig, ... }:
    let
      mkHost = { username, system }: nix-darwin.lib.darwinSystem {
        specialArgs = { inherit username system; };
        modules = [
          ./nix/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit lig; };
            home-manager.users.${username} = import ./nix/home.nix;
          }
        ];
      };
    in {
      darwinConfigurations = {
        "torano-ana" = mkHost { username = "lighttiger2505"; system = "aarch64-darwin"; };
        "PC-71285" = mkHost { username = "toshikazu.ohashi"; system = "aarch64-darwin"; };
      };
    };
}
