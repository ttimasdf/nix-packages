# Pebble

Pebble is a local-first desktop email client for a calmer, private inbox, packaged as `pkgs.pebble`.

## Use

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
environment.systemPackages = [ pkgs.pebble ];
```

The package installs the `pebble` executable and desktop integration. Account data and mail-service configuration are managed by Pebble; this package does not provide an email server. Build directly with `nix build github:ttimasdf/nix-packages#pebble`.
