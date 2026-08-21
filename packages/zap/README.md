# Zap

`pkgs.zap` repackages the x86_64 Linux `.deb` release of Zap, a community fork of the Rust-based Warp terminal. It installs the `zap` executable and desktop integration.

## Use

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
environment.systemPackages = [ pkgs.zap ];
```

Terminal profiles and shell configuration remain user settings. Build directly with `nix build github:ttimasdf/nix-packages#zap`.
