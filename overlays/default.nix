let
  packageOverlay = import ./package-set.nix;

  namedOverlays = {
    ark = import ./ark;
    clash-verge-rev = import ./clash-verge-rev.nix;
    cockpit-zfs = import ./cockpit-zfs;
    fcitx5-rime-ice = import ./fcitx5-rime-ice;
    ghidra = import ./ghidra;
    kscreen = import ./kscreen;
    nvtop = import ./nvtop.nix;
    qt68 = import ./qt68.nix;
    wps = import ./wps.nix;
    xxzip-natspec = import ./xxzip-natspec.nix;
  };

  aggregateOverlays = [ packageOverlay ] ++ builtins.attrValues namedOverlays;

  composeExtensions =
    first: second: final: prev:
    let
      firstResult = first final prev;
      secondResult = second final (prev // firstResult);
    in
    firstResult // secondResult;

  composeManyExtensions = builtins.foldl' composeExtensions (_final: _prev: { });

  allOverlays = composeManyExtensions aggregateOverlays;
in
{
  default = packageOverlay;
  all = allOverlays;
}
// namedOverlays
