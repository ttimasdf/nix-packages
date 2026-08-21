let
  packages = import ./packages.nix;
in
{
  default = packages;
  inherit packages;

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
}
