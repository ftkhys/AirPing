import 'package:airping/shared/models/timer.dart';
import 'package:airping/shared/services/database_service.dart';

class TimerRepository {
  const TimerRepository();

  Future<int> insert(Timer timer) async {
    final database = await DatabaseService.instance.database;
    return database.insert('timers', timer.toMap());
  }

  Future<List<Timer>> getAll() async {
    final database = await DatabaseService.instance.database;
    final rows = await database.query('timers', orderBy: 'created_at DESC');
    return rows.map(Timer.fromMap).toList();
  }

  Future<int> update(Timer timer) async {
    final database = await DatabaseService.instance.database;
    return database.update(
      'timers',
      timer.toMap(),
      where: 'id = ?',
      whereArgs: [timer.id],
    );
  }

  Future<int> markAsTriggered(int id) async {
    final database =await DatabaseService.instance.database;

    return database.update('timers', {'triggered': 1},
    where: 'id = ?',
    whereArgs: [id],);
  }

  Future<int> delete(int id) async {
    final database = await DatabaseService.instance.database;
    return database.delete('timers', where: 'id = ?', whereArgs: [id]);
  }

  Future<Timer?> getById(int id) async {
    final database = await DatabaseService.instance.database;
    final rows = await database.query(
      'timers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return Timer.fromMap(rows.first);
  }

  Future<List<Timer>> getByDate(DateTime date) async {
    final database = await DatabaseService.instance.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final rows = await database.query(
      'timers',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'created_at ASC',
    );
    return rows.map(Timer.fromMap).toList();
  }

  Future<List<Timer>> getByDateRange(
    DateTime start,
    DateTime endExclusive,
  ) async {
    final database = await DatabaseService.instance.database;
    final rows = await database.query(
      'timers',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [start.toIso8601String(), endExclusive.toIso8601String()],
      orderBy: 'created_at ASC',
    );
    return rows.map(Timer.fromMap).toList();
  }
}
