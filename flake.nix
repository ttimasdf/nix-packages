{
  description = "Cortex Red's Nix packages and overlays";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = lib.genAttrs systems;
      overlays = import ./overlays;
      packageSet = import ./lib/package-set.nix { inherit lib; };
      flattenPackages = import ./lib/flatten-packages.nix { inherit lib; };
    in
    {
      inherit overlays;

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlays.packages ];
            config.allowUnfree = true;
          };
        in
        flattenPackages (packageSet pkgs)
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      nixosModules = import ./modules/nixos;
    };
}
