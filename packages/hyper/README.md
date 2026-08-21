# Hyper

`pkgs.hyper` repackages the Hyper terminal AppImage as a Nix application. It is a prebuilt x86_64 Linux binary with desktop integration.

## Use

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
environment.systemPackages = [ pkgs.hyper ];
```

Launch it with `hyper`. The package does not configure shells, fonts, or terminal profiles. Build directly with `nix build github:ttimasdf/nix-packages#hyper`.
