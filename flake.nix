{
  description = "Known Rabbit's Nix packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
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
