import 'package:sqflite/sqflite.dart';

import '../data/db_helper.dart';
import '../data/bible_data.dart';
import '../models/reading_entry.dart';

/// Verse-level read-count key: identifies a unique verse.
typedef VerseKey = ({int bookIndex, int chapter, int verse});

/// All aggregated reading statistics computed from the database.
class ReadingStats {
  /// Map from VerseKey → number of distinct dates the verse was read.
  final Map<VerseKey, int> verseCounts;

  const ReadingStats(this.verseCounts);

  /// Number of distinct verses that have been read at least once.
  int get totalDistinctVersesRead =>
      verseCounts.values.where((c) => c > 0).length;

  /// Sum of all read counts across all verses (used for ring ratio display).
  int get totalVerseReads => verseCounts.values.fold(0, (s, c) => s + c);

  /// How many distinct verses have been read exactly once.
  int get readOnceCount => verseCounts.values.where((c) => c == 1).length;

  /// How many distinct verses have been read exactly twice.
  int get readTwiceCount => verseCounts.values.where((c) => c == 2).length;

  /// How many distinct verses have been read 3 or more times.
  int get readThreePlusCount => verseCounts.values.where((c) => c >= 3).length;

  /// Number of verses never read.
  int get unreadCount =>
      totalBibleVerses - readOnceCount - readTwiceCount - readThreePlusCount;

  /// Returns total distinct read count for a given chapter (for detail view).
  int chapterReadCount(int bookIndex, int chapter) {
    final book = bibleBooks[bookIndex];
    final verseMax = book.versesInChapter(chapter);
    if (verseMax == 0) return 0;
    int total = 0;
    for (int v = 1; v <= verseMax; v++) {
      total += verseCounts[(bookIndex: bookIndex, chapter: chapter, verse: v)] ??
          0;
    }
    return total;
  }

  /// How many chapters in the book have been read at least once.
  int chaptersReadInBook(int bookIndex) {
    final book = bibleBooks[bookIndex];
    int count = 0;
    for (int c = 1; c <= book.chapterCount; c++) {
      if (chapterReadCount(bookIndex, c) > 0) count++;
    }
    return count;
  }

  /// The max read count for any verse in a chapter (determines chapter colour).
  int maxVerseReadCountInChapter(int bookIndex, int chapter) {
    final book = bibleBooks[bookIndex];
    final verseMax = book.versesInChapter(chapter);
    int max = 0;
    for (int v = 1; v <= verseMax; v++) {
      final c =
          verseCounts[(bookIndex: bookIndex, chapter: chapter, verse: v)] ?? 0;
      if (c > max) max = c;
    }
    return max;
  }

  /// Read count for a specific verse.
  int verseReadCount(int bookIndex, int chapter, int verse) =>
      verseCounts[(bookIndex: bookIndex, chapter: chapter, verse: verse)] ?? 0;

  /// Chapter-level stats. A chapter is counted at the tier of its highest
  /// verse read count (e.g. if any verse was read 2×, the chapter is "twice").
  ({int once, int twice, int threePlus, int total}) get chapterStats {
    int once = 0, twice = 0, threePlus = 0;
    for (final book in bibleBooks) {
      for (int c = 1; c <= book.chapterCount; c++) {
        final max = maxVerseReadCountInChapter(book.index, c);
        if (max == 1) {
          once++;
        } else if (max == 2) {
          twice++;
        } else if (max >= 3) {
          threePlus++;
        }
      }
    }
    return (once: once, twice: twice, threePlus: threePlus, total: once + twice + threePlus);
  }
}

/// Repository: all database operations for reading entries.
class ReadingRepository {
  ReadingRepository._();
  static final ReadingRepository instance = ReadingRepository._();

  Future<Database> get _db async => DbHelper.instance.database;

  // ─── Write ──────────────────────────────────────────────────────────────

  /// Insert a reading entry. Silently ignores true duplicates (same passage + date).
  Future<void> insertEntry(ReadingEntry entry) async {
    final db = await _db;
    await db.insert(
      DbHelper.table,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Delete a reading entry by its database id.
  Future<void> deleteEntry(int id) async {
    final db = await _db;
    await db.delete(DbHelper.table, where: 'id = ?', whereArgs: [id]);
  }

  /// Insert many entries efficiently in a single transaction.
  Future<void> bulkInsertEntries(List<ReadingEntry> entries) async {
    final db = await _db;
    await db.transaction((txn) async {
      for (final entry in entries) {
        await txn.insert(
          DbHelper.table,
          entry.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }

  // ─── Read ────────────────────────────────────────────────────────────────

  /// Fetch all entries, newest first.
  Future<List<ReadingEntry>> fetchAll() async {
    final db = await _db;
    final rows = await db.query(DbHelper.table, orderBy: 'read_date DESC');
    return rows.map(ReadingEntry.fromMap).toList();
  }

  /// Fetch all entries for a specific date (YYYY-MM-DD).
  Future<List<ReadingEntry>> fetchForDate(String date) async {
    final db = await _db;
    final rows = await db.query(
      DbHelper.table,
      where: 'read_date = ?',
      whereArgs: [date],
    );
    return rows.map(ReadingEntry.fromMap).toList();
  }

  // ─── Aggregation ─────────────────────────────────────────────────────────

  /// Compute full aggregated stats from all entries.
  /// Reads all rows from DB, expands verse ranges app-side,
  /// and counts distinct dates per verse.
  Future<ReadingStats> computeStats() async {
    final entries = await fetchAll();

    // Map: VerseKey → set of distinct dates read
    final Map<VerseKey, Set<String>> verseDates = {};

    for (final entry in entries) {
      for (int v = entry.verseStart; v <= entry.verseEnd; v++) {
        final key = (
          bookIndex: entry.bookIndex,
          chapter: entry.chapter,
          verse: v,
        );
        verseDates.putIfAbsent(key, () => {}).add(entry.readDate);
      }
    }

    final Map<VerseKey, int> verseCounts = {};
    verseDates.forEach((key, dates) {
      verseCounts[key] = dates.length;
    });

    return ReadingStats(verseCounts);
  }
}
