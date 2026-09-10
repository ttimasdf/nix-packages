let
  modules = {
    enmesh = ./enmesh.nix;
    easytier-gui = ./easytier-gui.nix;
    fido-linux-id = ./fido-linux-id.nix;
    rustdesk-unattended-wayland = ./rustdesk-unattended-wayland.nix;
  };
in
modules
// {
  all = {
    imports = builtins.attrValues modules;
  };
}
