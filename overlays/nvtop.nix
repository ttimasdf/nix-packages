final: prev: {
  nvtopPackages = prev.nvtopPackages // {
    nvidia-intel = final.callPackage "${prev.path}/pkgs/tools/system/nvtop/build-nvtop.nix" {
      intel = true;
      nvidia = true;
    };
  };
}
