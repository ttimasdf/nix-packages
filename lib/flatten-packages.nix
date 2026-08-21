{ lib }:

attrs:
lib.foldl' lib.recursiveUpdate { } (
  lib.mapAttrsToList (
    name: value:
    if lib.isDerivation value then
      { ${name} = value; }
    else if lib.isAttrs value then
      (import ./flatten-packages.nix { inherit lib; }) value
    else
      { }
  ) attrs
)
