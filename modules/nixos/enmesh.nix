{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.enmesh;
in
{
  options.programs.enmesh = {
    enable = lib.mkEnableOption "enmesh";
    package = lib.mkPackageOption pkgs "enmesh" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    security.wrappers.enmesh = {
      owner = "root";
      group = "root";
      capabilities = "cap_net_admin+ep";
      # `${lib.getExe cfg.package}` is the bash wrapper that
      # buildFlutterApplication generates, and file capabilities cannot be set
      # on scripts (NixOS rejects non-ELF wrapper sources). Use the real Flutter
      # executable instead; it locates its bundled plugin libraries through the
      # `$ORIGIN/lib` RUNPATH baked into it.
      source = "${cfg.package}/app/enmesh/enmesh";
    };
  };
}
