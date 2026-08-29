{
  description = "Known Rabbit's Nix packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
      overlays = import ./overlays;
      rabit-lib = import ./lib/rabit-lib.nix { inherit lib; };
      packageSet = import ./lib/package-set.nix;
    in
    {
      inherit overlays;

      inherit rabit-lib;

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
          inherit (pkgs) lib;
          callPackage = lib.callPackageWith (pkgs // { inherit rabit-lib; });
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      nixosModules = import ./modules/nixos;
    };
}
