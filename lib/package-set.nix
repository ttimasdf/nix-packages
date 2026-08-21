{ lib }:

final:
let
  packagePaths = import ./discover.nix { inherit lib; } ../packages;
in
lib.mapAttrs (_name: path: final.callPackage path { }) packagePaths
