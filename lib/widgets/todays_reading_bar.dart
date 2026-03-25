import 'package:flutter/material.dart';

import '../models/reading_entry.dart';

/// Verse key type.
typedef VerseKey = ({int bookIndex, int chapter, int verse});

/// Shows today's reading split: new (amber) vs read before (orange).
/// In portrait: horizontal bar above the ring.
/// In landscape: vertical bar to the side of the ring with labels to the right.
class TodaysReadingBar extends StatelessWidget {
  final List<ReadingEntry> todayEntries;
  final Map<VerseKey, int> verseCounts;
  final bool isVertical;

  const TodaysReadingBar({
    super.key,
    required this.todayEntries,
    required this.verseCounts,
    this.isVertical = false,
  });

  ({int newVerses, int readBeforeVerses}) _computeCounts() {
    int newVerses = 0;
    int readBeforeVerses = 0;
    for (final entry in todayEntries) {
      for (int verse = entry.verseStart; verse <= entry.verseEnd; verse++) {
        final key = (
          bookIndex: entry.bookIndex,
          chapter: entry.chapter,
          verse: verse,
        ) as VerseKey;
        final count = verseCounts[key] ?? 0;
        if (count <= 1) {
          newVerses++;
        } else {
          readBeforeVerses++;
        }
      }
    }
    return (newVerses: newVerses, readBeforeVerses: readBeforeVerses);
  }

  @override
  Widget build(BuildContext context) {
    final (:newVerses, :readBeforeVerses) = _computeCounts();
    final total = newVerses + readBeforeVerses;
    if (total == 0) return const SizedBox.shrink();

    final newFlex = ((newVerses / total) * 100).toInt().clamp(1, 99);
    final beforeFlex = ((readBeforeVerses / total) * 100).toInt().clamp(0, 98);

    return isVertical
        ? _VerticalBar(
            newVerses: newVerses,
            readBeforeVerses: readBeforeVerses,
            newFlex: newFlex,
            beforeFlex: beforeFlex,
          )
        : _HorizontalBar(
            newVerses: newVerses,
            readBeforeVerses: readBeforeVerses,
            newFlex: newFlex,
            beforeFlex: beforeFlex,
          );
  }
}

class _HorizontalBar extends StatelessWidget {
  final int newVerses;
  final int readBeforeVerses;
  final int newFlex;
  final int beforeFlex;

  const _HorizontalBar({
    required this.newVerses,
    required this.readBeforeVerses,
    required this.newFlex,
    required this.beforeFlex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's reading",
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  flex: newFlex,
                  child: Container(height: 24, color: const Color(0xFF60A5FA)),
                ),
                if (readBeforeVerses > 0)
                  Expanded(
                    flex: beforeFlex,
                    child: Container(height: 24, color: const Color(0xFF2563EB)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Dot(color: const Color(0xFF60A5FA), label: 'New ($newVerses)'),
              if (readBeforeVerses > 0) ...[
                const SizedBox(width: 16),
                _Dot(
                  color: const Color(0xFF2563EB),
                  label: 'Read before ($readBeforeVerses)',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _VerticalBar extends StatelessWidget {
  final int newVerses;
  final int readBeforeVerses;
  final int newFlex;
  final int beforeFlex;

  const _VerticalBar({
    required this.newVerses,
    required this.readBeforeVerses,
    required this.newFlex,
    required this.beforeFlex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Vertical bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 24,
              child: Column(
                children: [
                  Expanded(
                    flex: newFlex,
                    child: Container(color: const Color(0xFFFBBF24)),
                  ),
                  if (readBeforeVerses > 0)
                    Expanded(
                      flex: beforeFlex,
                      child: Container(color: const Color(0xFFF97316)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Labels to the right
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Today's reading",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              _Dot(color: const Color(0xFFFBBF24), label: 'New ($newVerses)'),
              if (readBeforeVerses > 0) ...[
                const SizedBox(height: 8),
                _Dot(
                  color: const Color(0xFFF97316),
                  label: 'Read before ($readBeforeVerses)',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
