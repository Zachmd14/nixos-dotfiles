{
  description = "Personal NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    potatofox = {
      url = "git+https://codeberg.org/awwpotato/PotatoFox";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";

      # Change this to your login name. The name must be a valid Unix user.
      username = "zach";

      mkHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = { inherit inputs username; };

          modules = [
            ./modules/system.nix
            ./hosts/${hostname}/default.nix
            home-manager.nixosModules.default
            {
              home-manager = {
                extraSpecialArgs = { inherit inputs username; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import ./modules/home.nix;
                backupFileExtension = "bak";
              };
            }
          ];
        };
    in
    {
      nixosConfigurations.zach-nixos = mkHost "zach-nixos";
    };
}
