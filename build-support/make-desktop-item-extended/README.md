# makeDesktopItemExtended

`makeDesktopItemExtended` is a package-set helper exposed by `overlays.default`. It extends Nixpkgs' desktop-item generator with localized names, localized comments/keywords, desktop actions, and additional vendor-specific desktop-entry fields.

It is not an installable package and is intentionally absent from `packages.<system>` and the NUR package set.

## Use

Apply the package overlay, then request the helper as a normal `callPackage` argument. For a package definition in another file, use `pkgs.callPackage ./package.nix { }` after applying `inputs.known-rabbit-packages.overlays.default`.

```nix
{ makeDesktopItemExtended, stdenv }:

stdenv.mkDerivation {
  # ...
  desktopItems = [
    (makeDesktopItemExtended {
      name = "spectacle";
      exec = "spectacle";
      icon = "spectacle";
      desktopName = "Spectacle";

      localizedNames = {
        "zh_CN" = "Spectacle 截图工具";
        "ja" = "スクリーンショット";
      };

      genericName = "Screenshot Capture Utility";
      localizedGenericNames = {
        "zh_CN" = "屏幕截图工具";
        "ja" = "スクリーンショット撮影ユーティリティ";
      };

      actions.FullScreenScreenShot = {
        name = "Capture Entire Desktop";
        localizedNames."zh_CN" = "截取整个桌面";
        exec = "spectacle -f";
        extraConfig."X-KDE-Shortcuts" = "Shift+Print";
      };

      extraConfig = {
        "X-KDE-Shortcuts" = "Print,Meta+Shift+S";
        "X-DBUS-ServiceName" = "org.kde.Spectacle";
      };
    })
  ];
}
```

## API

```text
makeDesktopItemExtended :: AttrSet -> Derivation
```

The helper accepts all of Nixpkgs' `makeDesktopItem` arguments and adds:

- `localizedNames` (attribute set): locale to localized `Name` value
- `localizedGenericNames` (attribute set): locale to localized `GenericName` value
- `localizedComments` (attribute set): locale to localized `Comment` value
- `localizedKeywords` (attribute set): locale to a list of localized `Keywords`
- `actions` (attribute set): desktop actions with the standard `name`, `icon`, and `exec` fields plus `localizedNames` and `extraConfig`

Locale mappings use names such as `"zh_CN"` or `"ja"`. Both top-level and action-level `extraConfig` values are emitted literally, which supports vendor-specific fields such as `X-KDE-Shortcuts`.

The result is a derivation containing the generated `.desktop` or `.directory` file. See the [Desktop Entry Specification 1.5](https://specifications.freedesktop.org/desktop-entry-spec/1.5/) for field definitions.
