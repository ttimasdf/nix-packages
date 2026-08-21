# Unlock Music CLI

`pkgs.unlock-music-cli` is the command-line tool for decoding supported encrypted music files. Its executable is `um`.

## Use

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
environment.systemPackages = [ pkgs.unlock-music-cli ];
```

Run `um --help` to see supported formats and output options. Use it only with media you are authorized to decode. Build directly with `nix build github:ttimasdf/nix-packages#unlock-music-cli`.
