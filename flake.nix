{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = { nixpkgs, ... } @ inputs: {
    nixosConfigurations = {
      fridge = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/fridge/configuration.nix
          ./modules/common.nix
          ./modules/desktop-environment.nix
        ];
      };

      xps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/xps/configuration.nix
          ./modules/common.nix
          ./modules/desktop-environment.nix
        ];
      };
    };
  };
}
