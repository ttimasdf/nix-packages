{
  lib,
  stdenv,
  requireFile,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  makeSanitizedLauncherHook,
  _7zz,
  dbus,
  fontconfig,
  freetype,
  glib,
  libGL,
  libGLU,
  libxkbcommon,
  libxml2,
  wayland,
  libxi,
  libxrender,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-wm,
  qt6Packages,
  python312,
  qt68Packages ? null,
  qt68python312 ? null,
  useQtFromNixpkgs ? false,
  version ? "5.3.9757",
  hash ? "sha256-m0THmHL7CX0F/E4wA+AghRMa9y9c85r+nCgkoUmnZjQ=",
  binaryNinjaSource ? null,
}:

let
  _ = lib.asserts.assertMsg (
    !useQtFromNixpkgs || (qt68Packages != null && qt68python312 != null)
  ) "qt68Packages and qt68python312 must be provided when useQtFromNixpkgs is true";

  isDev = lib.hasSuffix "-dev" version;
  pname = if isDev then "binaryninja-dev" else "binaryninja";
  executableName = pname;
  pythonExecutableName = if isDev then "bnpython3-dev" else "bnpython3";
  desktopName = "Binary Ninja" + lib.optionalString isDev " (Dev Channel)";
  archiveName = "binaryninja_linux_commercial.${version}${lib.optionalString (!isDev) "-stable"}.7z";

  qt6Packages' = if useQtFromNixpkgs then qt68Packages else qt6Packages;
  python3' = if useQtFromNixpkgs then qt68python312 else python312;

  src =
    if binaryNinjaSource != null then
      binaryNinjaSource
    else
      requireFile {
        name = archiveName;
        inherit hash;
        url = "https://binary.ninja/recover/";
      };

  desktopIcon = fetchurl {
    url = "https://docs.binary.ninja/img/logo.png";
    hash = "sha256-TzGAAefTknnOBj70IHe64D6VwRKqIDpL4+o9kTw0Mn4=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version src;

  nativeBuildInputs = [
    _7zz
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
    makeSanitizedLauncherHook
    python3'.pkgs.wrapPython
    qt6Packages'.wrapQtAppsHook
  ];

  buildInputs = [
    dbus
    fontconfig
    freetype
    glib
    libGL
    libGLU
    libxkbcommon
    libxml2
    wayland
    libxi
    libxrender
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm
    qt6Packages'.qtbase
    qt6Packages'.qtdeclarative
    qt6Packages'.qtwayland
    python3'
    python3'.pkgs.pip
  ]
  ++ lib.optionals useQtFromNixpkgs [
    python3'.pkgs.pyside6
    python3'.pkgs.shiboken6
  ];

  pythonPath =
    with python3'.pkgs;
    [ pip ]
    ++ lib.optionals useQtFromNixpkgs [
      pyside6
      shiboken6
    ];

  appendRunpaths = [ "${lib.getLib python3'}/lib" ];

  unpackPhase = ''
    runHook preUnpack

    local tmpDir
    tmpDir=$(mktemp -d)
    7zz x -snld "$src" -o"$tmpDir"

    local archiveRoot
    archiveRoot=$(find "$tmpDir" -maxdepth 1 -mindepth 1 -type d)
    if [ -z "$archiveRoot" ] || [ "$(echo "$archiveRoot" | wc -l)" -ne 1 ]; then
      echo "error: Binary Ninja archive must contain exactly one directory"
      exit 1
    fi

    mv "$archiveRoot"/* .
    rm -rf "$tmpDir"

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    installDir=$out/opt/${pname}
    mkdir -p "$installDir" $out/bin
    cp -r . "$installDir"

    find "$installDir" \
      -type f \
      -name '*.so.*' \
      -not -name 'libbinaryninjacore.so.*' \
      -not -name 'libbinaryninjaui.so.*' \
      -not -name 'liblldb.so.*' \
      -not -name 'libicu*.so.*' \
      -not -name 'libQt6*.so.*' \
      -not -name 'libshiboken6.abi*.so.*' \
      -not -name 'libpyside6.abi*.so.*' \
      -delete

    if [ "${toString useQtFromNixpkgs}" = "1" ]; then
      find "$installDir" -name 'libicu*.so.*' -delete
      find "$installDir" -name 'libQt6*.so.*' -delete
      find "$installDir/qt" -type f -name '*.so' -delete
      rm -r "$installDir/python3/PySide6" "$installDir/python3/shiboken6"
      find "$installDir" -name 'libshiboken6.abi*.so.*' -delete
      find "$installDir" -name 'libpyside6.abi*.so.*' -delete
    fi

    buildPythonPath "$pythonPath"
    makeWrapper "$installDir/binaryninja" "$out/bin/${executableName}" \
      --prefix PATH : "${lib.makeBinPath [ python3' ]}" \
      --prefix PYTHONPATH : "$program_PYTHONPATH" \
      --prefix LD_LIBRARY_PATH : "$installDir" \
      "''${sanitizedLauncherArgs[@]}" \
      "''${qtWrapperArgs[@]}"

    makeWrapper "$installDir/bnpython3" "$out/bin/${pythonExecutableName}"

    install -Dm644 ${desktopIcon} "$out/share/pixmaps/${pname}.png"
    rm -f "$installDir/env-vars"

    runHook postInstall
  '';

  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    find $out/opt/${pname}/plugins/lldb/lib -name 'liblldb.so*' -print0 | \
      xargs -0 -r patchelf --replace-needed libxml2.so.2 libxml2.so
  '';

  dontWrapQtApps = true;
  dontWrapWithSanitizedLauncher = true;
  sanitizedLaunchers = [ "xdg-open" ];

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = executableName;
      icon = pname;
      inherit desktopName;
      mimeTypes = [
        "application/x-binaryninja"
        "x-scheme-handler/binaryninja"
      ];
      comment = "Interactive decompiler, disassembler, debugger, and binary analysis platform";
      categories = [ "Utility" ];
      terminal = false;
      startupWMClass = "binaryninja";
    })
  ];

  passthru = {
    inherit archiveName isDev;
  };

  meta = {
    changelog = "https://binary.ninja/changelog/#${
      lib.replaceStrings [ "." ] [ "-" ] finalAttrs.version
    }";
    description = "Interactive decompiler, disassembler, debugger";
    homepage = "https://binary.ninja/";
    license = lib.licenses.unfree;
    mainProgram = executableName;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
