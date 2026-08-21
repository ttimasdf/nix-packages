# JumpServer Client 3

`pkgs.jumpserver-client-3` uses a vendor-provided `.deb` that is not downloaded
by this repository. Each user must obtain the installer and add it to their own
Nix store.

For the currently packaged release:

```console
nix-store --add-fixed sha256 \
  /path/to/JumpServer-Client-Installer-linux-v3.0.4-amd64.deb
```

Keep the vendor filename unchanged. `requireFile` locates the store object by
that filename and the hash recorded in the package. If the installer differs,
calculate its hash first and update/override the package version, filename, and
hash together in your own package collection.

The newer `pkgs.jumpserver-client` package is fetched publicly and does not
need this manual input.
