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
      source = lib.getExe cfg.package;
    };
  };
}
