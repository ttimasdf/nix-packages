# rustdesk-flutter-unattended-wayland

RustDesk client built from a `master` pin with the `drm`/`drm-wake` capture
backend — the same variant upstream ships as the rolling `nightly`
`rustdesk-unattended-wayland` deb (CI job `build-rustdesk-linux-drm` in
`flutter-build.yml`).

The DRM features do not exist in any release tag, so this cannot be an
override of `pkgs.rustdesk-flutter` (which builds the stock release client):
`pubspecLock`/`gitHashes` are eval-time inputs to the Flutter deps machinery
and cannot be replaced via `overrideAttrs` or `.override`. The package file is
therefore vendored from nixpkgs' `rustdesk-flutter` expression and diverges by:
source pin, cargo features, lockfiles, and the bundled `libdrmtap`.

## Bumping the master pin

Keep in sync in `package.nix` / `libdrmtap.nix`:
- `src.rev` (master commit) and its hash
- `pubspec.lock.json` — `curl -sL .../<rev>/flutter/pubspec.lock | yq > pubspec.lock.json`
- `git-hashes.json` — `nix-prefetch-git` each `resolved-ref`, `nix hash convert --to sri`
- `cargoDeps` hash (fakeHash → build → replace)
- `libdrmtap.nix` `rev` — must equal rustdesk `build.py` `LIBDRMTAP_SHA_PINNED`
  (the runtime loader ABI-gates it: major 0, minor 5 exact)

When nixpkgs' `rustdesk-flutter` expression changes meaningfully (new builder
args, hook changes), re-vendor `package.nix` from it and re-apply this file's
divergences (search for "drm" comments).
