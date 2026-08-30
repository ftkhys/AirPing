import 'package:flutter/material.dart';

/// Full-screen transparent window content that renders the "paper plane" ping animation: a plane flies across the screen dragging a banner with the reminder/schedule/timer title.
///
/// This widget is meant to be the root widget of a SEPARATE always-on-top,
/// frameless, transparent window (spawned via desktop_multi_window), not part of the main AirPing window.
class BuddyOverlayWindow extends StatefulWidget {
  final String title;
  final VoidCallback onFinished;

  const BuddyOverlayWindow({
    super.key,
    required this.title,
    required this.onFinished,
  });

  @override
  State<BuddyOverlayWindow> createState() => _BuddyOverlayWindowState();
}

class _BuddyOverlayWindowState extends State<BuddyOverlayWindow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _buddyPop;
  late final Animation<double> _wave;

  static const int _animationDurationMs = 5000;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _animationDurationMs),
    );

    // From fully off-screen left to fully off-screen right.
    // Actual pixel range is resolved at build time using MediaQuery, so here we animate a 0..1 progress and map it in build().
    _buddyPop = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 25,
      ),

      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),

      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_controller);

    _wave = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.25), weight: 10),
      TweenSequenceItem(tween: Tween(begin: -0.25, end: 0.25), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.25, end: -0.25), weight: 10),
      TweenSequenceItem(tween: Tween(begin: -0.25, end: 0.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 60),
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
    return Container(
      // Fully transparent background so only the plane + banner are visible,
      // letting whatever is behind the overlay window show through.
      color: const Color.fromARGB(255, 221, 220, 221),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Center(
            child: SizedBox(
              width: 500,
              height: 500,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: 65,
                    child: Transform.translate(
                      offset: Offset(0, 100 * (1 - _buddyPop.value)),
                      child: _LittleBuddy(wave: _wave.value),
                    ),
                  ),

                  Positioned(top: 110, child: _WhiteBoard(title: widget.title)),

                  const Positioned(top: 85, child: _BuddyHand()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WhiteBoard extends StatelessWidget {
  final String title;

  const _WhiteBoard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      height: 250,
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(70, 0, 0, 0),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color.fromARGB(255, 46, 46, 46),
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}

class _BuddyHand extends StatelessWidget {
  const _BuddyHand();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/streamline-emojis_girl-2.png',
      width: 55,
      height: 55,
    );
  }
}

class _LittleBuddy extends StatelessWidget {
  final double wave;

  const _LittleBuddy({required this.wave});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: wave,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/streamline-emojis_girl-2.png',
            width: 120,
            height: 120,
          ),
        ],
      ),
    );
  }
}
