final: prev:

prev.lib.composeManyExtensions [
  (import ./libtiff5.nix)
  (import ./qt5webengine.nix)
  (helperFinal: _helperPrev: {
    makeDesktopItemExtended =
      helperFinal.callPackage ../build-support/make-desktop-item-extended/package.nix
        { };
    makeSanitizedLauncherHook =
      helperFinal.callPackage ../build-support/make-sanitized-launcher-hook/package.nix
        { };
  })
  (
    packageFinal: packagePrev:
    import ../lib/package-set.nix {
      inherit (packagePrev) lib;
      inherit (packageFinal) callPackage;
    }
  )
] final prev
