# Package guidance

Every `.nix` file and directory with `package.nix` under this directory is discovered by `lib.packagesFromDirectoryRecursive`.

- Package leaves must evaluate to derivations suitable for flake and NUR package outputs.
- Use normal `callPackage` arguments and include complete `meta` attributes.
- Use a directory with `package.nix` when a package needs patches, scripts, icons, or update helpers.
- Package-set-dependent functions and setup hooks belong under `build-support/`, not here.
- Sibling packages and build-support helpers are resolved through the package overlay's fixed point.
- Do not add packages whose sources require private credentials.
