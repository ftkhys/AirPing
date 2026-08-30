import 'package:flutter/material.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  Widget _deliveryOption(String label, String assetPath) {
    return Container(
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset(assetPath, width: 24, height: 24),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Back button
            Positioned(
              left: 20,
              top: 20,
              child: IconButton(
                icon: Icon(Icons.arrow_back, size: 24),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // Save button
            Positioned(
              right: 20,
              top: 20,
              child: IconButton(
                icon: Image.asset(
                  'assets/icons/charm_tick.png',
                  width: 24,
                  height: 24,
                ),
                onPressed: () {},
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Container(
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.centerLeft,
                    child: const Text('Title', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(height: 20),

                  // Time and repeat reminder
                  Row(
                    children: [
                      // Time
                      Container(
                        width: 150,
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          '10.00 AM',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Repeat reminder
                      Expanded(
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Repeat Reminder?',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calendar
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Calendar',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Delivery Style
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Delivery Style',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 10),

                            _deliveryOption(
                              'Paper Plane',
                              'assets/icons/fontisto_paper-plane.png',
                            ),

                            const SizedBox(height: 10),
                            _deliveryOption(
                              'Bird Messenger',
                              'assets/icons/noto_bird.png',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
