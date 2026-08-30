import 'package:flutter/material.dart';

/// Full-screen transparent window content that renders the "paper plane" ping animation: a plane flies across the screen dragging a banner with the reminder/schedule/timer title.
///
/// This widget is meant to be the root widget of a SEPARATE always-on-top,
/// frameless, transparent window (spawned via desktop_multi_window), not part of the main AirPing window.
class PlaneOverlayWindow extends StatefulWidget {
  final String title;
  final VoidCallback onFinished;

  const PlaneOverlayWindow({
    super.key,
    required this.title,
    required this.onFinished,
  });

  @override
  State<PlaneOverlayWindow> createState() => _PlaneOverlayWindowState();
}

class _PlaneOverlayWindowState extends State<PlaneOverlayWindow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _xPosition;
  late final Animation<double> _bob; // subtle up/down bobbing

  static const int _flightDurationMs = 25000;
  static const double _planeWidth = 90;
  static const double _bannerWidth = 260;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _flightDurationMs),
    );

    // From fully off-screen left to fully off-screen right.
    // Actual pixel range is resolved at build time using MediaQuery, so here we animate a 0..1 progress and map it in build().
    _xPosition = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _bob = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalTravel = screenWidth + _planeWidth + _bannerWidth + 200;
    final startX = -(_planeWidth + _bannerWidth + 100);

    return Container(
      // Fully transparent background so only the plane + banner are visible,
      // letting whatever is behind the overlay window show through.
      color: const Color.fromARGB(255, 221, 220, 221),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final currentX = startX + (_xPosition.value * totalTravel);
          return Stack(
            children: [
              Positioned(
                left: currentX,
                top: 300 + _bob.value,
                child: _PlaneWithBanner(title: widget.title),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlaneWithBanner extends StatelessWidget {
  final String title;

  const _PlaneWithBanner({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Banner trails behind the plane
        Container(
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 221, 220, 221),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color.fromARGB(255, 46, 46, 46),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Image.asset('assets/icons/airplane_gendut.png', width: 60, height: 60),
      ],
    );
  }
}
