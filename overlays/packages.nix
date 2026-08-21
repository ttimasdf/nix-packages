final: prev:

prev.lib.composeManyExtensions [
  (import ./libtiff5.nix)
  (import ./qt5webengine.nix)
  (
    packageFinal: packagePrev:
    (import ../lib/package-set.nix { inherit (packagePrev) lib; }) packageFinal
  )
] final prev
