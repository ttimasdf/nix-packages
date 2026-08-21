# JumpServer Client

`pkgs.jumpserver-client` repackages the publicly downloadable JumpServer Client 4.x `.deb` for x86_64 Linux. It launches remote sessions from a JumpServer installation.

## Use

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
environment.systemPackages = [ pkgs.jumpserver-client ];
```

Configure the JumpServer endpoint and authentication in the application itself. The package does not configure a server or session profiles. For the older proprietary Client 3 release, use [`../jumpserver-client-3`](../jumpserver-client-3). Build with `nix build github:ttimasdf/nix-packages#jumpserver-client`.
