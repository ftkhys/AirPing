import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final databasePath = await databaseFactory.getDatabasesPath();
    print('DATABASE PATH: $databasePath');
    _database = await databaseFactory.openDatabase(
      join(databasePath, 'airping.db'),
      options: OpenDatabaseOptions(
        version: 4,

        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE scheduled_events (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              agenda TEXT NOT NULL,
              starts_at TEXT NOT NULL,
              ends_at TEXT NOT NULL,
              ping_style TEXT NOT NULL,
              has_pre_reminder INTEGER NOT NULL DEFAULT 0,
              pre_reminder_hours INTEGER NOT NULL DEFAULT 0,
              pre_reminder_minutes INTEGER NOT NULL DEFAULT 0,
              pre_reminder_seconds INTEGER NOT NULL DEFAULT 0,
              triggered INTEGER NOT NULL DEFAULT 0,
              repeat_enabled INTEGER NOT NULL DEFAULT 0,
              repeat_interval INTEGER NOT NULL DEFAULT 1,
              repeat_unit TEXT NOT NULL DEFAULT 'day'
            )
          ''');

          await database.execute('''
            CREATE TABLE timers (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              hours INTEGER NOT NULL,
              minutes INTEGER NOT NULL,
              seconds INTEGER NOT NULL,
              ping_style TEXT NOT NULL,
              note TEXT NOT NULL,
              created_at TEXT NOT NULL,
              triggered INTEGER NOT NULL DEFAULT 0
            )
          ''');
        },

        onUpgrade: (database, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await database.execute('''
              ALTER TABLE scheduled_events
              ADD COLUMN triggered INTEGER NOT NULL DEFAULT 0
            ''');

            await database.execute('''
              ALTER TABLE timers
              ADD COLUMN triggered INTEGER NOT NULL DEFAULT 0
            ''');
          }

          if (oldVersion < 3) {
            await database.execute('''
              ALTER TABLE scheduled_events
              ADD COLUMN pre_reminder_hours INTEGER NOT NULL DEFAULT 0
            ''');

            await database.execute('''
              ALTER TABLE scheduled_events
              ADD COLUMN pre_reminder_minutes INTEGER NOT NULL DEFAULT 0
            ''');

            await database.execute('''
              ALTER TABLE scheduled_events
              ADD COLUMN pre_reminder_seconds INTEGER NOT NULL DEFAULT 0
            ''');
          }

          if (oldVersion < 4) {
            await database.execute('''
              ALTER TABLE scheduled_events
              ADD COLUMN repeat_enabled INTEGER NOT NULL DEFAULT 0
              ''');

            await database.execute('''
              ALTER TABLE scheduled_events
              ADD COLUMN repeat_interval INTEGER NOT NULL DEFAULT 1
              ''');

            await database.execute('''
              ALTER TABLE scheduled_events
              ADD COLUMN repeat_unit TEXT NOT NULL DEFAULT 'day'
              ''');
          }
        },
      ),
    );
    return _database!;
  }
}
