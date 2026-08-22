# Overlay guidance

All overlays in this directory are ordinary portable Nixpkgs overlays:

```nix
final: prev: {
  example = prev.example.overrideAttrs (oldAttrs: { });
}
```

`default.nix` exports the overlay index. `package-set.nix` implements the canonical package overlay exposed as `default`; all existing-package overrides remain opt-in unless a consumer selects `all`.

Use `../lib/find-patches.nix` or `../../lib/find-patches.nix` for local patch directories. Avoid dependencies on a consuming flake or configuration repository.
