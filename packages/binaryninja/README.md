# Binary Ninja

This package exposes one commercial Binary Ninja package as `pkgs.binaryninja`.
It is a user-supplied proprietary archive. The package intentionally has no
default version or archive: every user must provide the archive through an
explicit `requireFile` expression.

## Add the vendor archive

Download a Linux commercial archive from Binary Ninja. Stable archives use a
`-stable` suffix in the filename; development archives use a `-dev` suffix and
no `-stable` suffix.

From the repository root, import the archive and obtain its hash:

```console
scripts/nix-store-add.sh binaryninja_linux_commercial.5.3.9757-stable.7z
```

Then provide that archive to the package as `binaryNinjaArchive` using
`requireFile`:

```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (binaryninja.override {
      binaryNinjaArchive = requireFile rec {
        name = "binaryninja_linux_commercial.5.3.9757-stable.7z";
        hash = "sha256-REPLACE-WITH-THE-HASH-FROM-NIX-STORE-ADD";
        message = "add BN to nix store with: nix-store-add.sh ${name}";
      };
    })
  ];
}
```

The `name` must match the downloaded archive exactly. Binary Ninja's version
is inferred from this filename. Do not pass the downloaded file directly or
omit `requireFile`; doing so would make the proprietary source unsuitable for
this package collection.

## Python runtime

The package selects its Python runtime from the archive version automatically:
Binary Ninja versions before 6.0 use `pkgs.python312`, while version 6.0 and
newer use `pkgs.python313`.

## Stable and development channels

The package detects a `-dev` version suffix and changes its executable and
Desktop Entry names. Provide a separate `requireFile` source for each channel
to install stable and development channels side by side:

```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (binaryninja.override {
      binaryNinjaArchive = requireFile rec {
        name = "binaryninja_linux_commercial.5.3.9757-stable.7z";
        hash = "sha256-REPLACE-WITH-THE-HASH-FROM-NIX-STORE-ADD";
        message = "add BN to nix store with: nix-store-add.sh ${name}";
      };
    }) # binaryninja
    (binaryninja.override {
      binaryNinjaArchive = requireFile rec {
        name = "binaryninja_linux_commercial.6.1.10544-dev.7z";
        hash = "sha256-REPLACE-WITH-THE-HASH-FROM-NIX-STORE-ADD";
        message = "add BN to nix store with: nix-store-add.sh ${name}";
      };
    }) # binaryninja-dev
  ];
}
```

For the development archive, run the store helper from the repository root:

```console
scripts/nix-store-add.sh binaryninja_linux_commercial.6.1.10544-dev.7z
```

A stable package installs `binaryninja` and `bnpython3` with a `Binary Ninja`
Desktop Entry. A development package installs `binaryninja-dev` and
`bnpython3-dev` with a `Binary Ninja (Dev Channel)` Desktop Entry.

If the archive has already been imported into the Nix store, it must still be
wrapped in `requireFile` when passed as `binaryNinjaArchive`:

```nix
with pkgs;
binaryninja.override {
  binaryNinjaArchive = requireFile rec {
    name = "binaryninja_linux_commercial.6.1.10544-dev.7z";
    hash = "sha256-REPLACE-WITH-THE-HASH-FROM-NIX-STORE-ADD";
    message = ''
      Add the Binary Ninja archive to the Nix store with:
        scripts/nix-store-add.sh ${name}
    '';
  };
}
```

## Use with the flake

Apply `inputs.known-rabbit-packages.overlays.default` to the Nixpkgs instance
used by your system, then install a `pkgs.binaryninja.override` with a
user-supplied `requireFile` archive as shown above. The package cannot be built
without this explicit archive.
