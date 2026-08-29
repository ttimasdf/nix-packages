{
  lib,
  stdenv,
  fetchFromGitHub,
  git, # tests spawn git for worktree isolation
  rust,
  rustPlatform,
  pkg-config,
  glib,
  gtk3,
  libsoup_3,
  cargo-tauri,
  fetchNpmDeps,
  npmHooks,
  glib-networking,
  openssl,
  webkitgtk_4_1,
  nodejs,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "y-agent";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "gorgiaxx";
    repo = "y-agent";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xKs8ZIEGYlesTWSZCXB0fNM294K/2gjM/h63Wm3fVYk=";
  };

  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  # Upstream's lockfile is committed without "resolved"/"integrity" fields,
  # which fetchNpmDeps cannot cache. Vendor a repaired copy with identical pins
  # and registry URLs backfilled; replaced before npmConfigHook validates it.
  postPatch = ''
    cp ${./package-lock.json} crates/y-gui/package-lock.json
  '';

  npmRoot = "./crates/y-gui";
  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/crates/y-gui";
    postPatch = ''
      cp ${./package-lock.json} package-lock.json
    '';
    hash = "sha256-DQTNOEtz2mlrph7iQB/gCGLHpSu+CRxn8ZgCIwhIjjc=";
  };
  npmFlags = [ "--legacy-peer-deps" ];

  nativeBuildInputs = [
    cargo-tauri.hook
    git
    nodejs
    npmHooks.npmConfigHook
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    glib-networking
    gtk3
    openssl
    webkitgtk_4_1
    libsoup_3
  ];

  postBuild = ''
    # cargo-tauri builds y-gui only, so we need to build y-agent separately
    ${rust.envVars.setEnv} cargo build "''${cargoFlagsArray[@]}" --bin y-agent
  '';

  postInstall = ''
    # Copy the y-agent binary to the output directory
    releaseDir=target/${stdenv.targetPlatform.rust.cargoShortTarget}/${finalAttrs.cargoBuildType}
    mkdir -p $out/bin
    cp $releaseDir/y-agent $out/bin/
  '';

  # Skip flaky sandbox-incompatible tests:
  # - hook_handler test times out in the nix sandbox
  # - "outside_working_dir" permission tests expect EACCES from paths outside
  #   the working dir, but the sandbox's writable tmpfs grants access instead
  checkFlags = [
    "--skip=hook_handler::tests::handler_tests::test_command_hook_timeout_killed"
    "--skip=outside_working_dir"
  ];

  meta = {
    description = "AI coding agent with Tauri GUI";
    homepage = "https://github.com/gorgiaxx/y-agent";
    changelog = "https://github.com/gorgiaxx/y-agent/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "y-agent";
  };
})
