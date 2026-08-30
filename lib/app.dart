import 'package:flutter/material.dart';

import 'package:airping/core/theme/app_theme.dart';
import 'package:airping/features/home/home_screen.dart';
import 'package:airping/features/auth/login/login_page.dart';
import 'package:airping/features/schedule/scheduler_page.dart';
import 'package:airping/features/timer/timer_page.dart';

class AirPingApp extends StatelessWidget {
  const AirPingApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AirPing',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginPage(),
        '/schedule': (context) => const SchedulerPage(),
        '/timer': (context) => const TimerPage(),
      },
    );
  }
}
