class Timer {
  final int? id;
  final int hours;
  final int minutes;
  final int seconds;
  final String pingStyle;
  final String note;
  final DateTime createdAt;
  final bool triggered;

  const Timer({
    this.id,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.pingStyle,
    required this.note,
    required this.createdAt,
    required this.triggered,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'ping_style': pingStyle,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'triggered': triggered ? 1 : 0,
    };
  }

  factory Timer.fromMap(Map<String, Object?> map) {
    return Timer(
      id: map['id'] as int?,
      hours: map['hours'] as int,
      minutes: map['minutes'] as int,
      seconds: map['seconds'] as int,
      pingStyle: map['ping_style'] as String,
      note: map['note'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      triggered: map['triggered'] == 1,
    );
  }
}
