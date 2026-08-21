# EasyTier Manager Pro

`pkgs.easytier-manager` is the EasyTier Manager Pro desktop application. It provides a graphical interface for starting and stopping EasyTier, changing kernel parameters, viewing logs, and downloading EasyTier versions.

## Use

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
environment.systemPackages = [ pkgs.easytier-manager ];
```

This package is separate from `easytier-gui`: it does not use the `programs.easytier-gui` module or install the `CAP_NET_ADMIN` wrapper. The package supports Linux platforms. Build directly with `nix build github:ttimasdf/nix-packages#easytier-manager`.
