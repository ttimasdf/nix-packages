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

## Fix

The current implementation is a small native `LD_PRELOAD` library,
[`wemeet-drop-shadow-fix.c`](wemeet-drop-shadow-fix.c). A normal preload
function override is insufficient here: `QGraphicsDropShadowEffect::draw()` is
a C++ virtual method, and the bundled Qt vtable contains a direct pointer to
its implementation rather than a dynamically interposed call.

At library construction time, the shim:

1. obtains the already-loaded bundled `libQt5Widgets.so.5` with `RTLD_NOLOAD`;
2. resolves the Qt `Qt_5` symbols for the drop-shadow vtable, `draw()`, and
   `QGraphicsEffect::drawSource()`;
3. verifies that all symbols belong to WeMeet's Qt library;
4. uses the vtable symbol's ELF size as a bounded scan range and locates the
   unique entry pointing to `draw()`;
5. temporarily makes that vtable page writable, replaces the pointer with
   `drawSource()`, and restores read-only protection.

The vtable slot is discovered from symbols at runtime; no file offset, machine
instruction sequence, or fixed vtable index is embedded. Missing symbols,
ambiguous matches, unexpected libraries, or protection failures cause the shim
to leave the process unchanged. The workaround removes Qt drop shadows but
continues to draw the source widget and video surfaces.

The first working version used a Frida Gadget hook. The native library replaces
that runtime dependency while retaining the same symbol-level behavior and
supporting both `x86_64-linux` and `aarch64-linux` without architecture-specific
instruction patching.

## Launchers and limitations

The overlay adds the native shim to the `wemeet` and `wemeet-xwayland` launchers.
The experimental `wemeet-wayland-playback` launcher remains available; it
removes only `wemeet-camera-fix` before selecting the Wayland Qt platform. That
may restore playback but can regress the local camera preview.

Use the Xwayland launcher for the most reliable current workaround:

```console
wemeet-xwayland
```

The native hook has been compiled and verified to install against the current
bundled Qt. Full meeting validation should be repeated after each Tencent
release. It intentionally fails closed if Tencent changes the Qt major version,
removes the exported ABI symbols, changes the vtable representation, or loads
Qt in a way that occurs after the constructor hook runs.
