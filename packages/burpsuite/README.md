# Burp Suite

`pkgs.burpsuite` packages the PortSwigger Burp Suite Java application with a launcher, desktop entry, and the local loader integration. It defaults to the Professional edition and is an unfree binary-bytecode package.

## Use

Apply the default overlay, then install the package:

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.default ];
environment.systemPackages = [ pkgs.burpsuite ];
```

Use the Community edition by overriding the package argument:

```nix
let burpsuite-community = pkgs.burpsuite.override { proEdition = false; };
in
{ environment.systemPackages = [ burpsuite-community ]; }
```

`gdkScale` defaults to `2`; override it if the display scaling needs adjustment. The package is built for the platforms supported by the selected Nixpkgs JDK. Build directly with `nix build github:ttimasdf/nix-packages#burpsuite`.
