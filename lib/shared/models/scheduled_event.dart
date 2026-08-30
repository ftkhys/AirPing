class ScheduledEvent {
  final int? id;
  final String title;
  final String agenda;
  final DateTime startsAt;
  final DateTime endsAt;
  final String pingStyle;
  final bool hasPreReminder;
  final int preReminderHours;
  final int preReminderMinutes;
  final int preReminderSeconds;
  final bool triggered;
  final bool repeatEnabled;
  final int repeatInterval;
  final String repeatUnit;

  const ScheduledEvent({
    this.id,
    required this.title,
    required this.agenda,
    required this.startsAt,
    required this.endsAt,
    required this.pingStyle,
    required this.hasPreReminder,
    required this.preReminderHours,
    required this.preReminderMinutes,
    required this.preReminderSeconds,
    required this.triggered,
    required this.repeatEnabled,
    required this.repeatInterval,
    required this.repeatUnit,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'agenda': agenda,
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt.toIso8601String(),
      'ping_style': pingStyle,
      'has_pre_reminder': hasPreReminder ? 1 : 0,
      'pre_reminder_hours': preReminderHours,
      'pre_reminder_minutes': preReminderMinutes,
      'pre_reminder_seconds': preReminderSeconds,
      'triggered': triggered ? 1 : 0,
      'repeat_enabled': repeatEnabled ? 1 : 0,
      'repeat_interval': repeatInterval,
      'repeat_unit': repeatUnit,
    };
  }

  factory ScheduledEvent.fromMap(Map<String, Object?> map) {
    return ScheduledEvent(
      id: map['id'] as int?,
      title: map['title'] as String,
      agenda: map['agenda'] as String,
      startsAt: DateTime.parse(map['starts_at'] as String),
      endsAt: DateTime.parse(map['ends_at'] as String),
      pingStyle: map['ping_style'] as String,
      hasPreReminder: map['has_pre_reminder'] == 1,
      preReminderHours: map['pre_reminder_hours'] as int,
      preReminderMinutes: map['pre_reminder_minutes'] as int,
      preReminderSeconds: map['pre_reminder_seconds'] as int,
      triggered: map['triggered'] == 1,
      repeatEnabled: map['repeat_enabled'] == 1,
      repeatInterval: map['repeat_interval'] as int,
      repeatUnit: map['repeat_unit'] as String,
    );
  }
}
