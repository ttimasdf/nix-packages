# Ghidra overlay

This overlay provides a modified Ghidra build with GhidraIDA integration, IDA type information, a HiDPI adjustment, PyGhidra, and extension composition helpers. It exports `ghidra-mod`, `ghidra-mod-with-extensions`, and the custom extension attributes.

Enable it explicitly alongside the package overlay:

```nix
nixpkgs.overlays = [
  inputs.known-rabbit-packages.overlays.default
  inputs.known-rabbit-packages.overlays.ghidra
];
```

To develop one of the packaged extensions:

e.g.

```bash
nix develop .#nixosConfigurations.viscacha.pkgs.ghidra-custom-extensions.ghydra-mcp
```
