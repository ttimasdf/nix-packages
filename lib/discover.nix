{ lib }:

dir:
lib.pipe (builtins.readDir dir) [
  (lib.filterAttrs (
    name: type:
    (type == "regular" && lib.hasSuffix ".nix" name)
    || (type == "directory" && builtins.pathExists (dir + "/${name}/default.nix"))
  ))
  (lib.mapAttrs' (
    name: type:
    lib.nameValuePair (if type == "regular" then lib.removeSuffix ".nix" name else name) (
      dir + "/${name}"
    )
  ))
]
