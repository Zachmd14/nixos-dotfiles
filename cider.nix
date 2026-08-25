{
  description = "My NixOS configuration with Cider";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.my-system = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Your existing configuration file
        ./cider-module.nix  # or wherever you saved your module
        {
          modules.cider.enable = true;
          modules.cider.pkg = "cider-2";  # or "cider"
        }
      ];
    };
  };
}
