import 'package:flutter_test/flutter_test.dart';
import 'package:bible_tracker/data/bible_data.dart';
import 'package:bible_tracker/data/reading_repository.dart';
import 'package:bible_tracker/models/reading_entry.dart';

void main() {
  // ─── BibleData structural tests ────────────────────────────────────────────

  group('BibleData', () {
    test('has exactly 66 books', () {
      expect(bibleBooks.length, 66);
    });

    test('book indices are sequential 0–65', () {
      for (int i = 0; i < bibleBooks.length; i++) {
        expect(bibleBooks[i].index, i);
      }
    });

    test('total verses equals $totalBibleVerses', () {
      final total =
          bibleBooks.fold<int>(0, (sum, b) => sum + b.totalVerses);
      expect(total, totalBibleVerses);
    });

    test('Genesis has 50 chapters', () {
      expect(bibleBooks[0].chapterCount, 50);
    });

    test('Genesis chapter 1 has 31 verses', () {
      expect(bibleBooks[0].versesInChapter(1), 31);
    });

    test('Revelation has 22 chapters', () {
      expect(bibleBooks[65].chapterCount, 22);
    });

    test('Psalms has 150 chapters', () {
      expect(bibleBooks[18].chapterCount, 150);
    });

    test('John chapter 3 has 36 verses', () {
      // John is book index 42
      expect(bibleBooks[42].versesInChapter(3), 36);
    });

    test('Old Testament has 39 books', () {
      expect(bibleBooks.where((b) => b.isOldTestament).length, 39);
    });

    test('New Testament has 27 books', () {
      expect(bibleBooks.where((b) => !b.isOldTestament).length, 27);
    });
  });

  // ─── expandPassage tests ───────────────────────────────────────────────────

  group('expandPassage', () {
    test('expands single verse correctly', () {
      final result = expandPassage(
        bookIndex: 42,
        chapter: 3,
        verseStart: 16,
        verseEnd: 16,
      );
      expect(result.length, 1);
      expect(result.first,
          (bookIndex: 42, chapter: 3, verse: 16));
    });

    test('expands range of 5 verses', () {
      final result = expandPassage(
        bookIndex: 0,
        chapter: 1,
        verseStart: 1,
        verseEnd: 5,
      );
      expect(result.length, 5);
      expect(result.map((r) => r.verse).toList(), [1, 2, 3, 4, 5]);
    });

    test('full-chapter expansion matches verse count', () {
      // Genesis 1: 31 verses
      final result = expandPassage(
        bookIndex: 0,
        chapter: 1,
        verseStart: 1,
        verseEnd: 31,
      );
      expect(result.length, 31);
    });
  });

  // ─── ReadingStats aggregation tests ───────────────────────────────────────

  group('ReadingStats aggregation', () {
    ReadingStats buildStats(
        Map<VerseKey, int> counts) =>
        ReadingStats(counts);

    test('all counters zero when empty', () {
      final stats = buildStats({});
      expect(stats.readOnceCount, 0);
      expect(stats.readTwiceCount, 0);
      expect(stats.readThreePlusCount, 0);
      expect(stats.totalDistinctVersesRead, 0);
      expect(stats.unreadCount, totalBibleVerses);
    });

    test('single verse read once', () {
      final stats = buildStats({
        (bookIndex: 0, chapter: 1, verse: 1): 1,
      });
      expect(stats.readOnceCount, 1);
      expect(stats.readTwiceCount, 0);
      expect(stats.readThreePlusCount, 0);
      expect(stats.unreadCount, totalBibleVerses - 1);
    });

    test('verse read twice shows in readTwiceCount', () {
      final stats = buildStats({
        (bookIndex: 0, chapter: 1, verse: 1): 2,
      });
      expect(stats.readOnceCount, 0);
      expect(stats.readTwiceCount, 1);
    });

    test('verse read 3+ times shows in readThreePlusCount', () {
      final stats = buildStats({
        (bookIndex: 0, chapter: 1, verse: 1): 3,
        (bookIndex: 0, chapter: 1, verse: 2): 5,
      });
      expect(stats.readThreePlusCount, 2);
    });

    test('chapterReadCount sums verse counts', () {
      final stats = buildStats({
        (bookIndex: 0, chapter: 1, verse: 1): 2,
        (bookIndex: 0, chapter: 1, verse: 2): 1,
        (bookIndex: 0, chapter: 1, verse: 3): 3,
      });
      expect(stats.chapterReadCount(0, 1), 6);
    });

    test('maxVerseReadCountInChapter returns max', () {
      final stats = buildStats({
        (bookIndex: 0, chapter: 1, verse: 1): 1,
        (bookIndex: 0, chapter: 1, verse: 2): 4,
        (bookIndex: 0, chapter: 1, verse: 3): 2,
      });
      expect(stats.maxVerseReadCountInChapter(0, 1), 4);
    });

    test('chaptersReadInBook counts chapters with at least 1 read verse', () {
      final stats = buildStats({
        (bookIndex: 0, chapter: 1, verse: 1): 1,
        (bookIndex: 0, chapter: 3, verse: 5): 2,
      });
      expect(stats.chaptersReadInBook(0), 2);
    });
  });

  // ─── De-duplication logic test ─────────────────────────────────────────────
  // Verifies that the repository's computeStats correctly de-duplicates
  // verses read on the same day (simulated without DB using the same logic).

  group('De-duplication', () {
    test('same verse on same date counts as 1', () {
      // Simulate what computeStats does: build verseDates map
      final entries = [
        ReadingEntry(
          bookIndex: 42,
          chapter: 3,
          verseStart: 16,
          verseEnd: 16,
          readDate: '2026-03-25',
        ),
        // Same verse, same date — should NOT increment count
        ReadingEntry(
          bookIndex: 42,
          chapter: 3,
          verseStart: 16,
          verseEnd: 16,
          readDate: '2026-03-25',
        ),
      ];

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

      expect(verseDates[(bookIndex: 42, chapter: 3, verse: 16)]?.length, 1);
    });

    test('same verse on different dates counts as 2', () {
      final entries = [
        ReadingEntry(
          bookIndex: 42,
          chapter: 3,
          verseStart: 16,
          verseEnd: 16,
          readDate: '2026-03-24',
        ),
        ReadingEntry(
          bookIndex: 42,
          chapter: 3,
          verseStart: 16,
          verseEnd: 16,
          readDate: '2026-03-25',
        ),
      ];

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

      expect(verseDates[(bookIndex: 42, chapter: 3, verse: 16)]?.length, 2);
    });
  });
}
