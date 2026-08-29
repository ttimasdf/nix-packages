# Decode legacy Chinese archive names with libnatspec in 7-Zip.
final: prev:
let
  inherit (prev) lib;
  findPatches = (import ../../lib/rabit-lib.nix { inherit (prev) lib; }).findPatches;
in
{
  _7zz-nls = prev._7zz-rar.overrideAttrs (oldAttrs: {
    pname = oldAttrs.pname + "-nls";
    buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ final.libnatspec ];

    # AUR's 7zip-natspec patch, vendored with LF line endings: the pristine
    # AUR patch is CRLF and no longer applies to LF-formatted 7-Zip sources.
    patches = (oldAttrs.patches or [ ]) ++ (findPatches ./patches);

    postPatch = (oldAttrs.postPatch or "") + ''
      substituteInPlace CPP/7zip/Archive/Zip/ZipItem.cpp \
        --replace-fail \
          'natspec_get_charset_by_locale(NATSPEC_DOSCS, "")' \
          '"CP936"'
    '';

    # KDE Ark searches for "7z" rather than "7zz".
    postInstall = (oldAttrs.postInstall or "") + ''
      ln -s 7zz "$out/bin/7z"
    '';

    meta = lib.recursiveUpdate oldAttrs.meta {
      description = oldAttrs.meta.description + " with CP936 filename decoding";
      longDescription = ''
        ${oldAttrs.meta.longDescription or oldAttrs.meta.description}

        This variant uses libnatspec to decode unmarked ZIP filenames as CP936.
      '';
    };
  });
}
