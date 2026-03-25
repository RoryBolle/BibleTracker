import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// Manages the SQLite database lifecycle.
class DbHelper {
  static const _dbName = 'bible_tracker.db';
  static const _dbVersion = 1;
  static const table = 'reading_entries';

  DbHelper._();
  static final DbHelper instance = DbHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        book_index  INTEGER NOT NULL,
        chapter     INTEGER NOT NULL,
        verse_start INTEGER NOT NULL,
        verse_end   INTEGER NOT NULL,
        read_date   TEXT    NOT NULL,
        UNIQUE(book_index, chapter, verse_start, verse_end, read_date)
      )
    ''');
    // Indexes for common query patterns
    await db.execute(
      'CREATE INDEX idx_date ON $table (read_date)',
    );
    await db.execute(
      'CREATE INDEX idx_book ON $table (book_index)',
    );
  }
}
