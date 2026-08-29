_final: prev:
let
  findPatches = (import ../../lib/rabit-lib.nix { inherit (prev) lib; }).findPatches;
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
