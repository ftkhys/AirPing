import 'dart:async';

import 'package:airping/features/overlay/overlay_launcher.dart';
import 'package:airping/shared/services/scheduled_event_repository.dart';
import 'package:airping/shared/services/timer_repository.dart';

class SchedulerService {
  SchedulerService._();

  static final SchedulerService instance = SchedulerService._();

  final ScheduledEventRepository _eventRepository =
      const ScheduledEventRepository();

  final TimerRepository _timerRepository = const TimerRepository();

  Timer? _timer;

  DateTime? _startedAt;

  // Schedule yg sudah dipicu selama AirPing berjalan.
  final Set<int> _triggeredEventIds = {};
  final Set<int> _triggeredPreReminderIds = {};

  // Timer yg sudah dipicu selama AirPing berjalan.
  final Set<int> _triggeredTimerIds = {};

  void start() {
    if (_timer != null) return;

    _startedAt = DateTime.now();

    _check();
    _scheduleNextCheck();
  }

  Future<void> _scheduleNextCheck() async {
    final now = DateTime.now();

    _timer?.cancel();
    _timer = null;

    DateTime? nextTime;

    final events = await _eventRepository.getUpcoming(50);

    for (final event in events) {
      if (event.id == null) continue;
      if (event.triggered) continue;

      if (event.startsAt.isAfter(now)) {
        if (nextTime == null || event.startsAt.isBefore(nextTime)) {
          nextTime = event.startsAt;
        }
      }

      if (event.hasPreReminder &&
          !_triggeredPreReminderIds.contains(event.id)) {
        final preReminderDuration = Duration(
          hours: event.preReminderHours,
          minutes: event.preReminderMinutes,
          seconds: event.preReminderSeconds,
        );

        final preReminderTime = event.startsAt.subtract(preReminderDuration);

        if (preReminderTime.isAfter(now)) {
          if (nextTime == null || preReminderTime.isBefore(nextTime)) {
            nextTime = preReminderTime;
          }
        }
      }
    }

    final timers = await _timerRepository.getAll();

    for (final timer in timers) {
      if (timer.id == null) continue;
      if (timer.triggered) continue;

      final duration = Duration(
        hours: timer.hours,
        minutes: timer.minutes,
        seconds: timer.seconds,
      );

      final targetTime = timer.createdAt.add(duration);

      if (targetTime.isAfter(now)) {
        if (nextTime == null || targetTime.isBefore(nextTime)) {
          nextTime = targetTime;
        }
      }
    }

    if (nextTime == null) {
      return;
    }

    final delay = nextTime.difference(now);

    _timer?.cancel();

    _timer = Timer(delay, () async {
      await _check();
      await _scheduleNextCheck();
    });
  }

  Future<void> _check() async {
    await _checkScheduledEvents();
    await _checkTimers();
  }

  Future<void> _checkScheduledEvents() async {
    try {
      final events = await _eventRepository.getUpcoming(50);
      final now = DateTime.now();

      for (final event in events) {
        if (event.id == null) continue;
        if (_triggeredEventIds.contains(event.id)) continue;

        if (event.hasPreReminder &&
            !_triggeredPreReminderIds.contains(event.id)) {
          final preReminderDuration = Duration(
            hours: event.preReminderHours,
            minutes: event.preReminderMinutes,
            seconds: event.preReminderSeconds,
          );

          final preReminderTime = event.startsAt.subtract(preReminderDuration);

          if (!preReminderTime.isBefore(_startedAt!) &&
              !preReminderTime.isAfter(now)) {
            _triggeredPreReminderIds.add(event.id!);

            await _triggerPing(
              pingStyle: event.pingStyle,
              title: 'Coming up: ${event.title}',
            );
          }
        }

        if (!event.triggered &&
            !event.startsAt.isBefore(_startedAt!) &&
            !event.startsAt.isAfter(now)) {
          _triggeredEventIds.add(event.id!);

          await _triggerPing(pingStyle: event.pingStyle, title: event.title);

          await _eventRepository.markAsTriggered(event.id!);
        }
      }
    } catch (e) {
      print('SchedulerService error: $e');
    }
  }

  Future<void> _checkTimers() async {
    try {
      final now = DateTime.now();
      final allTimers = await _timerRepository.getAll();

      final timers = allTimers.where((timer) {
        return !timer.triggered;
      }).toList();

      for (final timer in timers) {
        if (timer.id == null) continue;
        if (_triggeredTimerIds.contains(timer.id)) continue;

        final duration = Duration(
          hours: timer.hours,
          minutes: timer.minutes,
          seconds: timer.seconds,
        );

        final targetTime = timer.createdAt.add(duration);

        if (!timer.triggered &&
            !targetTime.isAfter(now) &&
            !targetTime.isBefore(_startedAt!)) {
          _triggeredTimerIds.add(timer.id!);

          await _triggerPing(pingStyle: timer.pingStyle, title: timer.note);

          await _timerRepository.markAsTriggered(timer.id!);
        }
      }
    } catch (e) {
      print('SchedulerService timer error: $e');
    }
  }

  Future<void> _triggerPing({
    required String pingStyle,
    required String title,
  }) async {
    await OverlayLauncher.showPing(pingStyle: pingStyle, title: title);
  }

  void refresh() {
    if (_startedAt == null) return;

    _timer?.cancel();
    _timer = null;

    _scheduleNextCheck();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
