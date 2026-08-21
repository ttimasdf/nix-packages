# nix-packages

Personal Nix packages, opt-in Nixpkgs overlays, and package-specific NixOS modules.

## Flake usage

Add the repository as an input and make its packages available through the default overlay:

```nix
{
  inputs.rabbit-packages = {
    url = "github:ttimasdf/nix-packages";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, rabbit-packages, ... }: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs.overlays = [
            rabbit-packages.overlays.default
            # Opt in to overrides separately:
            # rabbit-packages.overlays.kscreen
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

The default overlay adds packages and the `makeDesktopItemExtended` and `makeSanitizedLauncherHook` build-support helpers. Existing-package overrides such as `kscreen`, `ghidra`, and `qt68` are exported separately under `overlays`.

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

Package-specific NixOS modules are available as `nixosModules.astral`, `nixosModules.easytier-gui`, and `nixosModules.fido-linux-id`.

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
