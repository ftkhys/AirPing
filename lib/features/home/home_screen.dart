import 'package:flutter/material.dart';
import 'package:airping/shared/services/scheduled_event_repository.dart';
import 'package:airping/shared/services/timer_repository.dart';
import 'package:airping/shared/models/calendar_item.dart';
import 'package:airping/features/home/all_scheduler_page.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<CalendarItem>> todayItems;

  @override
  void initState() {
    super.initState();
    todayItems = _loadTodayItems();
  }

  Future<List<CalendarItem>> _loadTodayItems() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final events = await const ScheduledEventRepository().getByDate(today);
    final timers = await const TimerRepository().getByDate(today);

    final items = <CalendarItem>[
      ...events.map(CalendarItem.fromEvent),
      ...timers.map(CalendarItem.fromTimer),
    ]..sort((a, b) => a.sortTime.compareTo(b.sortTime));

    return items;
  }

  Future<void> _refresh() async {
    setState(() {
      todayItems = _loadTodayItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Bar
              Row(
                children: [
                  SizedBox(width: 15),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllSchedulePage(),
                        ),
                      );

                      _refresh();
                    },
                    child: Image.asset(
                      'assets/icons/Blue Calendar.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                  Spacer(),
                ],
              ),

              SizedBox(height: 40),

              // Main Content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Panel
                  Padding(
                    padding: const EdgeInsets.only(left: 200),
                    child: SizedBox(
                      width: 500,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo
                          Image.asset('assets/images/Air Ping.png', width: 300),

                          SizedBox(height: 32),

                          Text(
                            "Today's Ping:",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 16),

                          // Today's Ping List
                          FutureBuilder<List<CalendarItem>>(
                            future: todayItems,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }

                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }

                              final events = snapshot.data ?? [];
                              final visibleEvents = events.take(5).toList();
                              // final hasMore = events.length > 5;

                              if (events.isEmpty) {
                                return Text(
                                  'No upcoming events',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...visibleEvents.map(
                                    (event) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      child: Text(
                                        '• ${event.title}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),

                                  // if (hasMore)
                                  //   Transform.translate(
                                  //     offset: const Offset(200, -70),
                                  //     child: GestureDetector(
                                  //       onTap: () async {
                                  //         await Navigator.push(
                                  //           context,
                                  //           MaterialPageRoute(
                                  //             builder: (context) =>
                                  //                 const AllSchedulePage(),
                                  //           ),
                                  //         );

                                  //         _refresh();
                                  //       },
                                  //       child: Image.asset(
                                  //         'assets/icons/pointer.png',
                                  //         width: 40,
                                  //         height: 40,
                                  //       ),
                                  //     ),
                                  //   ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 100),

                  // Right Panel
                  Padding(
                    padding: const EdgeInsets.only(top: 50, left: 100),
                    child: SizedBox(
                      width: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/schedule',
                              );

                              if (result == true) {
                                await _refresh();

                                if (!mounted) return;

                                _showSuccessDialog(
                                  'Your schedule has been created!',
                                );
                              }
                            },

                            child: Text(
                              'Scheduler',
                              style: GoogleFonts.caveat(
                                fontSize: 50,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/timer',
                              );

                              if (result == true) {
                                await _refresh();

                                if (!mounted) return;

                                _showSuccessDialog(
                                  'Your timer has been created!',
                                );
                              }
                            },
                            child: Text(
                              'Focus Timer',
                              style: GoogleFonts.caveat(
                                fontSize: 50,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          SizedBox(height: 32),

                          Image.asset(
                            'assets/icons/Paperplane.png',
                            width: 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black12,
      builder: (context) {
        Future.delayed(const Duration(seconds: 1), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15),
          ),
        );
      },
    );
  }
}
