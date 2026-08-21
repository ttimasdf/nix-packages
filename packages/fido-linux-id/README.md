# fido-linux-id

`pkgs.fido-linux-id` provides a WebAuthn/U2F token backed by a TPM. It installs the `linux-id` daemon and is intended to expose a local hardware-backed identity to compatible authentication clients.

## Use

The NixOS module installs the daemon, pinentry, udev rule, and user service:

```nix
{
  imports = [ inputs.known-rabbit-packages.nixosModules.fido-linux-id ];
  nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
  programs.fido-linux-id.enable = true;
}
```

Use `programs.fido-linux-id.package` or `pinentryPackage` to override either dependency. The service is started with the graphical session and requires access to the `uhid` group. Build the raw package with `nix build github:ttimasdf/nix-packages#fido-linux-id`.
