final: prev:

prev.lib.composeManyExtensions [
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
    let
      rabit-lib = import ../lib/rabit-lib.nix { inherit (packagePrev) lib; };
    in
    import ../lib/package-set.nix {
      inherit (packagePrev) lib;
      callPackage = packagePrev.lib.callPackageWith (packageFinal // { inherit rabit-lib; });
    }
  )
] final prev
