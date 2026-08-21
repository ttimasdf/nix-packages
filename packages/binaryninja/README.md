# Binary Ninja

This package exposes one commercial Binary Ninja package as `pkgs.binaryninja`.
It is a user-supplied proprietary archive, so the archive must be added to the
Nix store before evaluation/build.

## Add the vendor archive

Download a Linux commercial archive from Binary Ninja. Stable archives use a
`-stable` suffix in the filename; development archives use a `-dev` suffix and
no `-stable` suffix.

For the current stable package:

```console
nix-prefetch-url file:///path/to/binaryninja_linux_commercial.5.3.9757-stable.7z
```

The resulting store path is accepted by `requireFile` when the filename and
hash match the package arguments.

## Stable and development channels

The default package is the stable channel:

```nix
environment.systemPackages = [ pkgs.binaryninja ];
```

The package detects a `-dev` version suffix and changes its executable and
Desktop Entry names. This permits stable and development channels to coexist:

```nix
{ pkgs, ... }:
let
  binaryninja-dev = pkgs.binaryninja.override {
    version = "5.3.8664-dev";
    hash = "sha256-UEG3bcNmFjqIzfds5/Wrspn+CCnbI5vy0DSJXT6UQUQ=";
  };
in
{
  environment.systemPackages = [
    pkgs.binaryninja       # binaryninja
    binaryninja-dev        # binaryninja-dev
  ];
}
```

For the development override, add the corresponding archive to the store:

```console
nix-prefetch-url file:///path/to/binaryninja_linux_commercial.5.3.8664-dev.7z
```

A stable package installs `binaryninja` and `bnpython3` with a `Binary Ninja`
Desktop Entry. A development package installs `binaryninja-dev` and
`bnpython3-dev` with a `Binary Ninja (Dev Channel)` Desktop Entry.

`binaryNinjaSource` can also be supplied in an override when the archive is
already represented by a Nix path or another fetcher:

```nix
pkgs.binaryninja.override {
  version = "5.3.8664-dev";
  hash = "sha256-UEG3bcNmFjqIzfds5/Wrspn+CCnbI5vy0DSJXT6UQUQ=";
  binaryNinjaSource = /path/to/binaryninja_linux_commercial.5.3.8664-dev.7z;
}
```

The hash shown above is an example for the latest development archive known to
this package at the time of writing; verify the hash for the exact archive you
download.
