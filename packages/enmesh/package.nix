{
  lib,
  stdenv,
  flutter344,
  rustPlatform,
  fetchFromGitHub,
  makeDesktopItem,
  copyDesktopItems,
  writeText,
  libayatana-appindicator,
  protobuf,
}:

let
  pname = "enmesh";
  version = "3.0.0-rc.3";

  src = fetchFromGitHub {
    owner = "ttimasdf";
    repo = "enmesh";
    tag = "v${version}";
    hash = "sha256-KSjd/u5iBrrnz7VidvELqmYA7oJNt4F8GYC1gRYKW/g=";
    fetchSubmodules = true;
  };

  rustDep = rustPlatform.buildRustPackage {
    inherit pname version src;

    sourceRoot = "${src.name}/rust";

    cargoHash = "sha256-Pk0/d06TagbaJnyB8Uojqr4XzWzX/5EoRr3wJhDZLOw=";

    nativeBuildInputs = [
      protobuf
      rustPlatform.bindgenHook
    ];

    passthru.libraryPath = "lib/librust_lib_enmesh.so";

    meta.platforms = [ "x86_64-linux" ];
  };
in
flutter344.buildFlutterApplication {
  inherit pname version src;

  autoPubspecLock = src + "/pubspec.lock";

  customSourceBuilders = {
    rust_lib_enmesh =
      { version, src, ... }:
      stdenv.mkDerivation {
        pname = "rust_lib_enmesh";
        inherit version src;
        inherit (src) passthru;

        postPatch =
          let
            fakeCargokitCmake = writeText "FakeCargokit.cmake" ''
              function(apply_cargokit target manifest_dir lib_name any_symbol_name)
                set("''${target}_cargokit_lib" ${rustDep}/${rustDep.passthru.libraryPath} PARENT_SCOPE)
              endfunction()
            '';
          in
          ''
            cp ${fakeCargokitCmake} rust_builder/cargokit/cmake/cargokit.cmake
          '';

        installPhase = ''
          runHook preInstall

          cp -r . "$out"

          runHook postInstall
        '';
      };
  };

  nativeBuildInputs = [
    copyDesktopItems
  ];

  buildInputs = [
    libayatana-appindicator
  ];

  postInstall = ''
    mkdir -p $out/share/pixmaps
    cp $out/app/${pname}/data/flutter_assets/assets/logo.png $out/share/pixmaps/enmesh.png
  '';

  extraWrapProgramArgs = ''
    --prefix LD_LIBRARY_PATH : $out/app/${pname}/lib
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "enmesh";
      desktopName = "Enmesh";
      comment = "Enmesh is an EasyTier desktop client";
      exec = "enmesh %u";
      icon = "enmesh";
      terminal = false;
      type = "Application";
      categories = [ "Network" ];
      startupNotify = true;
      keywords = [
        "Easytier"
        "VPN"
        "Network"
        "Proxy"
      ];
    })
  ];

  passthru = {
    inherit rustDep;
  };

  meta = with lib; {
    description = "Enmesh desktop client";
    homepage = "https://github.com/ttimasdf/enmesh";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "enmesh";
  };
}
