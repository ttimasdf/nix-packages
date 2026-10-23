# RustDesk with the DRM/KMS "unattended wayland" capture backend.
#
# Upstream ships this as a separate opt-in variant
# (`rustdesk-unattended-wayland`) rather than in the stock client: the
# `drm`/`drm-wake` features capture the scanout directly and let the root
# service inject input, bypassing the normal consent prompt. nixpkgs'
# `rustdesk-flutter` is the stock build, so it neither enables those cargo
# features nor bundles the dlopen()ed `libdrmtap`.
#
# Up to 1.5.0 the backend only existed on `master`, which meant vendoring the
# whole Flutter/Rust derivation. Since the 1.5.0 tag it is a normal release
# feature, so this overlay repoints the nixpkgs derivation at the release and
# switches the backend on.
#
# Bumping:
#   - version + src hash here
#   - pubspec.lock.json / git-hashes.json: copy from nixpkgs
#     pkgs/by-name/ru/rustdesk-flutter (they are regenerated there per the
#     comments in that package.nix)
#   - cargoDeps hash (fakeHash -> build -> replace)
#   - libdrmtap.nix pin must equal build.py LIBDRMTAP_SHA_PINNED
_final: prev:
let
  lib = prev.lib;
  libdrmtap = prev.callPackage ./libdrmtap.nix { };

  version = "1.5.0";
  src = prev.fetchFromGitHub {
    owner = "rustdesk";
    repo = "rustdesk";
    tag = version;
    fetchSubmodules = true;
    hash = "sha256-1xa7X+swBIb8Lz3c6m8SeNZAiJWNCUpw+UbdSsMkeSk=";
  };
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  gitHashes = lib.importJSON ./git-hashes.json;

  # buildDartApplication turns pubspecLock/gitHashes into `pubspecLockFile`
  # and `packageConfig` before the final derivation is constructed (they are
  # in its excludeDrvArgNames), so overrideAttrs cannot replace them. Evaluate
  # the same builder once with the 1.5.0 lock to obtain those two derived
  # attributes. Nothing here is built except `packageConfig`, which the real
  # build needs anyway.
  lockAttrs = prev.flutter329.buildFlutterApplication {
    pname = "rustdesk-flutter-unattended-wayland";
    inherit
      version
      src
      pubspecLock
      gitHashes
      ;
    sourceRoot = "${src.name}/flutter";
  };
in
{
  rustdesk-flutter-unattended-wayland = prev.rustdesk-flutter.overrideAttrs (old: rec {
    pname = "rustdesk-flutter-unattended-wayland";
    inherit version src;

    pubspecLockFile = lockAttrs.pubspecLockFile;
    packageConfig = lockAttrs.packageConfig;

    cargoDeps = prev.rustPlatform.fetchCargoVendor {
      inherit pname version src;
      inherit (old) patches;
      hash = "sha256-Ym4USlB1NJO0bm0cr2l/yZhoUBfxtd2uTkkjrR7iD3o=";
    };

    # What `build.py --flutter --drm --hwcodec --unix-file-copy-paste`
    # compiles for the deb variant, plus nixpkgs' linux-pkg-config.
    cargoBuildFeatures = old.cargoBuildFeatures ++ [
      "drm"
      "drm-wake"
      "unix-file-copy-paste"
    ];

    # drmtap_dl.rs only tries the deb's private absolute path when running as
    # root, and the packaged service does run as root, so that candidate has
    # to point into the store.
    postPatch = (old.postPatch or "") + ''
      substituteInPlace ../libs/scrap/src/common/drmtap_dl.rs \
        --replace-fail "/usr/lib/rustdesk/libdrmtap.so.0" "${libdrmtap}/lib/libdrmtap.so.0"
    '';

    passthru = (old.passthru or { }) // {
      inherit libdrmtap;
    };

    meta = old.meta // {
      description = "RustDesk client with the DRM/KMS unattended-wayland capture backend";
    };
  });
}
