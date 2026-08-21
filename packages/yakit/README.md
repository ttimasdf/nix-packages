# Yakit

Yakit is a cross-platform reverse-engineering framework packaged from the upstream AppImage as `pkgs.yakit`. The current package provides x86_64 and aarch64 Linux sources.

## Use

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
environment.systemPackages = [ pkgs.yakit ];
```

Launch it with `yakit`. The package does not configure project data or external scanning services. Build directly with `nix build github:ttimasdf/nix-packages#yakit`.
