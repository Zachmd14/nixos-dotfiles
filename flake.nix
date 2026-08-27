{
  description = "Personnal Flake";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fetch = {
      url = "github:areofyl/fetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    potatofox = {
      url = "git+https://codeberg.org/awwpotato/PotatoFox";
      flake = false;
    };

    pi-flake = {
      url = "github:ChauDucToan/pi-flake";
    };

  };

  outputs = { self, nixpkgs, fetch, potatofox, home-manager, pi-flake, ... }@inputs: {

    nixosConfigurations.zach-nixos = nixpkgs.lib.nixosSystem {

      system = "x86_64-linux";

      modules = [
        ./configuration.nix
        home-manager.nixosModules.default
        {
          home-manager = {
            extraSpecialArgs = { inherit inputs; };
            useGlobalPkgs = true;
            useUserPackages = true;
            users.zach = import ./home.nix;
            backupFileExtension = "bak";
          };
        }
      ];

      specialArgs = { inherit inputs; };
    };
  };
}
