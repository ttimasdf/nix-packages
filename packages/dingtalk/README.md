# DingTalk

`pkgs.dingtalk` repackages the official x86_64 Linux DingTalk `.deb` as an unfree binary desktop application. It includes the vendor runtime libraries and desktop integration.

## Use

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
environment.systemPackages = [ pkgs.dingtalk ];
```

The package is supported on `x86_64-linux` only. It does not configure DingTalk accounts, proxies, or desktop portals. Build it directly with `nix build github:ttimasdf/nix-packages#dingtalk`.
