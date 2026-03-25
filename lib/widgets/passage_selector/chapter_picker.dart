import 'package:flutter/material.dart';

import '../../data/bible_data.dart';

/// Grid of chapter number buttons for a given book with multi-select capability.
class ChapterPicker extends StatefulWidget {
  final int bookIndex;
  final int? selectedChapter;
  final ValueChanged<int> onChapterSelected;
  final ValueChanged<Set<int>>? onMultiSelectChanged;

  const ChapterPicker({
    super.key,
    required this.bookIndex,
    required this.selectedChapter,
    required this.onChapterSelected,
    this.onMultiSelectChanged,
  });

  @override
  State<ChapterPicker> createState() => _ChapterPickerState();
}

class _ChapterPickerState extends State<ChapterPicker> {
  final Set<int> _selectedChapters = {};

  @override
  void didUpdateWidget(ChapterPicker old) {
    super.didUpdateWidget(old);
    // Reset selections when book changes
    if (old.bookIndex != widget.bookIndex) {
      _selectedChapters.clear();
    }
  }

  void _toggleChapter(int chNum) {
    setState(() {
      if (_selectedChapters.contains(chNum)) {
        _selectedChapters.remove(chNum);
      } else {
        _selectedChapters.add(chNum);
      }
    });
    // Notify parent of all selected chapters
    widget.onMultiSelectChanged?.call(_selectedChapters);
  }

  @override
  Widget build(BuildContext context) {
    final book = bibleBooks[widget.bookIndex];
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 56,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: book.chapterCount,
      itemBuilder: (context, i) {
        final chNum = i + 1;
        final selected = _selectedChapters.contains(chNum);
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _toggleChapter(chNum),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '$chNum',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: selected ? colorScheme.onPrimary : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
