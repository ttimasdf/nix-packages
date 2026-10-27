# EasyTier Server (headless binaries)

`pkgs.easytier-bin` packages the official EasyTier release binaries for
headless use: `easytier-core` (mesh peer), `easytier-cli` (management), and
`easytier-web` / `easytier-web-embed` (self-hosted web console + config
server; the `-embed` build serves the dashboard frontend).

## Why

The nixpkgs `easytier` package ships core+cli only and lags releases; the web
console is not packaged upstream at all. This package tracks official release
zips (pinned per version) so mesh peers, the VPS rendezvous, and the web
console all run one identical version.

## Source / platform assumptions

- Official GitHub release zip (`easytier-linux-x86_64-v<ver>.zip`), hash-pinned.
- x86_64-linux only; binaries are upstream-built (binaryNativeCode).

## Use

Overlay (`known-rabbit-packages.overlays.default`) then reference `pkgs.easytier-bin`,
or consume the flake output directly. Typically consumed via the NixOS
`services.easytier` module's `package` option for peers, and a systemd service
for `easytier-web-embed`.
