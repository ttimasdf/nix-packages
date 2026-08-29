# Decode legacy Chinese archive names written by NLS-enabled Info-ZIP unzip.
_final: prev: {
  unzip-nls = (prev.unzip.override { enableNLS = true; }).overrideAttrs (oldAttrs: {
    pname = oldAttrs.pname + "-nls";

    postPatch = (oldAttrs.postPatch or "") + ''
      oldOem=$'inline void oem_intern(char *string)\n{'
      newOem=$'inline void oem_intern(char *string)\n{\n    if (G.pInfo->GPFIsUTF8)\n        return;'
      oldIso=$'inline void iso_intern(char *string)\n{'
      newIso=$'inline void iso_intern(char *string)\n{\n    if (G.pInfo->GPFIsUTF8)\n        return;'

      substituteInPlace unix/unix.c \
        --replace-fail \
          'natspec_get_charset_by_locale(NATSPEC_DOSCS, "")' \
          '"CP936"' \
        --replace-fail \
          'natspec_get_charset_by_locale(NATSPEC_WINCS, "")' \
          '"CP936"' \
        --replace-fail "$oldOem" "$newOem" \
        --replace-fail "$oldIso" "$newIso"
    '';
  });
}
