# RustDesk unattended-wayland overlay

Provides `pkgs.rustdesk-flutter-unattended-wayland`: the RustDesk Flutter client
built with the `drm`/`drm-wake` capture features and a bundled `libdrmtap`,
which is what makes unattended access work on a headless Wayland/KMS session.

It is a thin override of nixpkgs' `rustdesk-flutter` rather than a vendored
derivation: upstream has shipped this backend as a separate opt-in variant
since the `1.5.0` tag (`rustdesk-unattended-wayland-<version>-x86_64.deb`,
built by `build.py --drm`). The override only

- repoints `version`/`src` at the release tag,
- feeds 1.5.0's `pubspec.lock.json` / `git-hashes.json` (copied from nixpkgs'
  `pkgs/by-name/ru/rustdesk-flutter`) through `pubspecLockFile` /
  `packageConfig`,
- enables `drm`, `drm-wake`, and `unix-file-copy-paste`,
- bundles `libdrmtap` and points `drmtap_dl.rs` at it.

The one subtlety: `buildDartApplication` consumes `pubspecLock`/`gitHashes`
before the final derivation exists (they are in `excludeDrvArgNames`), so
`overrideAttrs` cannot replace them directly. The overlay evaluates the same
builder once with the 1.5.0 lock to derive `pubspecLockFile` and
`packageConfig`, then overrides those on the real derivation.

nixpkgs' stock `rustdesk-flutter` is not a substitute: it compiles the backend
out and does not bundle `libdrmtap`, so remote capture of a Wayland session
falls back or fails.

The `services.rustdesk-unattended-wayland` NixOS module in
`modules/nixos/rustdesk-unattended-wayland.nix` consumes the package and runs
the root `rustdesk --service` side.

## Bumping

Keep in sync:

- `default.nix`: `version`, `src.hash`
- `default.nix`: `pubspec.lock.json` / `git-hashes.json` from nixpkgs at the
  matching `rustdesk-flutter` version (or regenerate as that file documents)
- `default.nix`: `cargoDeps` hash (`fakeHash`, build, replace with reported
  hash)
- `libdrmtap.nix`: `rev` must equal `LIBDRMTAP_SHA_PINNED` in rustdesk's
  `build.py` (the loader ABI-gates major 0, minor 5 exact)

When nixpkgs' `rustdesk-flutter` reaches the same release, `version`, `src`,
the lockfiles, and `cargoDeps` can be dropped, leaving only the feature list
and the `libdrmtap` patch.
