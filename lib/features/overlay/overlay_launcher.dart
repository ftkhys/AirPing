import 'dart:convert';
import 'dart:ui';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:screen_retriever/screen_retriever.dart';

/// Spawns a new, separate OS window sized to cover the whole primary display, positioned at (0,0), frameless, transparent, and always on top. The window's Flutter content is decided in main.dart by checking the 'args' passed to runApp for a secondary window (see main.dart wiring instructions).

class OverlayLauncher {
  static Future<void> showPing({
    required String pingStyle, // 'paper_plane' || 'bird' | 'little buddy'
    required String title,
  }) async {
    final display = await screenRetriever.getPrimaryDisplay();
    final screenSize = display.size;

    final window = await DesktopMultiWindow.createWindow(
      jsonEncode({
        'type': 'ping_overlay',
        'pingStyle': pingStyle,
        'title': title,
      }),
    );

    // Cover the whole screen so the animation has room to travel edge to edge.
    final overlayFrame = Rect.fromLTWH(
      0,
      0,
      screenSize.width - 2,
      screenSize.height - 2,
    );

    await window.setFrame(overlayFrame);
    await window.setTitle('airping-overlay');

    // Note: click-through (setIgnoreMouseEvents) is not set here.
    // window_manager's setIgnoreMouseEvents affects "the current window",
    // i.e it must be called from INSIDE the overlay window's own entrypoint (its own Flutter engine instance), not remotely via this
    // WindowController. See main.dart's secondary-window branch.
    await window.show();
  }
}
