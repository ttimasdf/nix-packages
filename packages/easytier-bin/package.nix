{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "easytier-bin";
  version = "2.7.0";

  src = fetchurl {
    url = "https://github.com/EasyTier/EasyTier/releases/download/v${finalAttrs.version}/easytier-linux-x86_64-v${finalAttrs.version}.zip";
    hash = "sha256-RCI4kSBlU3woCGkIkhcwPj0oE+nF0qaxTeryVmcGWqI=";
  };

  sourceRoot = "easytier-linux-x86_64";

  nativeBuildInputs = [ unzip ];

  # Prebuilt release binaries (statically linked upstream); nothing to build.
  dontBuild = true;
  dontStrip = true; # preserve prebuilt symbols as shipped

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 easytier-core easytier-cli easytier-web easytier-web-embed $out/bin/
    runHook postInstall
  '';

  meta = {
    description = "EasyTier headless binaries (core/cli/web) from official releases — for mesh peers and the self-hosted web console";
    homepage = "https://easytier.cn";
    license = lib.licenses.asl20;
    mainProgram = "easytier-core";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
