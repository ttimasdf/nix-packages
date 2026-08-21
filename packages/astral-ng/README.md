# Astral NG

Astral NG is the `ttimasdf/astral-ng` Linux desktop client, exposed as `pkgs.astral-ng`. It currently supports `x86_64-linux` and requires the `CAP_NET_ADMIN` capability to manage network interfaces.

## Use

The package-specific NixOS module configures the capability wrapper and installs the client:

```nix
{
  imports = [ inputs.known-rabbit-packages.nixosModules.astral ];
  nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
  programs.astral.enable = true;
}
```

To select a different package through the module, set `programs.astral.package`. The raw package is also available as `pkgs.astral-ng`:

```nix
environment.systemPackages = [ pkgs.astral-ng ];
```

Build it directly with `nix build github:ttimasdf/nix-packages#astral-ng`.
