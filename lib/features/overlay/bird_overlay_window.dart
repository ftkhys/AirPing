import 'package:flutter/material.dart';

/// Full-screen transparent window content that renders the "paper plane" ping animation: a plane flies across the screen dragging a banner with the reminder/schedule/timer title.
///
/// This widget is meant to be the root widget of a SEPARATE always-on-top,
/// frameless, transparent window (spawned via desktop_multi_window), not part of the main AirPing window.
class BirdOverlayWindow extends StatefulWidget {
  final String title;
  final VoidCallback onFinished;

  const BirdOverlayWindow({
    super.key,
    required this.title,
    required this.onFinished,
  });

  @override
  State<BirdOverlayWindow> createState() => _BirdOverlayWindowState();
}

class _BirdOverlayWindowState extends State<BirdOverlayWindow>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _xPosition;
  late final AnimationController _flapController;

  static const int _flightDurationMs = 35000;
  static const double _birdWidth = 90;
  static const double _bannerWidth = 260;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _flightDurationMs),
    );

    _flapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    )..repeat(reverse: true);

    // From fully off-screen left to fully off-screen right.
    // Actual pixel range is resolved at build time using MediaQuery, so here we animate a 0..1 progress and map it in build().
    _xPosition = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

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
    _flapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final totalTravelX = screenWidth + _birdWidth + _bannerWidth + 100;
    final totalTravelY = screenHeight;

    final startX = screenWidth + 100;
    final startY = screenHeight - 100;

    return Container(
      // Fully transparent background so only the plane + banner are visible,
      // letting whatever is behind the overlay window show through.
      color: const Color.fromARGB(255, 221, 220, 221),
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _flapController]),
        builder: (context, _) {
          final progress = _xPosition.value;

          final wingUp = _flapController.value > 0.5;

          final currentX = startX - (progress * totalTravelX);
          final currentY = startY - (progress * totalTravelY);

          return Stack(
            children: [
              Positioned(
                left: currentX,
                top: currentY,
                child: _BirdWithBanner(title: widget.title, wingUp: wingUp),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BirdWithBanner extends StatelessWidget {
  final String title;
  final bool wingUp;

  const _BirdWithBanner({required this.title, required this.wingUp});

  @override
  Widget build(BuildContext context) {
    final imagePath = wingUp
        ? 'assets/images/Burungsayapkeatas.png'
        : 'assets/images/Burungkincup.png';

    final imageSize = wingUp ? 120.0 : 120.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.flip(
          flipX: true,
          child: Image.asset(imagePath, width: imageSize, height: imageSize),
        ),

        const SizedBox(height: 6),
        // Banner trails behind the plane
        Container(
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 221, 220, 221),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color.fromARGB(255, 46, 46, 46),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
