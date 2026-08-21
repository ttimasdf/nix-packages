_final: prev:
let
  findPatches = import ../../lib/find-patches.nix { inherit (prev) lib; };
in
{
  kdePackages = prev.kdePackages.overrideScope (
    _kdeFinal: kdePrev: {
      kscreen = kdePrev.kscreen.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ (findPatches ./patches);
      });
    }
  );
}
