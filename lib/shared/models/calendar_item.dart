import 'package:airping/shared/models/scheduled_event.dart';
import 'package:airping/shared/models/timer.dart' as timer_model;

enum CalendarItemType { schedule, timer }

class CalendarItem {
  final CalendarItemType type;
  final ScheduledEvent? event;
  final timer_model.Timer? timer;

  const CalendarItem.fromEvent(ScheduledEvent this.event)
    : type = CalendarItemType.schedule,
      timer = null;

  const CalendarItem.fromTimer(timer_model.Timer this.timer)
    : type = CalendarItemType.timer,
      event = null;

  DateTime get sortTime =>
      type == CalendarItemType.schedule ? event!.startsAt : timer!.createdAt;

  String get title =>
      type == CalendarItemType.schedule ? event!.title : timer!.note;

  String get pingStyle =>
      type == CalendarItemType.schedule ? event!.pingStyle : timer!.pingStyle;
}
