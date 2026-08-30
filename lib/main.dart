import 'dart:convert';
import 'package:airping/shared/services/scheduler_service.dart';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

import 'app.dart';
import 'package:airping/features/overlay/plane_overlay_window.dart';
import 'package:airping/features/overlay/bird_overlay_window.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // desktop_multi_window memanggil ulang main() untuk tiap window baru yang di-spawn lewat DesktopMultiWindow.createWindow(). Kalau args pertamanya 'multi_window', berarti ini bukan AirPing utama, tapi window overlay ping yang lagi mau ditampilin.
  // NOTE: window_manager SENGAJA gak dipakai di sini. Ada known
  // incompatibility antara window_manager & desktop_multi_window di Linux
  if (args.isNotEmpty && args.first == 'multi_window') {
    final windowId = int.parse(args[1]);
    final argument = args.length > 2
        ? jsonDecode(args[2]) as Map<String, dynamic>
        : <String, dynamic>{};

    runApp(_OverlayApp(windowId: windowId, argument: argument));
    return;
  }

  SchedulerService.instance.start();
  runApp(const AirPingApp());
}

class _OverlayApp extends StatelessWidget {
  final int windowId;
  final Map<String, dynamic> argument;

  const _OverlayApp({required this.windowId, required this.argument});

  @override
  Widget build(BuildContext context) {
    final pingStyle = argument['pingStyle'] as String? ?? 'paper_plane';
    final title = argument['title'] as String? ?? '';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 221, 220, 221),
        body: _buildOverlayForStyle(pingStyle, title),
      ),
    );
  }

  Widget _buildOverlayForStyle(String pingStyle, String title) {
    switch (pingStyle) {
      case 'paper_plane':
        return PlaneOverlayWindow(
          title: title,
          onFinished: () async {
            await WindowController.fromWindowId(windowId).hide();
          },
        );
      case 'bird':
        return BirdOverlayWindow(
          title: title,
          onFinished: () async {
            await WindowController.fromWindowId(windowId).hide();
          },
        );

      default:
        return PlaneOverlayWindow(
          title: title,
          onFinished: () async {
            await WindowController.fromWindowId(windowId).hide();
          },
        );
    }
  }
}
