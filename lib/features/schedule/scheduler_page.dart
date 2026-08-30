import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:airping/shared/models/scheduled_event.dart';
import 'package:airping/shared/services/scheduled_event_repository.dart';
import 'package:airping/shared/services/scheduler_service.dart';

class SchedulerPage extends StatefulWidget {
  final ScheduledEvent? existingEvent;

  const SchedulerPage({super.key, this.existingEvent});

  @override
  State<SchedulerPage> createState() => _SchedulerPageState();
}

class _SchedulerPageState extends State<SchedulerPage> {
  late DateTime weekStartDate;
  late List<int> weekDates;
  late int selectedDate;
  late int selectedMonth;
  late int selectedYear;
  late DateTime startTime;
  late DateTime endTime;
  late final FixedExtentScrollController startHourController;
  late final FixedExtentScrollController startMinuteController;
  late final FixedExtentScrollController endHourController;
  late final FixedExtentScrollController endMinuteController;
  late final FixedExtentScrollController preReminderHoursController;
  late final FixedExtentScrollController preReminderMinutesController;
  late final FixedExtentScrollController preReminderSecondsController;
  bool hasPreReminder = false;
  bool repeatEnabled = false;
  int repeatInterval = 1;
  String repeatUnit = 'day';
  String selectedPingStyle = 'paper_plane';
  int preReminderHours = 1;
  int preReminderMinutes = 0;
  int preReminderSeconds = 0;
  final titleController = TextEditingController();
  final agendaController = TextEditingController();
  final repository = const ScheduledEventRepository();

  final weekDaysLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  void _selectPingStyle(String style) {
    setState(() {
      selectedPingStyle = style;
    });
  }

  @override
  void initState() {
    super.initState();

    final event = widget.existingEvent;

    if (event != null) {
      titleController.text = event.title;
      agendaController.text = event.agenda;

      selectedDate = event.startsAt.day;
      selectedMonth = event.startsAt.month;
      selectedYear = event.startsAt.year;

      startTime = event.startsAt;
      endTime = event.endsAt;

      selectedPingStyle = event.pingStyle;
      hasPreReminder = event.hasPreReminder;

      preReminderHours = event.preReminderHours;
      preReminderMinutes = event.preReminderMinutes;
      preReminderSeconds = event.preReminderSeconds;

      repeatEnabled = event.repeatEnabled;
      repeatInterval = event.repeatInterval;
      repeatUnit = event.repeatUnit;

      weekStartDate = event.startsAt.subtract(
        Duration(days: event.startsAt.weekday % 7),
      );

      _generateWeekDates();
    } else {
      _initializeWeekDates();
    }

    preReminderHoursController = FixedExtentScrollController(
      initialItem: preReminderHours,
    );
    preReminderMinutesController = FixedExtentScrollController(
      initialItem: preReminderMinutes,
    );
    preReminderSecondsController = FixedExtentScrollController(
      initialItem: preReminderSeconds,
    );

    startHourController = FixedExtentScrollController(
      initialItem: startTime.hour,
    );
    startMinuteController = FixedExtentScrollController(
      initialItem: startTime.minute,
    );
    endHourController = FixedExtentScrollController(initialItem: endTime.hour);
    endMinuteController = FixedExtentScrollController(
      initialItem: endTime.minute,
    );
  }

  void _initializeWeekDates() {
    final now = DateTime.now();
    selectedDate = now.day;
    selectedMonth = now.month;
    selectedYear = now.year;
    startTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    endTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);

    weekStartDate = now.subtract(
      Duration(days: now.weekday % 7),
    ); // Sunday of week containing July 11
    _generateWeekDates();
  }

  void _generateWeekDates() {
    weekDates = [];
    for (int i = 0; i < 7; i++) {
      weekDates.add(weekStartDate.add(Duration(days: i)).day);
    }
  }

  void _previousWeek() {
    setState(() {
      weekStartDate = weekStartDate.subtract(const Duration(days: 7));
      selectedMonth = weekStartDate.month;
      selectedYear = weekStartDate.year;
      _generateWeekDates();
      selectedDate = weekDates[0];
      _updateTimeForSelectedDate();
    });
  }

  void _nextWeek() {
    setState(() {
      weekStartDate = weekStartDate.add(const Duration(days: 7));
      selectedMonth = weekStartDate.month;
      selectedYear = weekStartDate.year;
      _generateWeekDates();
      selectedDate = weekDates[0];
      _updateTimeForSelectedDate();
    });
  }

  void _updateTimeForSelectedDate() {
    startTime = DateTime(
      selectedYear,
      selectedMonth,
      selectedDate,
      startTime.hour,
      startTime.minute,
    );
    endTime = DateTime(
      selectedYear,
      selectedMonth,
      selectedDate,
      endTime.hour,
      endTime.minute,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    agendaController.dispose();
    preReminderHoursController.dispose();
    preReminderMinutesController.dispose();
    preReminderSecondsController.dispose();
    startHourController.dispose();
    startMinuteController.dispose();
    endHourController.dispose();
    endMinuteController.dispose();
    super.dispose();
  }

  void _showMonthYearPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        int tempMonth = selectedMonth;
        int tempYear = selectedYear;
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Select Month & Year',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: tempMonth - 1,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (int index) {
                          tempMonth = index + 1;
                        },
                        children: List<Widget>.generate(
                          12,
                          (int index) => Center(child: Text(monthNames[index])),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: tempYear - 2020,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (int index) {
                          tempYear = 2020 + index;
                        },
                        children: List<Widget>.generate(
                          20,
                          (int index) =>
                              Center(child: Text((2020 + index).toString())),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                child: const Text('Done'),
                onPressed: () {
                  setState(() {
                    selectedMonth = tempMonth;
                    selectedYear = tempYear;
                    weekStartDate = DateTime(selectedYear, selectedMonth, 1);
                    _generateWeekDates();
                    selectedDate = weekDates[0];
                    _updateTimeForSelectedDate();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // void _showRepeatReminderPicker() {
  //   showDialog(
  //     context: context,
  //     barrierColor: Colors.black12,
  //     builder: (context) {
  //       final intervalController = TextEditingController(
  //         text: repeatInterval.toString(),
  //       );

  //       String tempUnit = repeatUnit;
  //       bool tempEnabled = repeatEnabled;

  //       return StatefulBuilder(
  //         builder: (context, setModalState) {
  //           return AlertDialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(18),
  //             ),
  //             title: const Text(
  //               'Repeat Reminder',
  //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //             ),

  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 _buildRepeatOption(
  //                   label: 'hour',
  //                   unit: 'hour',
  //                   tempUnit: tempUnit,
  //                   tempEnabled: tempEnabled,
  //                   intervalController: intervalController,
  //                   onSelected: () {
  //                     setModalState(() {
  //                       tempEnabled = true;
  //                       tempUnit = 'hour';
  //                     });
  //                   },
  //                 ),

  //                 _buildRepeatOption(
  //                   label: 'day',
  //                   unit: 'day',
  //                   tempUnit: tempUnit,
  //                   tempEnabled: tempEnabled,
  //                   intervalController: intervalController,
  //                   onSelected: () {
  //                     setModalState(() {
  //                       tempEnabled = true;
  //                       tempUnit = 'day';
  //                     });
  //                   },
  //                 ),

  //                 _buildRepeatOption(
  //                   label: 'week',
  //                   unit: 'week',
  //                   tempUnit: tempUnit,
  //                   tempEnabled: tempEnabled,
  //                   intervalController: intervalController,
  //                   onSelected: () {
  //                     setModalState(() {
  //                       tempEnabled = true;
  //                       tempUnit = 'week';
  //                     });
  //                   },
  //                 ),

  //                 _buildRepeatOption(
  //                   label: 'month',
  //                   unit: 'month',
  //                   tempUnit: tempUnit,
  //                   tempEnabled: tempEnabled,
  //                   intervalController: intervalController,
  //                   onSelected: () {
  //                     setModalState(() {
  //                       tempEnabled = true;
  //                       tempUnit = 'month';
  //                     });
  //                   },
  //                 ),

  //                 _buildRepeatOption(
  //                   label: 'year',
  //                   unit: 'year',
  //                   tempUnit: tempUnit,
  //                   tempEnabled: tempEnabled,
  //                   intervalController: intervalController,
  //                   onSelected: () {
  //                     setModalState(() {
  //                       tempEnabled = true;
  //                       tempUnit = 'year';
  //                     });
  //                   },
  //                 ),
  //               ],
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   setState(() {
  //                     repeatEnabled = false;
  //                   });

  //                   intervalController.dispose();
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text('Disable'),
  //               ),
  //               TextButton(
  //                 onPressed: () {
  //                   final interval = int.tryParse(intervalController.text) ?? 1;

  //                   setState(() {
  //                     repeatEnabled = tempEnabled;
  //                     repeatInterval = interval < 1 ? 1 : interval;
  //                     repeatUnit = tempUnit;
  //                   });

  //                   intervalController.dispose();
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text('Done'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // Widget _buildRepeatOption({
  //   required String label,
  //   required String unit,
  //   required String tempUnit,
  //   required bool tempEnabled,
  //   required TextEditingController intervalController,
  //   required VoidCallback onSelected,
  // }) {
  //   final isSelected = tempEnabled && tempUnit == unit;

  //   return GestureDetector(
  //     onTap: onSelected,
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 6),
  //       child: Row(
  //         children: [
  //           Icon(
  //             isSelected ? Icons.check_box : Icons.check_box_outline_blank,
  //             size: 24,
  //           ),

  //           const SizedBox(width: 12),

  //           const Text('Every', style: TextStyle(fontSize: 17)),

  //           const SizedBox(width: 8),

  //           SizedBox(
  //             width: 55,
  //             height: 38,
  //             child: TextField(
  //               controller: intervalController,
  //               keyboardType: TextInputType.number,
  //               textAlign: TextAlign.center,
  //               decoration: const InputDecoration(
  //                 border: OutlineInputBorder(),
  //                 contentPadding: EdgeInsets.symmetric(
  //                   horizontal: 6,
  //                   vertical: 4,
  //                 ),
  //               ),
  //             ),
  //           ),

  //           const SizedBox(width: 8),

  //           Text(label, style: const TextStyle(fontSize: 17)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Future<void> _saveEvent() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Judul event wajib diisi.')));
      return;
    }

    try {
      final existingEvent = widget.existingEvent;

      if (existingEvent == null) {
        await repository.insert(
          ScheduledEvent(
            title: title,
            agenda: agendaController.text.trim(),
            startsAt: startTime,
            endsAt: endTime,
            pingStyle: selectedPingStyle,
            hasPreReminder: hasPreReminder,
            preReminderHours: preReminderHours,
            preReminderMinutes: preReminderMinutes,
            preReminderSeconds: preReminderSeconds,
            triggered: false,
            repeatEnabled: repeatEnabled,
            repeatInterval: repeatInterval,
            repeatUnit: repeatUnit,
          ),
        );
      } else {
        await repository.update(
          ScheduledEvent(
            id: existingEvent.id,
            title: title,
            agenda: agendaController.text.trim(),
            startsAt: startTime,
            endsAt: endTime,
            pingStyle: selectedPingStyle,
            hasPreReminder: hasPreReminder,
            preReminderHours: preReminderHours,
            preReminderMinutes: preReminderMinutes,
            preReminderSeconds: preReminderSeconds,
            triggered: existingEvent.triggered,
            repeatEnabled: repeatEnabled,
            repeatInterval: repeatInterval,
            repeatUnit: repeatUnit,
          ),
        );
      }

      if (!mounted) return;
      SchedulerService.instance.refresh();
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
    }
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
                icon: const Icon(Icons.arrow_back, size: 24),
                onPressed: () => Navigator.pop(context),
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
                onPressed: _saveEvent,
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.only(top: 90, bottom: 20),
              child: SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constrains) {
                    final isSmallScreen = constrains.maxWidth < 800;

                    if (isSmallScreen) {
                      return Column(
                        children: [
                          _buildLeftSection(),
                          const SizedBox(height: 35),
                          _buildRightSection(),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: _buildLeftSection(),
                        ),
                        const SizedBox(width: 64),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: _buildRightSection(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 100),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeColumn(
                'Start',
                startHourController,
                24,
                startTime.hour,
                (index) {
                  setState(() {
                    startTime = DateTime(
                      selectedYear,
                      selectedMonth,
                      selectedDate,
                      index,
                      startTime.minute,
                    );
                  });
                },
              ),

              _buildTimeSeparator(),

              _buildTimeColumn(
                'Minutes',
                startMinuteController,
                60,
                startTime.minute,
                (index) {
                  setState(() {
                    startTime = DateTime(
                      selectedYear,
                      selectedMonth,
                      selectedDate,
                      startTime.hour,
                      index,
                    );
                  });
                },
              ),

              const SizedBox(width: 35),

              const Text('To', style: _normalStyle),

              const SizedBox(width: 35),

              _buildTimeColumn('End', endHourController, 24, endTime.hour, (
                index,
              ) {
                setState(() {
                  endTime = DateTime(
                    selectedYear,
                    selectedMonth,
                    selectedDate,
                    index,
                    endTime.minute,
                  );
                });
              }),

              _buildTimeSeparator(),

              _buildTimeColumn(
                'Minutes',
                endMinuteController,
                60,
                endTime.minute,
                (index) {
                  setState(() {
                    endTime = DateTime(
                      selectedYear,
                      selectedMonth,
                      selectedDate,
                      endTime.hour,
                      index,
                    );
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 28),

          _textField(
            controller: titleController,
            hintText: 'Title',
            height: 55,
            maxLines: 80,
          ),

          const SizedBox(height: 20),

          _textField(
            controller: agendaController,
            hintText: 'Agenda',
            height: 400,
            maxLines: 400,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(
    String label,
    FixedExtentScrollController controller,
    int itemCount,
    int currentValue,
    ValueChanged<int> onChanged,
  ) {
    return Column(
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          width: 70,
          child: CupertinoPicker(
            scrollController: controller,
            itemExtent: 40,
            looping: true,
            onSelectedItemChanged: onChanged,
            children: List<Widget>.generate(itemCount, (index) {
              final isSelected = index == currentValue;

              return Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: isSelected
                      ? const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        )
                      : const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.black26,
                        ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: Center(child: Text(':', style: _separatorStyle)),
        ),
      ],
    );
  }

  Widget _buildRightSection() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bulan, tahun, dan ping style
          Row(
            children: [
              GestureDetector(
                onTap: _showMonthYearPicker,
                child: Row(
                  children: [
                    Text(monthNames[selectedMonth - 1], style: _headerStyle),
                    const Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: _showMonthYearPicker,
                child: Row(
                  children: [
                    Text(selectedYear.toString(), style: _headerStyle),
                    const Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ),
              ),
              const SizedBox(width: 130),
              const Text('Ping Style', style: _headerStyle),
              const SizedBox(width: 22),
              GestureDetector(
                onTap: () => _selectPingStyle('paper_plane'),
                child: Image.asset(
                  'assets/icons/fontisto_paper-plane.png',
                  width: 25,
                  height: 20,
                  opacity: selectedPingStyle == 'paper_plane'
                      ? const AlwaysStoppedAnimation(1.0)
                      : const AlwaysStoppedAnimation(0.5),
                ),
              ),
              const SizedBox(width: 22),
              GestureDetector(
                onTap: () => _selectPingStyle('bird'),
                child: Image.asset(
                  'assets/icons/noto_bird.png',
                  width: 35,
                  height: 35,
                  opacity: selectedPingStyle == 'bird'
                      ? const AlwaysStoppedAnimation(1.0)
                      : const AlwaysStoppedAnimation(0.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          // Nama Hari
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDaysLabels
                .map(
                  (day) => Text(
                    day,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 10),

          // tanggal (dinamis berdasarkan weekStartDate)
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 235, 235, 235),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDates.map((date) {
                final isSelected = selectedDate == date;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                      _updateTimeForSelectedDate();
                    });
                  },
                  child: Text(
                    date.toString(),
                    style: TextStyle(
                      fontSize: 21,
                      fontFamily: 'serif',
                      decoration: isSelected ? TextDecoration.underline : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Navigasi minggu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _previousWeek,
                child: const _WeekButton(
                  icon: Icons.chevron_left,
                  label: 'Previous\nWeek',
                ),
              ),
              GestureDetector(
                onTap: _nextWeek,
                child: const _WeekButton(
                  icon: Icons.chevron_right,
                  label: 'Next\nWeek',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // GestureDetector(
          //   onTap: _showRepeatReminderPicker,
          //   child: _grayBox(
          //     text: repeatEnabled
          //         ? 'Every $repeatInterval $repeatUnit'
          //         : 'Repeat Reminder?',
          //     height: 46,
          //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 9),
          //   ),
          // ),
          const SizedBox(height: 20),

          // Checkbox reminder
          GestureDetector(
            onTap: () {
              setState(() {
                hasPreReminder = !hasPreReminder;
              });
            },
            child: Row(
              children: [
                Icon(
                  hasPreReminder ? Icons.check_box : Icons.check_box_outlined,
                  size: 25,
                ),
                const SizedBox(width: 15),
                const Text(
                  'Create reminder before event?',
                  style: TextStyle(fontSize: 18, fontFamily: 'serif'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Countdown reminder (only active if hasPreReminder is true)
          if (hasPreReminder) ...[
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDurationColumn(
                  'Hours',
                  preReminderHoursController,
                  24,
                  preReminderHours,
                  (index) {
                    setState(() => preReminderHours = index);
                  },
                ),
                _buildDurationSeparator(),
                _buildDurationColumn(
                  'Minutes',
                  preReminderMinutesController,
                  60,
                  preReminderMinutes,
                  (index) {
                    setState(() => preReminderMinutes = index);
                  },
                ),
                _buildDurationSeparator(),
                _buildDurationColumn(
                  'Seconds',
                  preReminderSecondsController,
                  60,
                  preReminderSeconds,
                  (index) {
                    setState(() => preReminderSeconds = index);
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _grayBox({
    required String text,
    required double height,
    EdgeInsets padding = const EdgeInsets.all(28),
  }) {
    return Container(
      width: double.infinity,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 235, 235, 235),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontFamily: 'serif'),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    required double height,
    int maxLines = 1,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 23, fontFamily: 'serif'),
      ),
    );
  }
}

class _WeekButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WeekButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 38, color: Colors.black54),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}

Widget _buildDurationColumn(
  String label,
  FixedExtentScrollController controller,
  int itemCount,
  int currentValue,
  ValueChanged<int> onChanged,
) {
  return Column(
    children: [
      Text(label, style: const TextStyle(color: Colors.black54)),
      const SizedBox(height: 12),
      SizedBox(
        height: 130,
        width: 70,
        child: CupertinoPicker(
          scrollController: controller,
          itemExtent: 40,
          looping: true,
          onSelectedItemChanged: onChanged,
          children: List<Widget>.generate(itemCount, (index) {
            final isSelected = index == currentValue;
            return Center(
              child: Text(
                index.toString().padLeft(2, '0'),
                style: isSelected
                    ? const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      )
                    : const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black26,
                      ),
              ),
            );
          }),
        ),
      ),
    ],
  );
}

Widget _buildDurationSeparator() {
  return Column(
    children: [
      const SizedBox(height: 20),
      const SizedBox(height: 12),
      const SizedBox(
        height: 130,
        child: Center(child: Text(':', style: TextStyle(fontSize: 28))),
      ),
    ],
  );
}

const _headerStyle = TextStyle(fontSize: 18, fontFamily: 'serif');

const _normalStyle = TextStyle(fontSize: 16, fontFamily: 'serif');

const _labelStyle = TextStyle(fontSize: 20, color: Colors.black54);

const _separatorStyle = TextStyle(fontSize: 38, fontWeight: FontWeight.bold);
