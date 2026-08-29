{
  pkgs ? import <nixpkgs> { },
}:

let
  overlays = import ./overlays;
  packagePkgs = pkgs.extend overlays.default;
  packages = import ./lib/package-set.nix {
    inherit (packagePkgs) lib;
    callPackage = packagePkgs.lib.callPackageWith (
      packagePkgs
      // {
        rabit-lib = import ./lib/rabit-lib.nix { inherit (packagePkgs) lib; };
      }
    );
  };
in
packages
// {
  inherit overlays;
  nixosModules = import ./modules/nixos;
}
