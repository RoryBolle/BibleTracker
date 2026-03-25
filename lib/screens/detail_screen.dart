import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bible_data.dart';
import '../data/reading_repository.dart';
import '../providers/reading_providers.dart';
import '../widgets/progress_ring.dart' show RingColors;

class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(readingStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reading Progress')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => _BookList(stats: stats),
      ),
    );
  }
}

class _BookList extends StatelessWidget {
  final ReadingStats stats;
  const _BookList({required this.stats});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bibleBooks.length + 2, // +2 for OT/NT headers
      itemBuilder: (context, index) {
        // OT header at top
        if (index == 0) {
          return _SectionHeader(label: 'Old Testament');
        }
        // NT header after 39 OT books (index 40 = after 39 books + 1 header)
        if (index == 40) {
          return _SectionHeader(label: 'New Testament');
        }
        // Offset: index 1–39 → OT books 0–38, index 41–67 → NT books 39–65
        final bookIndex = index <= 39 ? index - 1 : index - 2;
        final book = bibleBooks[bookIndex];
        final chaptersRead = stats.chaptersReadInBook(bookIndex);

        return ListTile(
          leading: _ReadDot(
              maxCount: _maxChapterCount(stats, bookIndex, book.chapterCount)),
          title: Text(book.name),
          subtitle: Text(
            '$chaptersRead / ${book.chapterCount} chapters read',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChapterDetailScreen(
                bookIndex: bookIndex,
                stats: stats,
              ),
            ),
          ),
        );
      },
    );
  }

  int _maxChapterCount(ReadingStats stats, int bookIndex, int chapterCount) {
    int max = 0;
    for (int c = 1; c <= chapterCount; c++) {
      final count = stats.maxVerseReadCountInChapter(bookIndex, c);
      if (count > max) max = count;
    }
    return max;
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _ReadDot extends StatelessWidget {
  final int maxCount;
  const _ReadDot({required this.maxCount});

  Color get _color {
    if (maxCount == 0) return RingColors.unread;
    if (maxCount == 1) return RingColors.once;
    if (maxCount == 2) return RingColors.twice;
    return RingColors.threePlus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
    );
  }
}

// ─── Chapter detail ──────────────────────────────────────────────────────────

class ChapterDetailScreen extends StatelessWidget {
  final int bookIndex;
  final ReadingStats stats;

  const ChapterDetailScreen({
    super.key,
    required this.bookIndex,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final book = bibleBooks[bookIndex];

    return Scaffold(
      appBar: AppBar(title: Text(book.name)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 80,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.9,
        ),
        itemCount: book.chapterCount,
        itemBuilder: (context, i) {
          final ch = i + 1;
          final maxVerse = stats.maxVerseReadCountInChapter(bookIndex, ch);

          return InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VerseDetailScreen(
                  bookIndex: bookIndex,
                  chapter: ch,
                  stats: stats,
                ),
              ),
            ),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: _chapterColor(maxVerse).withAlpha(40),
                border: Border.all(color: _chapterColor(maxVerse), width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$ch',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _chapterColor(maxVerse),
                        ),
                  ),
                  if (maxVerse > 0)
                    Text(
                      '×$maxVerse',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _chapterColor(maxVerse),
                          ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _chapterColor(int maxVerse) {
    if (maxVerse == 0) return RingColors.unread;
    if (maxVerse == 1) return RingColors.once;
    if (maxVerse == 2) return RingColors.twice;
    return RingColors.threePlus;
  }
}

// ─── Verse detail ─────────────────────────────────────────────────────────────

class VerseDetailScreen extends StatelessWidget {
  final int bookIndex;
  final int chapter;
  final ReadingStats stats;

  const VerseDetailScreen({
    super.key,
    required this.bookIndex,
    required this.chapter,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final book = bibleBooks[bookIndex];
    final verseCount = book.versesInChapter(chapter);

    return Scaffold(
      appBar: AppBar(title: Text('${book.name} – Chapter $chapter')),
      body: ListView.builder(
        itemCount: verseCount,
        itemBuilder: (context, i) {
          final verse = i + 1;
          final count = stats.verseReadCount(bookIndex, chapter, verse);
          return ListTile(
            dense: true,
            leading: _ReadDot(maxCount: count),
            title: Text('Verse $verse'),
            trailing: count > 0
                ? Chip(
                    label: Text('×$count'),
                    backgroundColor: _verseChipColor(count).withAlpha(40),
                    side: BorderSide(color: _verseChipColor(count)),
                    padding: EdgeInsets.zero,
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 6),
                  )
                : const Text('—',
                    style: TextStyle(color: Colors.grey)),
          );
        },
      ),
    );
  }

  Color _verseChipColor(int count) {
    if (count == 0) return RingColors.unread;
    if (count == 1) return RingColors.once;
    if (count == 2) return RingColors.twice;
    return RingColors.threePlus;
  }
}
