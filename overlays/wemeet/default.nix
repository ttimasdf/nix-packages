_final: prev:
let
  fridaVersion = "17.5.1";
  fridaAsset =
    {
      x86_64-linux = {
        arch = "x86_64";
        hash = "sha256-1mn6w1IHWQpNWM+jGRxYZFkM3cjsjoJ/rydE/3Wffbc=";
      };
      aarch64-linux = {
        arch = "arm64";
        hash = "sha256-tojSNB61Rdhjiv7SsSqKMOJcaTR9c/Zhc9MV6Ebs7o8=";
      };
    }
    .${prev.stdenv.hostPlatform.system};
  fridaGadget = prev.fetchurl {
    url = "https://github.com/frida/frida/releases/download/${fridaVersion}/frida-gadget-${fridaVersion}-linux-${fridaAsset.arch}.so.xz";
    inherit (fridaAsset) hash;
  };
  fridaScript = prev.writeText "frida_wemeet.js" (builtins.readFile ./patch/frida_wemeet.js);
  fridaConfig = prev.writeText "libgadget.config" (
    builtins.toJSON {
      interaction = {
        type = "script";
        path = toString fridaScript;
      };
    }
  );
in
{
  wemeet = prev.wemeet.overrideAttrs (oldAttrs: {
    pname = oldAttrs.pname + "-frida-patched";

    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
      prev.patchelf
      prev.xz
    ];

    postFixup = (oldAttrs.postFixup or "") + ''
      # Load Frida before WeMeet's bundled Qt. The script resolves exported C++
      # symbols by name and replaces drop-shadow rendering with direct source
      # rendering, avoiding the stale QPaintDevice crash on external Xwayland
      # outputs without relying on fixed file offsets or instruction bytes.
      xz -dc ${fridaGadget} > "$out/app/wemeet/lib/libgadget.so"
      chmod +x "$out/app/wemeet/lib/libgadget.so"
      install -Dm444 ${fridaConfig} "$out/app/wemeet/lib/libgadget.config"
      patchelf --add-needed libgadget.so "$out/app/wemeet/bin/wemeetapp"

      # The native-Wayland camera shim forces libxcast onto an X11 EGLDisplay,
      # which can make playback surface creation fail with EGL_BAD_ALLOC. Keep
      # the normal launcher unchanged and expose an experimental playback-first
      # variant that removes only this shim immediately before launching WeMeet.
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
    '';
  });
}
