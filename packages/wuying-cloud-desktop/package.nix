{
  lib,
  stdenv,
  requireFile,
  dpkg,
  buildFHSEnv,
  appimageTools,
  writeShellScript,
  version ? "7.11.0-wuying",
  hash ? "sha256-NdqvQVi9jq4YQFRQQQDU6s6rfVNrl9gYS2yJhnUzcxE=",
  wuyingSource ? null,
}:

let
  pname = "wuying-cloud-desktop";
  compatibility = import ./compatibility.nix {
    system = stdenv.hostPlatform.system;
  };

  src =
    if wuyingSource != null then
      wuyingSource
    else
      requireFile {
        name = "wuying-cloud-desktop-${version}.deb";
        inherit hash;
        message = ''
          Please download the Wuying Cloud Desktop installer and place it in the store:
          $ nix-prefetch-url file:///path/to/wuying-cloud-desktop-${version}.deb
        '';
      };

  unpacked = stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = [ dpkg ];

    unpackPhase = ''
      dpkg-deb -x $src .
    '';

    installPhase = ''
      mkdir -p $out/opt $out/share
      cp -r opt/wuying $out/opt/
      cp -r usr/share/applications $out/share/
      cp -r usr/share/fonts $out/share/
      cp -r usr/share/icons $out/share/
    '';
  };

  meta = with lib; {
    description = "Wuying Cloud Desktop - Alibaba Cloud productivity tool";
    homepage = "https://www.aliyun.com/product/wuying";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };

in
buildFHSEnv (
  appimageTools.defaultFhsEnvArgs
  // {
    inherit pname version meta;

    targetPkgs =
      pkgs:
      (appimageTools.defaultFhsEnvArgs.targetPkgs pkgs)
      ++ (with pkgs; [
        compatibility.qt5w.qtbase
        compatibility.qt5w.qtwebengine
        libusb1
        libevdev
        libinput
        libpulseaudio
        libopus
        compatibility.libtiff-abi5
        unpacked
      ]);

    runScript = writeShellScript "wuying" ''
      export LD_LIBRARY_PATH="/opt/wuying/lib:$LD_LIBRARY_PATH"
      exec /opt/wuying/bin/wuying "$@"
    '';

    extraInstallCommands = ''
      mkdir -p $out/share
      cp -r ${unpacked}/share/applications $out/share/
      cp -r ${unpacked}/share/icons $out/share/

      substituteInPlace $out/share/applications/wuying.desktop \
        --replace "Exec=env LD_LIBRARY_PATH=/opt/wuying/lib /opt/wuying/bin/wuying" "Exec=$out/bin/${pname}" \
        --replace "Icon=cloudspace-logo" "Icon=$out/share/icons/hicolor/scalable/apps/cloudspace-logo.png"
    '';
  }
)
