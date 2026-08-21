# Qoder CN

`pkgs.qoder-cn` repackages the x86_64 Linux Qoder CN `.deb`, an agentic coding platform for software development. It is an unfree prebuilt binary.

## Use

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
environment.systemPackages = [ pkgs.qoder-cn ];
```

Launch it with `qoder-cn`. The package does not supply Qoder credentials, model endpoints, or project configuration. Build directly with `nix build github:ttimasdf/nix-packages#qoder-cn`.
