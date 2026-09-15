{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.ida-pro;

  # IDA installs into `<package>/opt/idapro`; this is the directory an hcli
  # "instance" points at (`hcli ida list`, `ida.default`, idalib, ...).
  idaDirectory = "${cfg.package}/opt/idapro";

  # hcli owns `config.json`: it rewrites it whenever the schema version
  # changes or an instance is registered. A read-only symlink into the Nix
  # store would make every hcli invocation fail, so merge our keys into the
  # live file during activation instead of managing it as a home file.
  configureHcli = pkgs.writeShellApplication {
    name = "ida-pro-configure-hcli";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      config_file="$1"
      instance_name="$2"
      instance_path="$3"
      set_default="$4"

      mkdir -p "$(dirname "$config_file")"

      if [[ -f "$config_file" ]]; then
        current="$(cat "$config_file")"
      else
        current="{}"
      fi

      updated="$(
        jq \
          --arg name "$instance_name" \
          --arg path "$instance_path" \
          --argjson default "$set_default" \
          '
            .["ida.instances"] = ((.["ida.instances"] // {}) + { ($name): $path })
            | if $default then .["ida.default"] = $name else . end
          ' <<<"$current"
      )"

      printf '%s\n' "$updated" > "$config_file"
    '';
  };
in
{
  options.programs.ida-pro = {
    enable = lib.mkEnableOption "IDA Pro";

    package = lib.mkPackageOption pkgs "ida-pro" { };

    hcli = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Register the IDA installation with {command}`hcli` by editing its
          configuration file.
        '';
      };

      instanceName = lib.mkOption {
        type = lib.types.str;
        default = "nix";
        description = ''
          Name under which the IDA installation is registered in the hcli
          `ida.instances` mapping.
        '';
      };

      default = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether the registered instance becomes the hcli default
          (`ida.default`). Only meaningful when a single instance is managed.
        '';
      };

      configFile = lib.mkOption {
        type = lib.types.str;
        default =
          if pkgs.stdenv.hostPlatform.isDarwin then
            "${config.home.homeDirectory}/Library/Application Support/hcli/config.json"
          else
            "${config.xdg.configHome}/hcli/config.json";
        defaultText = lib.literalExpression ''
          if pkgs.stdenv.hostPlatform.isDarwin then
            "${config.home.homeDirectory}/Library/Application Support/hcli/config.json"
          else
            "${config.xdg.configHome}/hcli/config.json"
        '';
        description = ''
          Path to the hcli configuration file. Defaults to the location
          chosen by {command}`platformdirs` (the library hcli uses to resolve
          its config directory).
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.activation.idaProHcli = lib.mkIf cfg.hcli.enable (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${configureHcli}/bin/ida-pro-configure-hcli \
          "${cfg.hcli.configFile}" \
          "${cfg.hcli.instanceName}" \
          "${idaDirectory}" \
          "${lib.boolToString cfg.hcli.default}"
      ''
    );
  };
}
