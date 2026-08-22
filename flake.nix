{
  description = "Known Rabbit's Nix packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
      overlays = import ./overlays;
      packageSet = import ./lib/package-set.nix;
    in
    {
      inherit overlays;

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlays.default ];
            config.allowUnfree = true;
          };
        in
        packageSet {
          inherit (pkgs) lib callPackage;
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      nixosModules = import ./modules/nixos;
    };
}
