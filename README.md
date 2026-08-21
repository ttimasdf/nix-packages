# nix-packages

Personal Nix packages, opt-in Nixpkgs overlays, and package-specific NixOS modules.

## Flake usage

Add the repository as an input and make its packages available through the default overlay:

```nix
{
  inputs.rabbit-packages = {
    url = "github:ttimasdf/nix-packages";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, rabbit-packages, ... }: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs.overlays = [
            rabbit-packages.overlays.default
            # Opt in to overrides separately:
            # rabbit-packages.overlays.kscreen
          ];
        }
      ];
    };
  };
}
```

Packages can also be built directly:

```console
nix build github:ttimasdf/nix-packages#yakit
```

The default overlay only adds packages. Existing-package overrides such as `kscreen`, `ghidra`, and `qt68` are exported separately under `overlays`.

Package-specific NixOS modules are available as `nixosModules.astral`, `nixosModules.easytier-gui`, and `nixosModules.fido-linux-id`.

## NUR

The root `default.nix` is a NUR-compatible repository expression. Once registered, packages can be consumed through `pkgs.nur.repos.ttimasdf`.

## Development

```console
nix flake show
nix build .#<package>
nix fmt -- .
```
