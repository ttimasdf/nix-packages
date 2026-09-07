# WeMeet overlay context

## Problem

WeMeet `3.26.10.401` crashes on KDE Plasma Wayland with a reverse-PRIME
Intel/NVIDIA laptop when its in-meeting window is first created on an external
Xwayland output. The affected setup has an internal `eDP-1` display and a
vertically offset, rotated `HDMI-A-1` display.

The failure is in Tencent's bundled Qt 5.15.8, not in the display driver or in
nixpkgs' package wrapper. The important stack is:

```text
InMeetingMainWindow::event(QEvent::ScreenChangeInternal)
  QGraphicsDropShadowEffect::draw(QPainter *)
    QPainter::setWorldTransform(...)
```

The crash happens during construction and screen initialization. A meeting
window created on the internal display can subsequently be dragged to the
external display and remains stable.

There is a separate native-Wayland playback problem. With the normal launcher,
video decoding can succeed but EGL surface creation fails with
`EGL_BAD_ALLOC` (`eglCreateWindowSurface returned EGL_NO_SURFACE error:3003`).
That is related to the camera compatibility shim selecting an X11 EGL display
for `libxcast`, while playback is using a Wayland surface. It is not the cause
of the external-output Qt crash.

## How it was discovered

The following cases were compared:

1. Start `wemeet-xwayland`, keep the main window on `eDP-1`, join a meeting, and
   drag the initialized meeting window to `HDMI-A-1`: stable.
2. Move the main window to `HDMI-A-1` before joining, so the in-meeting window
   is constructed there: reproducible crash.
3. Change HDMI scaling, use `QT_SCREEN_SCALE_FACTORS`, force software Qt
   rendering, and use NVIDIA offload: no material change.
4. Reproduce with the Flathub build: the same bundled-Qt crash occurs without
   nixpkgs' preload libraries.
5. Inspect the video logs: HEVC decoding succeeds before the independent EGL
   `EGL_BAD_ALLOC` failure.

This establishes an initialization-time Qt screen-placement bug and separates
it from the video-rendering issue.

## Fix in this checkpoint

The overlay embeds Frida Gadget and loads [`frida_wemeet.js`](patch/frida_wemeet.js)
at process startup. The script observes the bundled `libQt5Widgets.so.5`, looks
up these exported C++ symbols by name, and replaces
`QGraphicsDropShadowEffect::draw(QPainter *)` with
`QGraphicsEffect::drawSource(QPainter *)`:

```text
_ZN25QGraphicsDropShadowEffect4drawEP8QPainter
_ZN15QGraphicsEffect10drawSourceEP8QPainter
```

This removes only the drop-shadow rendering path; the source widget and video
surfaces are still drawn. Symbol lookup and Frida's runtime hook avoid a
hard-coded file offset or an on-disk instruction patch. If the expected module
or symbols are absent, the script logs the mismatch and leaves WeMeet
unchanged.

The package also exposes `wemeet-wayland-playback`, an experimental launcher
that removes only `wemeet-camera-fix` before selecting the Wayland Qt platform.
It may restore playback but can regress the local camera preview.

## Usage and limitations

Opt into `known-rabbit-packages.overlays.wemeet` (or use `overlays.all`) and
launch the Xwayland variant for the most reliable current workaround:

```console
wemeet-xwayland
```

The hook has been verified to install at startup and the bundled Qt code is
left unchanged. Full meeting validation still needs to be repeated after each
Tencent release. The workaround intentionally trades Qt drop shadows for
stability and remains dependent on the bundled Qt symbols being exported. A
future native preload implementation may replace the Frida runtime while
preserving the same symbol-level behavior.
