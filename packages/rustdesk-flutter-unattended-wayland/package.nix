# Vendored from nixpkgs pkgs/by-name/ru/rustdesk-flutter (1.4.9 era), modified
# to build the master-only unattended-wayland variant:
#
#   - source pinned to a master commit (drm/drm-wake features exist only there;
#     upstream ships this variant as the rolling "nightly" deb, CI job
#     build-rustdesk-linux-drm in .github/workflows/flutter-build.yml)
#   - cargo features match: flutter,drm,drm-wake,hwcodec,unix-file-copy-paste
#     (plus nixpkgs' linux-pkg-config)
#   - libdrmtap (the dlopen()ed DRM/KMS capture engine) is bundled from the
#     exact pin in rustdesk build.py, and drmtap_dl.rs is patched to dlopen it
#     from the Nix store instead of /usr/lib/rustdesk.
#
# Keep in sync when bumping the master pin: src.rev, pubspec.lock.json,
# git-hashes.json, cargoDeps hash, and libdrmtap.nix.
{
  lib,
  clangStdenv,
  cargo,
  copyDesktopItems,
  fetchFromGitHub,
  flutter329,
  ffmpeg_7,
  gst_all_1,
  fuse3,
  libxtst,
  libaom,
  libopus,
  libpulseaudio,
  libva,
  libvdpau,
  libvpx,
  libxkbcommon,
  libyuv,
  pam,
  makeDesktopItem,
  rustPlatform,
  libayatana-appindicator,
  rustc,
  rustfmt,
  xdotool,
  xdg-user-dirs,
  pipewire,
  cargo-expand,
  yq,
  callPackage,
  addDriverRunpath,
  perl,
  openssl,
}:
let
  libdrmtap = callPackage ./libdrmtap.nix { };

  flutterRustBridge = rustPlatform.buildRustPackage rec {
    pname = "flutter_rust_bridge_codegen";
    # https://github.com/rustdesk/rustdesk/blob/master/.github/workflows/bridge.yml
    version = "1.80.1";

    src = fetchFromGitHub {
      owner = "fzyzcjy";
      repo = "flutter_rust_bridge";
      rev = "v${version}";
      hash = "sha256-SbwqWapJbt6+RoqRKi+wkSH1D+Wz7JmnVbfcfKkjt8Q=";
    };

    patches = [
      ./update-flutter-dev-path.patch
    ];

    cargoHash = "sha256-4khuq/DK4sP98AMHyr/lEo1OJdqLujOIi8IgbKBY60Y=";
    cargoBuildFlags = [
      "--package"
      "flutter_rust_bridge_codegen"
    ];
    doCheck = false;
  };

  ffigen = callPackage ./ffigen {
    flutter = flutter329;
  };

  sharedLibraryExt = rustc.stdenv.hostPlatform.extensions.sharedLibrary;

in
flutter329.buildFlutterApplication (finalAttrs: {
  pname = "rustdesk-flutter-unattended-wayland";
  # Master Cargo.toml version at the pinned rev; the nightly deb names its
  # artifacts after it too.
  version = "1.5.0-unstable";

  src = fetchFromGitHub {
    owner = "rustdesk";
    repo = "rustdesk";
    # master, same vintage as the nightly rustdesk-unattended-wayland deb
    rev = "435fe24a816819ec2d093be02b491bdacc2c7ca9";
    fetchSubmodules = true;
    hash = "sha256-A2992JqrK/wz0vwoWw6njE2GOSs+tPClU0HuXznH9rs=";
  };

  strictDeps = true;
  env.VCPKG_ROOT = "/homeless-shelter"; # idk man, makes the build go since https://github.com/21pages/hwcodec/commit/1873c34e3da070a462540f61c0b782b7ab15dc84
  env.OPENSSL_NO_VENDOR = true;

  # Configure the Flutter/Dart build
  sourceRoot = "${finalAttrs.src.name}/flutter";
  # Regenerated from the pinned commit:
  #   curl -sL https://raw.githubusercontent.com/rustdesk/rustdesk/<rev>/flutter/pubspec.lock | yq > pubspec.lock.json
  # git hashes: nix-prefetch-git each resolved-ref, then `nix hash convert --to sri`.
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  gitHashes = lib.importJSON ./git-hashes.json;

  # Configure the Rust build
  cargoRoot = "..";
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    patches = [ ./make-build-reproducible.patch ];
    hash = "sha256-mDgXYDHDzpqatMSBBjr5OJjtAXHPJKzget5fcSiDgGI=";
  };

  dontCargoBuild = true;
  cargoBuildFlags = "--lib";
  cargoBuildType = "release";
  # Feature set mirrors the CI DRM job:
  # python3 build.py --flutter --drm --hwcodec --unix-file-copy-paste --print-features
  cargoBuildFeatures = [
    "flutter"
    "hwcodec"
    "linux-pkg-config"
    "drm"
    "drm-wake"
    "unix-file-copy-paste"
  ];

  nativeBuildInputs = [
    # flutter_rust_bridge_codegen
    cargo
    copyDesktopItems
    rustfmt
    # Rust
    rustPlatform.cargoSetupHook
    rustPlatform.cargoBuildHook
    cargo-expand
    rustPlatform.bindgenHook
    ffigen
    yq
    perl
  ];

  buildInputs = [
    ffmpeg_7
    fuse3
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    libxtst
    libaom
    libopus
    libpulseaudio
    libva
    libvdpau
    libvpx
    pipewire
    libxkbcommon
    libyuv
    pam
    xdotool
    openssl
  ];

  prePatch = ''
    chmod -R +w ..
    cd ..
  '';

  patches = [
    ./make-build-reproducible.patch
  ];

  prepareBuildRunner = ''
    cp ${./build-runner.sh} build_runner
    substituteInPlace build_runner \
      --replace-fail "@bash@" "$SHELL"
    chmod +x build_runner
    export PATH=$PATH:$PWD
  '';

  postPatch = ''
    cd flutter
    if [ $cargoDepsCopy ]; then # That will be inherited to buildDartPackage and it doesn't have cargoDepsCopy
      substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
        --replace-fail "libayatana-appindicator3.so.1" "${lib.getLib libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
      # Disable static linking of ffmpeg since https://github.com/21pages/hwcodec/commit/1873c34e3da070a462540f61c0b782b7ab15dc84
      sed -i 's/static=//g' $cargoDepsCopy/*/hwcodec-*/build.rs
      sed -e '1i #include <cstdint>' -i $cargoDepsCopy/*/webm-1.1.0/src/sys/libwebm/mkvparser/mkvparser.cc
      sed -e '1i #include <cstdint>' -i $cargoDepsCopy/*/webm-sys-1.0.4/libwebm/mkvparser/mkvparser.cc
    fi

    substituteInPlace ../Cargo.toml --replace-fail ", \"staticlib\", \"rlib\"" ""

    # drmtap_dl.rs dlopen()s libdrmtap from an absolute deb path; when running
    # as root that is the ONLY candidate, so it must point into the Nix store.
    substituteInPlace ../libs/scrap/src/common/drmtap_dl.rs \
      --replace-fail "/usr/lib/rustdesk/libdrmtap.so.0" "${libdrmtap}/lib/libdrmtap.so.0"
  '';

  preBuild = ''
    # Build the Flutter/Rust bridge bindings
    cat <<EOF > bridge.yml
    rust_input:
      - "../src/flutter_ffi.rs"
    dart_output:
      - "./lib/generated_bridge.dart"
    llvm_path:
      - "${lib.getLib clangStdenv.cc.cc}"
    dart_format_line_length: 80
    llvm_compiler_opts: "-I ${lib.getLib clangStdenv.cc.cc}/lib/clang/${lib.versions.major clangStdenv.cc.version}/include -I ${clangStdenv.cc.libc_dev}/include"
    EOF
    runHook prepareBuildRunner
    RUST_LOG=info ${flutterRustBridge}/bin/flutter_rust_bridge_codegen bridge.yml

    # Build the Rust shared library
    cd ..
    preBuild=() # prevent loops
    cargoBuildHook
    mv ./target/*/release/liblibrustdesk${sharedLibraryExt} ./target/release/liblibrustdesk${sharedLibraryExt}
    cd flutter
  '';

  postInstall = ''
    mkdir -p $out/share/polkit-1/actions $out/share/icons/hicolor/{256x256,scalable}/apps
    cp ../res/128x128@2x.png $out/share/icons/hicolor/256x256/apps/rustdesk.png
    cp ../res/scalable.svg $out/share/icons/hicolor/scalable/apps/rustdesk.svg
  '';

  extraWrapProgramArgs = ''
    --prefix LD_LIBRARY_PATH : ${addDriverRunpath.driverLink}/lib \
    --prefix PATH : ${lib.makeBinPath [ xdg-user-dirs ]}
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "rustdesk";
      desktopName = "RustDesk";
      genericName = "Remote Desktop";
      comment = "Remote Desktop";
      exec = "rustdesk %u";
      icon = "rustdesk";
      terminal = false;
      type = "Application";
      startupNotify = true;
      categories = [
        "Network"
        "RemoteAccess"
        "GTK"
      ];
      keywords = [ "internet" ];
      actions.new-window = {
        name = "Open a New Window";
        exec = "rustdesk %u";
      };
    })
    (makeDesktopItem {
      name = "rustdesk-link";
      desktopName = "RustDeskURL Scheme Handler";
      noDisplay = true;
      mimeTypes = [ "x-scheme-handler/rustdesk" ];
      tryExec = "rustdesk";
      exec = "rustdesk %u";
      icon = "rustdesk";
      terminal = false;
      type = "Application";
      categories = [ "Network" ];
    })
  ];

  passthru = {
    inherit libdrmtap;
  };

  meta = {
    description = "RustDesk client with the DRM/KMS unattended-wayland capture backend (nightly-era master build)";
    homepage = "https://github.com/rustdesk/rustdesk";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    mainProgram = "rustdesk";
    platforms = lib.platforms.linux;
  };
})
