import 'package:flutter/material.dart';

import '../../data/bible_data.dart';

/// Scrollable book picker that shows OT / NT section headers.
class BookPicker extends StatelessWidget {
  final int? selectedBookIndex;
  final ValueChanged<int> onBookSelected;

  const BookPicker({
    super.key,
    required this.selectedBookIndex,
    required this.onBookSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final List<Widget> items = [];
    bool shownOT = false;
    bool shownNT = false;

    for (final book in bibleBooks) {
      if (book.isOldTestament && !shownOT) {
        shownOT = true;
        items.add(_SectionHeader(
            label: 'Old Testament', color: colorScheme.primary));
      }
      if (!book.isOldTestament && !shownNT) {
        shownNT = true;
        items.add(_SectionHeader(
            label: 'New Testament', color: colorScheme.secondary));
      }

      final selected = selectedBookIndex == book.index;
      items.add(
        ListTile(
          dense: true,
          title: Text(book.name),
          trailing: Text(
            book.abbreviation,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Colors.grey),
          ),
          selected: selected,
          selectedTileColor: colorScheme.primaryContainer,
          onTap: () => onBookSelected(book.index),
        ),
      );
    }

    return ListView(children: items);
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
