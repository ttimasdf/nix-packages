# makeDesktopItemExtended

`makeDesktopItemExtended` is a package-set helper exposed by `overlays.default`. It extends Nixpkgs' desktop-item generator with localized names, localized comments/keywords, desktop actions, and additional vendor-specific desktop-entry fields.

It is not an installable package and is intentionally absent from `packages.<system>` and the NUR package set.

## Use

Apply the package overlay, then request the helper as a normal `callPackage` argument:

```nix
{ makeDesktopItemExtended, stdenv }:

stdenv.mkDerivation {
  # ...
  desktopItems = [
    (makeDesktopItemExtended {
      name = "example";
      desktopName = "Example";
      exec = "example";
      localizedNames = { "zh_CN" = "示例"; };
      extraConfig = { "X-Example-Mode" = "desktop"; };
    })
  ];
}
```

For a package definition in another file, use `pkgs.callPackage ./package.nix { }` after applying `inputs.known-rabbit-packages.overlays.default`.
