{
  pkgs ? import <nixpkgs> { },
}:

let
  overlays = import ./overlays;
  packagePkgs = pkgs.extend overlays.packages;
  packageSet = (import ./lib/package-set.nix { inherit (pkgs) lib; }) packagePkgs;
  packages = (import ./lib/flatten-packages.nix { inherit (pkgs) lib; }) packageSet;
in
packages
// {
  inherit overlays;
  lib = {
    inherit (packageSet) makeDesktopItemExtended;
  };
  nixosModules = import ./modules/nixos;
}
