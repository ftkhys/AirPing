import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:airping/shared/models/timer.dart';
import 'package:airping/shared/services/timer_repository.dart';
import 'package:airping/shared/services/scheduler_service.dart';

class TimerPage extends StatefulWidget {
  final Timer? existingTimer;

  const TimerPage({super.key, this.existingTimer});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int hours = 1;
  int minutes = 0;
  int seconds = 0;
  String selectedPingStyle = 'paper_plane';
  final noteController = TextEditingController();
  final repository = const TimerRepository();
  late final FixedExtentScrollController hoursController;
  late final FixedExtentScrollController minutesController;
  late final FixedExtentScrollController secondsController;

  @override
  void initState() {
    super.initState();

    final timer = widget.existingTimer;

    if (timer != null) {
      hours = timer.hours;
      minutes = timer.minutes;
      seconds = timer.seconds;
      selectedPingStyle = timer.pingStyle;
      noteController.text = timer.note;
    }

    hoursController = FixedExtentScrollController(initialItem: hours);
    minutesController = FixedExtentScrollController(initialItem: minutes);
    secondsController = FixedExtentScrollController(initialItem: seconds);
  }

  @override
  void dispose() {
    noteController.dispose();
    hoursController.dispose();
    minutesController.dispose();
    secondsController.dispose();
    super.dispose();
  }

  Future<void> _saveTimer() async {
    final note = noteController.text.trim();
    if (hours == 0 && minutes == 0 && seconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu tidak boleh 00:00:00.')),
      );
      return;
    }

    if (note.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note wajib diisi.')));
      return;
    }

    try {
      final existingTimer = widget.existingTimer;

      if (existingTimer == null) {
        await repository.insert(
          Timer(
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            pingStyle: selectedPingStyle,
            note: note,
            createdAt: DateTime.now(),
            triggered: false,
          ),
        );
      } else {
        await repository.update(
          Timer(
            id: existingTimer.id,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            pingStyle: selectedPingStyle,
            note: note,
            createdAt: existingTimer.createdAt,
            triggered: existingTimer.triggered,
          ),
        );
      }

      if (!mounted) return;

      SchedulerService.instance.refresh();

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _selectPingStyle(String style) {
    setState(() {
      selectedPingStyle = style;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 20,
              top: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              right: 20,
              top: 20,
              child: IconButton(
                icon: const Icon(Icons.check, size: 24),
                onPressed: _saveTimer,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 100, 25, 30),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTimeColumn('Hours', hoursController, 24, hours, (
                          index,
                        ) {
                          setState(() => hours = index);
                        }),
                        _buildSeparator(),
                        _buildTimeColumn(
                          'Minutes',
                          minutesController,
                          60,
                          minutes,
                          (index) {
                            setState(() => minutes = index);
                          },
                        ),
                        _buildSeparator(),
                        _buildTimeColumn(
                          'Seconds',
                          secondsController,
                          60,
                          seconds,
                          (index) {
                            setState(() => seconds = index);
                          },
                        ),
                        const SizedBox(width: 45),
                        _buildPingColumn(),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Container(
                      width: 570,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          hintText: 'Note:',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'serif',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            children: List<Widget>.generate(itemCount, ((index) {
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
            })),
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
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

  Widget _buildPingColumn() {
    return Column(
      children: [
        Text('Ping', style: _labelStyle),
        const SizedBox(height: 35),
        GestureDetector(
          onTap: () => _selectPingStyle('paper_plane'),
          child: Image.asset(
            'assets/icons/fontisto_paper-plane.png',
            width: 30,
            height: 30,
            opacity: selectedPingStyle == 'paper_plane'
                ? const AlwaysStoppedAnimation(1.0)
                : const AlwaysStoppedAnimation(0.5),
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () => _selectPingStyle('bird'),
          child: Image.asset(
            'assets/icons/noto_bird.png',
            width: 42,
            height: 42,
            opacity: selectedPingStyle == 'bird'
                ? const AlwaysStoppedAnimation(1.0)
                : const AlwaysStoppedAnimation(0.5),
          ),
        ),
      ],
    );
  }
}

const _labelStyle = TextStyle(fontSize: 20, color: Colors.black54);

const _separatorStyle = TextStyle(fontSize: 38, fontWeight: FontWeight.bold);
