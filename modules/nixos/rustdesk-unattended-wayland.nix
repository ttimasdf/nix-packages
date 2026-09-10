{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.rustdesk-unattended-wayland;
in
{
  options.services.rustdesk-unattended-wayland = {
    enable = lib.mkEnableOption "RustDesk remote access with the DRM/KMS unattended-wayland capture backend";

    package = lib.mkPackageOption pkgs "rustdesk-flutter-unattended-wayland" { };
  };

  config = lib.mkIf cfg.enable {
    # Tray / GUI and the `rustdesk` CLI; the root service below is the
    # unattended capture side (rustdesk --service).
    environment.systemPackages = [ cfg.package ];

    # Mirrors the unit the upstream deb ships in
    # usr/share/rustdesk/files/systemd/rustdesk.service.
    systemd.services.rustdesk = {
      description = "RustDesk";
      requires = [ "network.target" ];
      after = [ "systemd-user-sessions.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} --service";
        # Kill the tray and server processes spawned by the service.
        KillMode = "mixed";
        TimeoutStopSec = 30;
        User = "root";
        LimitNOFILE = 100000;
      };

      environment = {
        PULSE_LATENCY_MSEC = "60";
        PIPEWIRE_LATENCY = "1024/48000";
      };
    };
  };
}
