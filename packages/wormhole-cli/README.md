# Wormhole CLI

`pkgs.wormhole-cli` is a command-line client for wormhole.app to upload, download, and inspect files. It installs the `wormhole-cli` executable.

## Use

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
environment.systemPackages = [ pkgs.wormhole-cli ];
```

Run `wormhole-cli --help` for command syntax and service options. Build directly with `nix build github:ttimasdf/nix-packages#wormhole-cli`.
