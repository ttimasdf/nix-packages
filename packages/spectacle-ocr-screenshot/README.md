# Spectacle OCR Screenshot

`pkgs.spectacle-ocr-screenshot` watches screenshots taken with KDE Spectacle and performs OCR automatically. It installs the `spectacle-ocr-screenshot` command and a desktop entry.

## Use

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
environment.systemPackages = [ pkgs.spectacle-ocr-screenshot ];
```

Run the command in a graphical session and configure its OCR behavior through the application options. The package uses the repository's `makeDesktopItemExtended` helper for its desktop metadata and targets Linux. Build with `nix build github:ttimasdf/nix-packages#spectacle-ocr-screenshot`.
