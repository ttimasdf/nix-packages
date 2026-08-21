# EasyTier GUI

EasyTier GUI is a visual desktop client for the EasyTier network, exposed as `pkgs.easytier-gui`. The package-specific module adds the `CAP_NET_ADMIN` wrapper required for network management.

## Use

Recommended NixOS configuration:

```nix
{
  imports = [ inputs.known-rabbit-packages.nixosModules.easytier-gui ];
  nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
  programs.easytier-gui.enable = true;
}
```

The raw package can be installed with `environment.systemPackages = [ pkgs.easytier-gui ];`. The module does not configure peers or automatically start a tunnel. Build with `nix build github:ttimasdf/nix-packages#easytier-gui`.
