# Package guidance

Every `.nix` file or directory with `default.nix` directly under this directory is discovered as a package-set attribute.

- Use normal `callPackage` arguments and include complete `meta` attributes.
- Use a directory when a package needs patches, scripts, icons, or update helpers.
- Package helpers may return functions for use through `pkgs`, but only derivations are exported from flake and NUR package outputs.
- Nested derivation sets such as Binary Ninja are flattened for flake and NUR outputs while retaining their nested form in the package overlay.
- Do not add packages whose sources require private credentials.
