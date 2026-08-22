{ system }:

let
  # Wuying depends on the Qt 5 WebEngine and libtiff ABI from older Nixpkgs
  # revisions.
  pkgs-qt5webengine =
    import
      (fetchTarball {
        name = "nixpkgs-qt5webengine";
        # The parent commit of https://github.com/NixOS/nixpkgs/commit/c3e30f8ab21a70116a7f189b6b3fa9d7017b717d
        url = "https://github.com/NixOS/nixpkgs/archive/7124eb5c3e1fe1512fcdbe3d87a71724807d2660.tar.gz";
        sha256 = "sha256-ezhvkFwNkulYvpHnGtvk61tcRZOZbFL9sIp05MhFK98=";
      })
      {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [
          "qtwebengine-5.15.19"
        ];
      };

  pkgs-libtiff-abi5 =
    import
      (fetchTarball {
        name = "nixpkgs-libtiff-abi5";
        # The latest commit with libtiff 4.4.0 in Nixpkgs, before the ABI bump.
        url = "https://github.com/NixOS/nixpkgs/archive/ccef3ab7d8762c6e5c75688dfd2d0850d9469a33.tar.gz";
        sha256 = "sha256-AW5UfsmQ+UCFwgyVbbjQRqmGBzU3F+UzjAKz5du8liw=";
      })
      {
        inherit system;
        config.allowUnfree = true;
      };
in
{
  qt5w = pkgs-qt5webengine.qt5;
  libtiff-abi5 = pkgs-libtiff-abi5.libtiff;
}
