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
# rustdesk version pin in ./default.nix.
stdenv.mkDerivation (finalAttrs: {
  pname = "libdrmtap";
  version = "0.5.8";

  src = fetchFromGitHub {
    owner = "rustdesk-org";
    repo = "libdrmtap";
    # LIBDRMTAP_SHA_PINNED in rustdesk 1.5.0 build.py (v0.5.8)
    rev = "95d4d74549631aa5c39461300acfd2e106583cc9";
    hash = "sha256-MOFUMlO8R84eI/oj9jjJZq0tuAaP9IZUeBd8gB8XQ+s=";
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
