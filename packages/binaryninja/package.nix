{ lib
, pkgs
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, copyDesktopItems
, makeDesktopItem
, makeSanitizedLauncherHook
, _7zz
, dbus
, fontconfig
, freetype
, glib
, libGL
, libGLU
, libxkbcommon
, libxml2
, wayland
, libxi
, libxrender
, libxcb-image
, libxcb-keysyms
, libxcb-render-util
, libxcb-wm
, qt6Packages
, binaryNinjaArchive ? throw ''
    pkgs.binaryninja requires a user-supplied `binaryNinjaArchive`.
    Set it to a `requireFile` expression for the Binary Ninja archive.
  ''
,
}:

let
  archiveName = builtins.baseNameOf (toString binaryNinjaArchive);
  versionMatch = builtins.match
    ".*([0-9]+[.][0-9]+[.][0-9]+)(-dev)?.*"
    archiveName;
  version =
    if versionMatch == null then
      throw "Binary Ninja archive name must contain a version like 5.3.9757 or 5.3.9757-dev, got: ${archiveName}"
    else
      builtins.elemAt versionMatch 0;
  isDev = builtins.elemAt versionMatch 1 == "-dev";
  pythonPackage = if lib.versionAtLeast version "6.0" then pkgs.python313 else pkgs.python312;
  pname = "binaryninja";
  executableName = pname + lib.optionalString isDev "-dev";
  pythonExecutableName = "bnpython3" + lib.optionalString isDev "-dev";
  desktopName = "Binary Ninja" + lib.optionalString isDev " (Dev Channel)";

  desktopIcon = fetchurl {
    url = "https://docs.binary.ninja/img/logo.png";
    hash = "sha256-TzGAAefTknnOBj70IHe64D6VwRKqIDpL4+o9kTw0Mn4=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version;
  src = binaryNinjaArchive;

  nativeBuildInputs = [
    _7zz
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
    makeSanitizedLauncherHook
    pythonPackage.pkgs.wrapPython
    qt6Packages.wrapQtAppsHook
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
    qt6Packages.qtbase
    qt6Packages.qtdeclarative
    qt6Packages.qtwayland
    pythonPackage
    pythonPackage.pkgs.pip
  ];

  pythonPath = with pythonPackage.pkgs; [ pip ];

  appendRunpaths = [ "${lib.getLib pythonPackage}/lib" ];

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
      -not -path "$installDir/plugins/python/lib/*" \
      -delete

    buildPythonPath "$pythonPath"
    makeWrapper "$installDir/binaryninja" "$out/bin/${executableName}" \
      --prefix PATH : "${lib.makeBinPath [ pythonPackage ]}" \
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
      name = executableName;
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
