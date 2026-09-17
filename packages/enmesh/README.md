# Enmesh

Enmesh (formerly Astral NG) is the `ttimasdf/enmesh` Linux desktop client for EasyTier, exposed as `pkgs.enmesh`. It currently supports `x86_64-linux` and requires the `CAP_NET_ADMIN` capability to manage network interfaces.

The package is pinned to `v3.0.0`. `v3.0.0-rc.3` was the first tagged release carrying the astral-ng → enmesh rebrand (binary `enmesh`, Rust crate `rust_lib_enmesh`, deep-link scheme `enmesh://`), so upgrading from `astral-ng` replaces the old package: existing installs under the `pw.rabit.astralng` application ID must be re-paired, and `astral://` room links no longer open.

## Use

The package-specific NixOS module configures the capability wrapper and installs the client:

```nix
{
  imports = [ inputs.known-rabbit-packages.nixosModules.enmesh ];
  nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
  programs.enmesh.enable = true;
}
```

To select a different package through the module, set `programs.enmesh.package`. The raw package is also available as `pkgs.enmesh`:

```nix
environment.systemPackages = [ pkgs.enmesh ];
```

Build it directly with `nix build github:ttimasdf/nix-packages#enmesh`.

## Updating

1. Bump `version`, the `src` hash and `cargoHash` in `package.nix`.
2. Regenerate the checked-in pub lock:

   ```bash
   nix-shell -p yq curl --run '
     curl -fsSL "https://raw.githubusercontent.com/ttimasdf/enmesh/v<version>/pubspec.lock" |
       yq . > pubspec.lock.json
   '
   ```

   `pubspec.lock.json` is `yq . pubspec.lock` — exactly what
   `buildFlutterApplication` derives from `autoPubspecLock` — where `yq` is
   `pkgs.yq` (python-yq). It is checked in and passed as
   `pubspecLock = lib.importJSON ./pubspec.lock.json;` so that evaluating the
   package needs no import-from-derivation. An IFD has to be *built* while the
   package is evaluated, so `autoPubspecLock` would require `yq` on every
   machine that evaluates the configuration — including an offline installer
   ISO. Forgetting to regenerate the file fails the build with an out-of-date
   lock rather than producing a wrong one.
