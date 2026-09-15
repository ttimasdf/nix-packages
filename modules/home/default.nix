let
  modules = {
    ida-pro = ./ida-pro.nix;
  };
in
modules
// {
  all = {
    imports = builtins.attrValues modules;
  };
}
