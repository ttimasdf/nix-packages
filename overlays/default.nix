let
  packageOverlay = import ./package-set.nix;

  namedOverlays = {
    ark = import ./ark;
    clash-verge-rev = import ./clash-verge-rev.nix;
    cockpit-zfs = import ./cockpit-zfs;
    fcitx5-rime-ice = import ./fcitx5-rime-ice;
    ghidra = import ./ghidra;
    kscreen = import ./kscreen;
    libtiff5 = import ./libtiff5.nix;
    nvtop = import ./nvtop.nix;
    qt5webengine = import ./qt5webengine.nix;
    qt68 = import ./qt68.nix;
    wps = import ./wps.nix;
    xxzip-natspec = import ./xxzip-natspec.nix;
  };

  # Keep the package overlay's existing compatibility dependencies from being
  # applied a second time when constructing the trusted aggregate overlay.
  aggregateOverlays = [
    packageOverlay
  ]
  ++ builtins.attrValues (
    builtins.removeAttrs namedOverlays [
      "libtiff5"
      "qt5webengine"
    ]
  );

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
