# Cockpit File Sharing

`pkgs.cockpit-file-sharing` is the 45Drives Cockpit plugin for managing Samba and NFS file shares. It is a Linux package and is intended to be installed alongside Cockpit and the relevant file-sharing services.

## Use

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
environment.systemPackages = [ pkgs.cockpit-file-sharing ];
```

Add it to the Cockpit package set used by your NixOS configuration if your Cockpit module exposes one. The package does not configure Samba/NFS or open firewall ports by itself. Build it directly with `nix build github:ttimasdf/nix-packages#cockpit-file-sharing`.
