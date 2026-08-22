# Optional overlays

The canonical package overlay is `overlays.default`. It provides this repository's packages, `makeDesktopItemExtended`, `makeSanitizedLauncherHook`, and the compatibility attributes needed by Wuying Cloud Desktop (`qt5w` and `libtiff-abi5`).

`overlays.all` is the trusted aggregate: it applies `default` and every distinct named overlay in this repository's composition order. Use it when you intentionally trust all repository overrides, as in the reference `nixos-config` consumer:

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.all ];
```

Other overlays remain individually available for consumers that want a narrower policy. Apply them alongside the default overlay in a NixOS configuration:

```nix
{
  nixpkgs.overlays = [
    inputs.known-rabbit-packages.overlays.default
    inputs.known-rabbit-packages.overlays.xxzip-natspec
  ];
}
```

For a standalone package evaluation:

```nix
let
  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    overlays = [ inputs.known-rabbit-packages.overlays.default ];
  };
in
pkgs.zip-nls
```

## Overlay catalog

| Overlay | Purpose and attributes |
| --- | --- |
| `ark` | Development scaffold for KDE Ark CLI/7z patches. Patch files are present, but the application remains disabled in `overlays/ark/default.nix` until explicitly enabled. See [`ark/README.md`](ark/README.md). |
| `clash-verge-rev` | Pins `pkgs.clash-verge-rev` to the repository's tested release. |
| `cockpit-zfs` | Applies the local branding-removal patches to `pkgs.cockpit-zfs`; the result is named `cockpit-zfs-patched`. |
| `fcitx5-rime-ice` | Makes `pkgs.fcitx5-rime-ice` use the `rime-data-ice` data and fixes the generated `default.yaml`. |
| `ghidra` | Adds GhidraIDA/IDA type information integration, PyGhidra, local patches, and the `ghidra-mod`/`ghidra-mod-with-extensions` packages. See [`ghidra/README.md`](ghidra/README.md). |
| `kscreen` | Applies local KDE KScreen patches through the `kdePackages` scope. |
| `libtiff5` | Exposes `pkgs.libtiff-abi5`, imported from a pinned Nixpkgs revision for binaries requiring the old ABI. Included by `overlays.default` and `overlays.all`. |
| `nvtop` | Adds `pkgs.nvtopPackages.nvidia-intel`, built with both Intel and NVIDIA support. |
| `qt5webengine` | Exposes `pkgs.qt5w`, a pinned Qt 5 package set containing the legacy Qt WebEngine required by Wuying. Included by `overlays.default` and `overlays.all`. |
| `qt68` | Exposes the pinned Qt 6.8 package set and Python 3.12 bindings as `qt68`, `qt68Packages`, `qt68python312`, `qt68pyside6`, and `qt68shiboken6`. |
| `wps` | Adds `pkgs.wpsoffice-cn-fcitx`, wrapping WPS executables with Fcitx input-method environment variables. |
| `xxzip-natspec` | Adds `zip-nls`, `unzip-nls`, and `_7zz-nls` with CP936/libnatspec decoding for legacy Chinese archive filenames. |

Use `overlays.default` for the package set, `overlays.all` when you trust every repository override, or one of the named overlays for a narrower policy.
