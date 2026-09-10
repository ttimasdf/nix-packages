{
  lib,
  stdenv,
  meson,
  ninja,
  pkg-config,
  fetchFromGitHub,
  autoPatchelfHook,
  libdrm,
  libva,
  libglvnd,
}:

# The DRM/KMS scanout capture engine that RustDesk dlopen()s at runtime (never
# linked). Pinned to the exact commit rustdesk's build.py pins via
# LIBDRMTAP_SHA_PINNED, because libs/scrap/src/common/drmtap_dl.rs gates the ABI
# (major 0, minor 5 exact) at load time: bump this only together with the
# rustdesk master pin in ./default.nix.
stdenv.mkDerivation (finalAttrs: {
  pname = "libdrmtap";
  version = "0.5.4";

  src = fetchFromGitHub {
    owner = "rustdesk-org";
    repo = "libdrmtap";
    # LIBDRMTAP_SHA_PINNED in rustdesk build.py (v0.5.4)
    rev = "5da68a3a368db569716d0d0f11cefacbb11b2290";
    hash = "sha256-d7I0DIoUl1XefJgcwwBDI3aSFt0tfdU4SvVBEAHYCYM=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    autoPatchelfHook
  ];

  buildInputs = [
    libdrm
    libva
    # EGL/GLESv2 headers only: the detiling backend dlopen()s them lazily.
    libglvnd
  ];

  # Library only, like the deb: the seccomp/cap-confined privileged helper is a
  # separate deployment unit upstream does not bundle either.
  mesonFlags = [ "-Dhelper=disabled" ];

  meta = {
    description = "DRM/KMS scanout capture library for RustDesk unattended access";
    homepage = "https://github.com/rustdesk-org/libdrmtap";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
