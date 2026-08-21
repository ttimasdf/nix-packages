{ lib }:

patchesDir:
lib.pipe (builtins.readDir patchesDir) [
  lib.attrNames
  (lib.filter (lib.hasSuffix ".patch"))
  (map (name: patchesDir + "/${name}"))
]
