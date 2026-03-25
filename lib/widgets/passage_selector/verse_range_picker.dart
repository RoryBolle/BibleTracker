import 'package:flutter/material.dart';

import '../../data/bible_data.dart';

/// Verse range selector for a specific book + chapter.
/// Defaults to the full chapter; an optional expand toggle lets the
/// user pick a start and end verse.
class VerseRangePicker extends StatefulWidget {
  final int bookIndex;
  final int chapter;

  /// Called whenever the selection changes.
  /// [verseStart] and [verseEnd] are 1-based inclusive.
  final void Function(int verseStart, int verseEnd) onChanged;

  const VerseRangePicker({
    super.key,
    required this.bookIndex,
    required this.chapter,
    required this.onChanged,
  });

  @override
  State<VerseRangePicker> createState() => _VerseRangePickerState();
}

class _VerseRangePickerState extends State<VerseRangePicker> {
  bool _expanded = false;
  late int _start;
  late int _end;

  int get _maxVerse =>
      bibleBooks[widget.bookIndex].versesInChapter(widget.chapter);

  @override
  void initState() {
    super.initState();
    // Initialize state but defer callback to avoid setState during build
    _start = 1;
    _end = _maxVerse;
    _expanded = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onChanged(_start, _end);
      }
    });
  }

  @override
  void didUpdateWidget(VerseRangePicker old) {
    super.didUpdateWidget(old);
    if (old.bookIndex != widget.bookIndex || old.chapter != widget.chapter) {
      _reset();
    }
  }

  void _reset() {
    _start = 1;
    _end = _maxVerse;
    _expanded = false;
    widget.onChanged(_start, _end);
  }

  void _notify() => widget.onChanged(_start, _end);

  @override
  Widget build(BuildContext context) {
    final max = _maxVerse;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full chapter chip / toggle
        Row(
          children: [
            const SizedBox(width: 16),
            FilterChip(
              label: Text(_expanded
                  ? 'Verses $_start–$_end'
                  : 'Full chapter ($max verses)'),
              selected: !_expanded,
              onSelected: (_) {
                setState(() {
                  _expanded = false;
                  _start = 1;
                  _end = max;
                });
                _notify();
              },
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: Icon(_expanded ? Icons.expand_less : Icons.tune, size: 18),
              label: Text(_expanded ? 'Reset' : 'Custom range'),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                  if (!_expanded) {
                    _start = 1;
                    _end = max;
                    _notify();
                  }
                });
              },
            ),
          ],
        ),
        if (_expanded) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _VerseDropdown(
                    label: 'Start',
                    value: _start,
                    min: 1,
                    max: _end,
                    onChanged: (v) {
                      setState(() => _start = v);
                      _notify();
                    },
                    accentColor: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _VerseDropdown(
                    label: 'End',
                    value: _end,
                    min: _start,
                    max: max,
                    onChanged: (v) {
                      setState(() => _end = v);
                      _notify();
                    },
                    accentColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _VerseDropdown extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final Color accentColor;

  const _VerseDropdown({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      max - min + 1,
      (i) => DropdownMenuItem(value: min + i, child: Text('${min + i}')),
    );

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isDense: true,
          items: items,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
