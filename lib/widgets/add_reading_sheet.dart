import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/bible_data.dart';
import '../models/reading_entry.dart';
import '../providers/reading_providers.dart';
import 'passage_selector/book_picker.dart';
import 'passage_selector/chapter_picker.dart';
import 'passage_selector/verse_range_picker.dart';

/// Bottom sheet for logging today's reading passages.
/// Opens via [AddReadingSheet.show].
class AddReadingSheet extends ConsumerStatefulWidget {
  const AddReadingSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => const AddReadingSheet(),
      );

  @override
  ConsumerState<AddReadingSheet> createState() => _AddReadingSheetState();
}

class _AddReadingSheetState extends ConsumerState<AddReadingSheet> {
  // Current selector state
  int? _bookIndex;
  int? _chapter;
  Set<int> _selectedChapters = {}; // Multi-select chapters
  int _verseStart = 1;
  int _verseEnd = 1;
  bool _useCustomVerses = false; // Toggle for custom verse selection

  // Which step is expanded: 'book', 'chapter', 'verse', or null (collapsed)
  String _step = 'book';

  String get _todayLabel =>
      DateFormat('MMMM d, yyyy').format(DateTime.now());

  bool get _canAdd => _bookIndex != null && _selectedChapters.isNotEmpty;

  Future<void> _addPassage() async {
    if (!_canAdd) return;
    final book = bibleBooks[_bookIndex!];

    // Add an entry for each selected chapter
    for (final ch in _selectedChapters) {
      int vs = _verseStart;
      int ve = _verseEnd;

      // If multi-chapter or not using custom verses, add full chapter
      if (_selectedChapters.length > 1 || !_useCustomVerses) {
        vs = 1;
        ve = book.versesInChapter(ch);
      }

      final entry = ReadingEntry(
        bookIndex: _bookIndex!,
        chapter: ch,
        verseStart: vs,
        verseEnd: ve,
        readDate: todayDateString(),
      );
      await ref.read(todayEntriesProvider.notifier).addEntry(entry);
    }

    // Reset for next passage
    setState(() {
      _chapter = null;
      _selectedChapters.clear();
      _useCustomVerses = false;
      _step = 'chapter';
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayEntries = ref.watch(todayEntriesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          // ── Handle ──
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // ── Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today\'s Reading',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(_todayLabel,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Today's readings list ──
          todayEntries.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => const SizedBox.shrink(),
            data: (entries) {
              if (entries.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Text(
                    'No passages added today yet.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                );
              }
              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: SingleChildScrollView(
                  child: Column(
                    children: entries
                        .map((e) => _EntryChip(
                              entry: e,
                              onDelete: () => ref
                                  .read(todayEntriesProvider.notifier)
                                  .removeEntry(e.id!),
                            ))
                        .toList(),
                  ),
                ),
              );
            },
          ),
          const Divider(),

          // ── Add button ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: _canAdd ? _addPassage : null,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Step selector ──
          Expanded(
            child: _StepContent(
              step: _step,
              bookIndex: _bookIndex,
              chapter: _chapter,
              selectedChapters: _selectedChapters,
              colorScheme: colorScheme,
              useCustomVerses: _useCustomVerses,
              onStepTap: (s) => setState(() => _step = s),
              onBookSelected: (b) => setState(() {
                _bookIndex = b;
                _chapter = null;
                _selectedChapters.clear();
                _step = 'chapter';
              }),
              onChapterSelected: (c) {
                final book = bibleBooks[_bookIndex!];
                setState(() {
                  _chapter = c;
                  _verseStart = 1;
                  _verseEnd = book.versesInChapter(c);
                });
              },
              onMultiSelectChaptersChanged: (chapters) {
                setState(() {
                  _selectedChapters = chapters;
                  if (chapters.isNotEmpty) {
                    _chapter = chapters.first;
                  }
                });
              },
              onVerseChanged: (s, e) => setState(() {
                _verseStart = s;
                _verseEnd = e;
              }),
              onUseCustomVersesChanged: (use) => setState(() {
                _useCustomVerses = use;
                if (use) {
                  _step = 'verse';
                }
              }),
            ),
          ),
          // Bottom safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Chip tile for an already-added today entry.
class _EntryChip extends StatelessWidget {
  final ReadingEntry entry;
  final VoidCallback onDelete;

  const _EntryChip({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final book = bibleBooks[entry.bookIndex];
    final maxVerse = book.versesInChapter(entry.chapter);
    final isFullChapter =
        entry.verseStart == 1 && entry.verseEnd == maxVerse;
    final label = isFullChapter
        ? '${book.name} ${entry.chapter}'
        : '${book.name} ${entry.chapter}:${entry.verseStart}–${entry.verseEnd}';

    return ListTile(
      dense: true,
      leading: Icon(Icons.menu_book,
          color: Theme.of(context).colorScheme.primary, size: 18),
      title: Text(label),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 16),
        onPressed: onDelete,
        tooltip: 'Remove',
      ),
    );
  }
}

/// Drives the three-step tab selector (Book → Chapter → Verse).
class _StepContent extends StatelessWidget {
  final String step;
  final int? bookIndex;
  final int? chapter;
  final Set<int> selectedChapters;
  final ColorScheme colorScheme;
  final bool useCustomVerses;
  final ValueChanged<String> onStepTap;
  final ValueChanged<int> onBookSelected;
  final ValueChanged<int> onChapterSelected;
  final ValueChanged<Set<int>> onMultiSelectChaptersChanged;
  final void Function(int start, int end) onVerseChanged;
  final ValueChanged<bool> onUseCustomVersesChanged;

  const _StepContent({
    required this.step,
    required this.bookIndex,
    required this.chapter,
    required this.selectedChapters,
    required this.colorScheme,
    required this.useCustomVerses,
    required this.onStepTap,
    required this.onBookSelected,
    required this.onChapterSelected,
    required this.onMultiSelectChaptersChanged,
    required this.onVerseChanged,
    required this.onUseCustomVersesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Step tabs
        Row(
          children: [
            _StepTab(
              label: bookIndex == null
                  ? 'Book'
                  : bibleBooks[bookIndex!].name,
              active: step == 'book',
              onTap: () => onStepTap('book'),
            ),
            _StepTab(
              label: 'Chapter',
              active: step == 'chapter',
              enabled: bookIndex != null,
              onTap: bookIndex != null ? () => onStepTap('chapter') : null,
            ),
            if (useCustomVerses)
              _StepTab(
                label: 'Verses',
                active: step == 'verse',
                enabled: chapter != null,
                onTap: chapter != null ? () => onStepTap('verse') : null,
              ),
          ],
        ),
        const Divider(height: 1),
        Expanded(
          child: switch (step) {
            'book' => BookPicker(
                selectedBookIndex: bookIndex,
                onBookSelected: onBookSelected,
              ),
            'chapter' when bookIndex != null => _ChapterPickerWithToggle(
                bookIndex: bookIndex!,
                selectedChapter: chapter,
                selectedChapters: selectedChapters,
                useCustomVerses: useCustomVerses,
                onChapterSelected: onChapterSelected,
                onMultiSelectChaptersChanged: onMultiSelectChaptersChanged,
                onUseCustomVersesChanged: onUseCustomVersesChanged,
              ),
            'verse' when bookIndex != null && chapter != null =>
              SingleChildScrollView(
                child: VerseRangePicker(
                  bookIndex: bookIndex!,
                  chapter: chapter!,
                  onChanged: onVerseChanged,
                ),
              ),
            _ => const Center(child: Text('Select a book first')),
          },
        ),
      ],
    );
  }
}

/// Wrapper around ChapterPicker with a toggle for custom verses.
class _ChapterPickerWithToggle extends StatelessWidget {
  final int bookIndex;
  final int? selectedChapter;
  final Set<int> selectedChapters;
  final bool useCustomVerses;
  final ValueChanged<int> onChapterSelected;
  final ValueChanged<Set<int>> onMultiSelectChaptersChanged;
  final ValueChanged<bool> onUseCustomVersesChanged;

  const _ChapterPickerWithToggle({
    required this.bookIndex,
    required this.selectedChapter,
    required this.selectedChapters,
    required this.useCustomVerses,
    required this.onChapterSelected,
    required this.onMultiSelectChaptersChanged,
    required this.onUseCustomVersesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chapter picker
        Expanded(
          child: ChapterPicker(
            bookIndex: bookIndex,
            selectedChapter: selectedChapter,
            onChapterSelected: onChapterSelected,
            onMultiSelectChanged: onMultiSelectChaptersChanged,
          ),
        ),
        // Toggle for custom verses (only show if single chapter selected) — below the grid
        if (selectedChapters.length <= 1) const Divider(height: 1),
        if (selectedChapters.length <= 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Checkbox(
                  value: useCustomVerses,
                  onChanged: (val) =>
                      onUseCustomVersesChanged(val ?? false),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Select specific verses',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepTab extends StatelessWidget {
  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback? onTap;

  const _StepTab({
    required this.label,
    this.active = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    active ? colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: active
                      ? colorScheme.primary
                      : enabled
                          ? null
                          : Colors.grey,
                  fontWeight:
                      active ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ),
      ),
    );
  }
}
