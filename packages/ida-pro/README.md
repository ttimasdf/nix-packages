# IDA Pro

`pkgs.ida-pro` is a repackaging of the proprietary IDA Pro Linux installer.
The installer is not publicly fetchable by Nix, so each user must obtain it
from Hex-Rays and add it to their own Nix store.

For the current package version, download the x86_64 Linux installer and add it
with:

```console
nix-prefetch-url file:///path/to/ida-pro_92_x64linux.run
```

The filename must match the version expected by the package. The package error
message prints the exact filename when the required file is missing. After the
prefetch command completes, build `pkgs.ida-pro` normally.

If you maintain a local package override for another licensed installer
version, update the package's `version` and `requireFile` hash/name together.
Do not publish the vendor installer or its license data in this repository.

## Use with the flake

Apply `inputs.known-rabbit-packages.overlays.default` to the Nixpkgs instance used by your NixOS configuration, then install `pkgs.ida-pro`:

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
environment.systemPackages = [ pkgs.ida-pro ];
```

Build directly with `nix build github:ttimasdf/nix-packages#ida-pro` after the installer has been imported.
