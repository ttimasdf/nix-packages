# nix-packages

Personal Nix packages, opt-in Nixpkgs overlays, and package-specific NixOS modules.

## Flake usage

Add the repository as an input and make its packages available through the default overlay:

```nix
{
  inputs.known-rabbit-packages = {
    url = "github:ttimasdf/nix-packages";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, known-rabbit-packages, ... }: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs.overlays = [
            known-rabbit-packages.overlays.default
            # Opt in to overrides separately:
            # known-rabbit-packages.overlays.kscreen
          ];
        }
      ];
    };
  };
}
```

Packages can also be built directly:

```console
nix build github:ttimasdf/nix-packages#yakit
```

The `overlays.default` overlay adds packages and the `makeDesktopItemExtended` and `makeSanitizedLauncherHook` build-support helpers. `overlays.all` additionally composes every distinct repository overlay for trusted consumers. Existing-package overrides such as `kscreen`, `ghidra`, and `qt68` are also exported individually under `overlays`.

After applying the overlay, external package definitions can request either helper through `callPackage` just like native Nixpkgs build-support utilities:

```nix
{
  makeDesktopItemExtended,
  makeSanitizedLauncherHook,
  stdenv,
}:

stdenv.mkDerivation {
  nativeBuildInputs = [ makeSanitizedLauncherHook ];
  desktopItems = [ (makeDesktopItemExtended { /* ... */ }) ];
}
```

The helpers are intentionally not exposed through `packages.<system>` or `legacyPackages`; consume them through the overlay so they use the consumer's Nixpkgs instance.

Package-specific NixOS modules are available as `nixosModules.astral`, `nixosModules.easytier-gui`, and `nixosModules.fido-linux-id`. Import only the modules a host uses:

```nix
{
  imports = [
    inputs.known-rabbit-packages.nixosModules.astral
    inputs.known-rabbit-packages.nixosModules.fido-linux-id
  ];
}
```

`nixosModules.all` imports the complete published module set as an opt-in convenience:

```nix
imports = [ inputs.known-rabbit-packages.nixosModules.all ];
```

Explicit named imports are recommended for host configurations because adding a module to this repository will not silently expand their module set.

## Package documentation

Each package directory contains a README with its purpose, platform and input requirements, and usage examples:

| Package | Documentation |
| --- | --- |
| `astral` | [`packages/astral/README.md`](packages/astral/README.md) |
| `astral-ng` | [`packages/astral-ng/README.md`](packages/astral-ng/README.md) |
| `binaryninja` | [`packages/binaryninja/README.md`](packages/binaryninja/README.md) |
| `burpsuite` | [`packages/burpsuite/README.md`](packages/burpsuite/README.md) |
| `cockpit-file-sharing` | [`packages/cockpit-file-sharing/README.md`](packages/cockpit-file-sharing/README.md) |
| `dingtalk` | [`packages/dingtalk/README.md`](packages/dingtalk/README.md) |
| `easytier-gui` | [`packages/easytier-gui/README.md`](packages/easytier-gui/README.md) |
| `easytier-manager` | [`packages/easytier-manager/README.md`](packages/easytier-manager/README.md) |
| `fido-linux-id` | [`packages/fido-linux-id/README.md`](packages/fido-linux-id/README.md) |
| `hyper` | [`packages/hyper/README.md`](packages/hyper/README.md) |
| `ida-pro` | [`packages/ida-pro/README.md`](packages/ida-pro/README.md) |
| `jumpserver-client` | [`packages/jumpserver-client/README.md`](packages/jumpserver-client/README.md) |
| `jumpserver-client-3` | [`packages/jumpserver-client-3/README.md`](packages/jumpserver-client-3/README.md) |
| `pebble` | [`packages/pebble/README.md`](packages/pebble/README.md) |
| `qoder-cn` | [`packages/qoder-cn/README.md`](packages/qoder-cn/README.md) |
| `spd5118-module` | [`packages/spd5118-module/README.md`](packages/spd5118-module/README.md) |
| `spectacle-ocr-screenshot` | [`packages/spectacle-ocr-screenshot/README.md`](packages/spectacle-ocr-screenshot/README.md) |
| `unlock-music-cli` | [`packages/unlock-music-cli/README.md`](packages/unlock-music-cli/README.md) |
| `wormhole-cli` | [`packages/wormhole-cli/README.md`](packages/wormhole-cli/README.md) |
| `wuying-cloud-desktop` | [`packages/wuying-cloud-desktop/README.md`](packages/wuying-cloud-desktop/README.md) |
| `yakit` | [`packages/yakit/README.md`](packages/yakit/README.md) |
| `zap` | [`packages/zap/README.md`](packages/zap/README.md) |

The optional overlay catalog, including each overlay's purpose and attributes, is in [`overlays/README.md`](overlays/README.md). Build-support helper documentation is available for [`makeDesktopItemExtended`](build-support/make-desktop-item-extended/README.md) and [`makeSanitizedLauncherHook`](build-support/make-sanitized-launcher-hook/README.md).

## NUR

The root `default.nix` is a NUR-compatible repository expression. Once registered, packages can be consumed through `pkgs.nur.repos.ttimasdf`.

## Development

```console
nix flake show
nix build .#<package>
nix fmt -- .
```

Reusable Nix store helpers live under `scripts/`:

```console
./scripts/nix-store-add.sh archive.7z
./scripts/nix-store-delete.sh
```

The add helper records imported store paths in `nix-paths.txt`; the delete helper reads that file.
