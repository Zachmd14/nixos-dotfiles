{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }: {
	nixosConfigurations.zach-nixos = nixpkgs.lib.nixosSystem {
	modules = [ ./configuration.nix ];
	};
    };
}
