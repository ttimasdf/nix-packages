# Repository guidance

This repository publishes personal Nix packages, portable Nixpkgs overlays, and package-specific NixOS modules through both flakes and NUR.

## Layout

- `packages/<name>/package.nix`: derivations discovered by `lib.packagesFromDirectoryRecursive`
- `build-support/`: package-set-dependent builders and setup hooks
- `overlays/packages.nix`: fixed-point overlay containing packages and build-support helpers
- `overlays/default.nix`: exported overlay index; `default` adds packages and build-support helpers
- `modules/nixos/`: package-specific NixOS modules
- `scripts/`: reusable Nix store and repository maintenance helpers
- `default.nix`: NUR entry point
- `flake.nix`: direct flake outputs

## Conventions

- Package definitions use ordinary `callPackage` arguments.
- Overlay files are portable `final: prev:` functions. Do not add repository-specific module arguments.
- Keep opinionated overrides opt-in; do not compose them into `overlays.default`.
- Add packages directly under `packages/` as a `.nix` file or directory with `package.nix`.
- Private-source packages do not belong in this public repository.
- NUR-visible package values must evaluate on Nixpkgs unstable.

## Validation

Run `nix fmt -- .`, force package output types with `nix eval`, and build affected packages when practical.
