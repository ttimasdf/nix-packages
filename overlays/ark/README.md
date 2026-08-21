# KDE Ark overlay

This overlay contains local KDE Ark CLI/7z patches. The overlay is currently a development scaffold: its patch application is commented out in `default.nix`, so applying `overlays.ark` alone does not replace `pkgs.kdePackages.ark`. Uncomment the `kdePackages` override to enable the patches, then rebuild the affected package.

```nix
nixpkgs.overlays = [ inputs.known-rabbit-packages.overlays.ark ];
```

# How to Debug Ark

## Build with Debug Log

To enable debug logging, apply the following patch to `./patches` as `debug.patch`.

```diff
diff --git a/plugins/cli7zplugin/cliplugin.cpp b/plugins/cli7zplugin/cliplugin.cpp
index bd452873..2a501e32 100644
--- a/plugins/cli7zplugin/cliplugin.cpp
+++ b/plugins/cli7zplugin/cliplugin.cpp
@@ -222,6 +222,7 @@ bool CliPlugin::readListLine(const QString &line)
         break;

     case ParseStateEntryInformation:
+        qCDebug(ARK_LOG) << "ParseStateEntryInformation line:" << line;
         if (m_isFirstInformationEntry) {
             m_isFirstInformationEntry = false;
             m_currentArchiveEntry = new Archive::Entry(this);
@@ -309,11 +310,14 @@ bool CliPlugin::readListLine(const QString &line)
         } else if (line.length() == 0 || line.startsWith(QLatin1String("Block = ")) || line.startsWith(QLatin1String("Version = "))) {
             m_isFirstInformationEntry = true;
             if (!m_currentArchiveEntry->fullPath().isEmpty()) {
+                qCDebug(ARK_LOG) << "ParseStateEntryInformation emiting entry:" << m_currentArchiveEntry->fullPath();
                 Q_EMIT entry(m_currentArchiveEntry);
             } else {
                 delete m_currentArchiveEntry;
             }
             m_currentArchiveEntry = nullptr;
+        } else {
+            qCWarning(ARK_LOG) << "ParseStateEntryInformation unknown line:" << line;
         }
         break;
     }
```

Then rebuild your system or the `ark` package with this patch applied.

## Run Ark to Check Debug Output

### Qt Debug Output

```
QT_LOGGING_RULES="ark.*.debug=true" ark filesystem.squashfs
```

### 7zz Command Line Trace

```
strace -f -e execve -qq ark filesystem.squashfs
```
