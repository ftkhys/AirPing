import 'package:airping/features/schedule/scheduler_page.dart';
import 'package:airping/features/timer/timer_page.dart';
import 'package:flutter/material.dart';

import 'package:airping/shared/models/calendar_item.dart';
import 'package:airping/shared/services/scheduled_event_repository.dart';
import 'package:airping/shared/services/timer_repository.dart';

class AllSchedulePage extends StatefulWidget {
  const AllSchedulePage({super.key});

  @override
  State<AllSchedulePage> createState() => _AllSchedulePageState();
}

class _AllSchedulePageState extends State<AllSchedulePage> {
  final eventRepo = const ScheduledEventRepository();
  final timerRepo = const TimerRepository();

  late DateTime displayedMonth;
  late DateTime selectedDate;
  late List<DateTime> gridDays;
  Map<String, int> countPerDay = {};
  List<CalendarItem> selectedItems = [];
  bool isLoading = true;

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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    displayedMonth = DateTime(now.year, now.month, 1);
    selectedDate = DateTime(now.year, now.month, now.day);
    _buildGridDays();
    _loadData();
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void _buildGridDays() {
    // cari minggu pertama yang muncul di grid
    final firstOfMonth = displayedMonth;
    final gridStart = firstOfMonth.subtract(
      Duration(days: firstOfMonth.weekday % 7),
    );
    gridDays = List.generate(42, (i) => gridStart.add(Duration(days: i)));
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    final rangeStart = gridDays.first;
    final rangeEnd = gridDays.last.add(const Duration(days: 1));

    final events = await eventRepo.getByDateRange(rangeStart, rangeEnd);
    final timers = await timerRepo.getByDateRange(rangeStart, rangeEnd);

    final newCountPerDay = <String, int>{};

    for (final event in events) {
      final startDay = DateTime(
        event.startsAt.year,
        event.startsAt.month,
        event.startsAt.day,
      );
      final endDay = DateTime(
        event.endsAt.year,
        event.endsAt.month,
        event.endsAt.day,
      );
      for (
        var day = startDay;
        !day.isAfter(endDay);
        day = day.add(const Duration(days: 1))
      ) {
        final key = _dateKey(day);
        newCountPerDay[key] = (newCountPerDay[key] ?? 0) + 1;
      }
    }

    for (final timer in timers) {
      final day = DateTime(
        timer.createdAt.year,
        timer.createdAt.month,
        timer.createdAt.day,
      );
      final key = _dateKey(day);
      newCountPerDay[key] = (newCountPerDay[key] ?? 0) + 1;
    }

    if (!mounted) return;
    setState(() {
      countPerDay = newCountPerDay;
      isLoading = false;
    });

    _loadSelectedDateItems();
  }

  Future<void> _loadSelectedDateItems() async {
    final events = await eventRepo.getByDate(selectedDate);
    final timers = await timerRepo.getByDate(selectedDate);

    final items = <CalendarItem>[
      ...events.map(CalendarItem.fromEvent),
      ...timers.map(CalendarItem.fromTimer),
    ]..sort((a, b) => a.sortTime.compareTo(b.sortTime));

    if (!mounted) return;
    setState(() => selectedItems = items);
  }

  void _nextMonth() {
    setState(() {
      displayedMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month + 1,
        1,
      );
      _buildGridDays();
    });
    _loadData();
  }

  void _previousMonth() {
    setState(() {
      displayedMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month - 1,
        1,
      );
      _buildGridDays();
    });
    _loadData();
  }

  void _selectDate(DateTime date) {
    setState(() => selectedDate = date);
    _loadSelectedDateItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: _buildCalendar(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: const Color(0xff9b6dc9),
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                child: _buildSelectedDatePanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            const Spacer(),
          ],
        ),
        Row(
          children: [
            Text(
              monthNames[displayedMonth.month - 1],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Text(
              displayedMonth.year.toString(),
              style: const TextStyle(fontSize: 22, color: Colors.black45),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousMonth,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _nextMonth,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: weekDaysLabels
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            itemCount: gridDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemBuilder: (context, index) => _buildDayCell(gridDays[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isCurrentMonth = date.month == displayedMonth.month;
    final isSelected =
        date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
    final count = countPerDay[_dateKey(date)] ?? 0;
    final dotCount = count > 5 ? 5 : count;

    return GestureDetector(
      onTap: () => _selectDate(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade300 : null,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isCurrentMonth ? Colors.black : Colors.black26,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (dotCount > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  dotCount,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: isCurrentMonth ? Colors.black45 : Colors.black26,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDatePanel() {
    final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final formattedDate =
        '${weekdayNames[selectedDate.weekday - 1]}, ${selectedDate.day.toString().padLeft(2, '0')} ${monthNames[selectedDate.month - 1]} ${selectedDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formattedDate,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: selectedItems.isEmpty
              ? const Text(
                  'Tidak ada jadwal',
                  style: TextStyle(color: Colors.white70),
                )
              : ListView.builder(
                  itemCount: selectedItems.length,
                  itemBuilder: (context, index) {
                    final item = selectedItems[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 2,
                            height: 18,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 10),

                          Builder(
                            builder: (textContext) {
                              return GestureDetector(
                                onTap: () => _showItemMenu(textContext, item),
                                child: Text(
                                  item.title,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showItemMenu(BuildContext itemContext, CalendarItem item) {
    final renderBox = itemContext.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + size.width + 8,
        position.dy,
        position.dx + size.width + 108,
        position.dy + size.height,
      ),
      items: const [
        PopupMenuItem(
          height: 40,
          value: 'edit',
          child: Text('Edit', style: TextStyle(fontSize: 15)),
        ),
        PopupMenuItem(
          height: 40,
          value: 'delete',
          child: Text('Delete', style: TextStyle(fontSize: 15)),
        ),
      ],
    ).then((value) async {
      if (value == 'edit') {
        if (item.type == CalendarItemType.timer) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TimerPage(existingTimer: item.timer),
            ),
          );

          if (result == true) {
            await _loadData();

            if (!mounted) return;

            _showSuccessDialog('Your timer has been updated!');
          }
        }

        if (item.type == CalendarItemType.schedule) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SchedulerPage(existingEvent: item.event),
            ),
          );

          if (result == true) {
            await _loadData();

            if (!mounted) return;

            _showSuccessDialog('Your schedule has been updated!');
          }
        }
      }

      if (value == 'delete') {
        _confirmDelete(item);
      }
    });
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

  Future<void> _confirmDelete(CalendarItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Wait!', style: TextStyle(fontSize: 18)),
          content: const Text(
            'Are u sure want to delete this reminder???',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    if (item.type == CalendarItemType.schedule) {
      final id = item.event?.id;
      if (id != null) {
        await eventRepo.delete(id);
      }
    } else {
      final id = item.timer?.id;
      if (id != null) {
        await timerRepo.delete(id);
      }
    }

    await _loadData();
  }
}
