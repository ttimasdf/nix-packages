_final: prev:
let
  wemeetDropShadowFix = prev.stdenv.mkDerivation {
    pname = "wemeet-drop-shadow-fix";
    version = "0-unstable-2026-09-07";

    src = ./wemeet-drop-shadow-fix.c;
    dontUnpack = true;
    dontWrapQtApps = true;

    buildPhase = ''
      runHook preBuild

      $CC $CFLAGS -Wall -Wextra -Werror -fPIC -shared \
        -o libwemeet-drop-shadow-fix.so $src -ldl

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -Dm755 ./libwemeet-drop-shadow-fix.so \
        $out/lib/libwemeet-drop-shadow-fix.so

      runHook postInstall
    '';

    meta = {
      description = "Native vtable hook for WeMeet's bundled Qt";
      homepage = "https://wemeet.qq.com";
      license = prev.lib.licenses.mit;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  };
in
{
  wemeet = prev.wemeet.overrideAttrs (oldAttrs: {
    pname = oldAttrs.pname + "-native-patched";

    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ prev.makeWrapper ];

    # The upstream package creates the launchers in preFixup. Create the
    # playback-first variant before adding our outer wrapper, then wrap every
    # launcher so the native hook is present in all modes.
    preFixup = (oldAttrs.preFixup or "") + ''
      cp "$out/bin/wemeet" "$out/bin/wemeet-wayland-playback"
      substituteInPlace "$out/bin/wemeet-wayland-playback" \
        --replace-fail \
          'exec "' \
          'filteredPreload=""
      oldIFS="$IFS"
      IFS=:
      for library in $LD_PRELOAD; do
        case "$library" in
          *wemeet-camera-fix*) ;;
          *) filteredPreload="''${filteredPreload:+$filteredPreload:}$library" ;;
        esac
      done
      IFS="$oldIFS"
      export LD_PRELOAD="$filteredPreload"
      export QT_QPA_PLATFORM=wayland
      exec "'

      for launcher in "$out/bin/wemeet" \
        "$out/bin/wemeet-xwayland" "$out/bin/wemeet-wayland-playback"; do
        wrapProgram "$launcher" \
          --prefix LD_PRELOAD : ${wemeetDropShadowFix}/lib/libwemeet-drop-shadow-fix.so
      done
    '';

  });
}
