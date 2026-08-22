{
  pkgs ? import <nixpkgs> { },
}:

let
  overlays = import ./overlays;
  packagePkgs = pkgs.extend overlays.default;
  packages = import ./lib/package-set.nix {
    inherit (packagePkgs) lib callPackage;
  };
in
packages
// {
  inherit overlays;
  nixosModules = import ./modules/nixos;
}
