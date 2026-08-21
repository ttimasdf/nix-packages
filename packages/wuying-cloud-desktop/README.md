# Wuying Cloud Desktop

This package repackages the proprietary Wuying Cloud Desktop `.deb` as
`pkgs.wuying-cloud-desktop`. The vendor installer is not fetched automatically;
you must provide it locally.

Download the Linux installer from Alibaba Cloud/Wuying, rename it to the exact
filename expected by the package, and add it to the Nix store:

```console
nix-prefetch-url file:///path/to/wuying-cloud-desktop-7.11.0-wuying.deb
```

The command prints the source hash and adds the file to the store. Nix will find
it by filename and hash when building `pkgs.wuying-cloud-desktop`.

For another vendor release, override the package arguments and provide your own
source path:

```nix
pkgs.wuying-cloud-desktop.override {
  version = "NEW-VERSION";
  hash = "sha256-...";
  wuyingSource = /path/to/wuying-cloud-desktop-NEW-VERSION.deb;
}
```

When `wuyingSource` is supplied directly, `hash` documents the corresponding
artifact but `requireFile` is bypassed. Paths referenced from a flake must be
tracked by that flake or already exist in the Nix store.

The package overlay composes the Qt 5 WebEngine and libtiff ABI 5 compatibility
packages required by this application.
