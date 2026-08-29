# Decode legacy Chinese archive names written by NLS-enabled Info-ZIP zip.
_final: prev: {
  zip-nls = (prev.zip.override { enableNLS = true; }).overrideAttrs (oldAttrs: {
    pname = oldAttrs.pname + "-nls";

    # The hosts use English locales, but these packages are intended to handle
    # archives whose unmarked filenames use the Chinese DOS code page.
    postPatch = (oldAttrs.postPatch or "") + ''
      substituteInPlace unix/unix.c zipnote.c \
        --replace-fail \
          'natspec_get_charset_by_locale(NATSPEC_DOSCS, "")' \
          '"CP936"'
    '';
  });
}
