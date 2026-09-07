# Enmesh

Enmesh (formerly Astral NG) is the `ttimasdf/enmesh` Linux desktop client for EasyTier, exposed as `pkgs.enmesh`. It currently supports `x86_64-linux` and requires the `CAP_NET_ADMIN` capability to manage network interfaces.

The package is pinned to `v3.0.0-rc.3`, the first tagged release carrying the astral-ng → enmesh rebrand (binary `enmesh`, Rust crate `rust_lib_enmesh`, deep-link scheme `enmesh://`). Upgrading replaces the old `astral-ng` package; existing installs under the `pw.rabit.astralng` application ID must be re-paired, and `astral://` room links no longer open.

## Use

The package-specific NixOS module configures the capability wrapper and installs the client:

```nix
{
  imports = [ inputs.known-rabbit-packages.nixosModules.enmesh ];
  nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
  programs.enmesh.enable = true;
}
```

To select a different package through the module, set `programs.enmesh.package`. The raw package is also available as `pkgs.enmesh`:

```nix
environment.systemPackages = [ pkgs.enmesh ];
```

Build it directly with `nix build github:ttimasdf/nix-packages#enmesh`.
