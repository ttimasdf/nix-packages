# Astral

Astral is a Linux desktop client for Astral, packaged as `pkgs.astral`. This is the upstream `ldoubil/astral` build and is currently supported on `x86_64-linux`.

## Use

Apply the package overlay and install it like any other NixOS package:

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
environment.systemPackages = [ pkgs.astral ];
```

The package installs the `astral` executable and desktop integration. Build it directly with:

```console
nix build github:ttimasdf/nix-packages#astral
```

For the newer `ttimasdf/astral-ng` client, use [`../astral-ng`](../astral-ng) and the `programs.astral` module instead.
