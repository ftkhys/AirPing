import 'package:airping/shared/models/scheduled_event.dart';
import 'package:airping/shared/services/database_service.dart';

class ScheduledEventRepository {
  const ScheduledEventRepository();

  Future<int> insert(ScheduledEvent event) async {
    final database = await DatabaseService.instance.database;
    return database.insert('scheduled_events', event.toMap());
  }

  Future<List<ScheduledEvent>> getAll() async {
    final database = await DatabaseService.instance.database;
    final rows = await database.query(
      'scheduled_events',
      orderBy: 'starts_at ASC',
    );
    return rows.map(ScheduledEvent.fromMap).toList();
  }

  Future<List<ScheduledEvent>> getByDateRange(
    DateTime start,
    DateTime endExclusive,
  ) async {
    final database = await DatabaseService.instance.database;
    final rows = await database.query(
      'scheduled_events',
      where: 'starts_at < ? AND ends_at >= ?',
      whereArgs: [endExclusive.toIso8601String(), start.toIso8601String()],
      orderBy: 'starts_at ASC',
    );
    return rows.map(ScheduledEvent.fromMap).toList();
  }

  Future<int> update(ScheduledEvent event) async {
    final database = await DatabaseService.instance.database;
    return database.update(
      'scheduled_events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> markAsTriggered(int id) async {
    final database = await DatabaseService.instance.database;

    return database.update(
      'scheduled_events',
      {'triggered': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final database = await DatabaseService.instance.database;
    return database.delete(
      'scheduled_events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ScheduledEvent?> getById(int id) async {
    final database = await DatabaseService.instance.database;
    final rows = await database.query(
      'scheduled_events',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return ScheduledEvent.fromMap(rows.first);
  }

  Future<List<ScheduledEvent>> getByDate(DateTime date) async {
    final database = await DatabaseService.instance.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final rows = await database.query(
      'scheduled_events',
      where: 'starts_at >= ? AND starts_at < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'starts_at ASC',
    );
    return rows.map(ScheduledEvent.fromMap).toList();
  }

  Future<List<ScheduledEvent>> getUpcoming(int limit) async {
    final database = await DatabaseService.instance.database;

    final rows = await database.query(
      'scheduled_events',
      where: 'triggered = 0',
      orderBy: 'starts_at ASC',
      limit: limit,
    );
    return rows.map(ScheduledEvent.fromMap).toList();
  }
}
