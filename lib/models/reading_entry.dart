/// A single reading record: one passage on one date.
/// Verse ranges are always stored expanded to real verse numbers.
class ReadingEntry {
  final int? id;
  final int bookIndex;   // 0-based
  final int chapter;     // 1-based
  final int verseStart;  // 1-based, inclusive
  final int verseEnd;    // 1-based, inclusive
  final String readDate; // "YYYY-MM-DD"

  const ReadingEntry({
    this.id,
    required this.bookIndex,
    required this.chapter,
    required this.verseStart,
    required this.verseEnd,
    required this.readDate,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'book_index': bookIndex,
        'chapter': chapter,
        'verse_start': verseStart,
        'verse_end': verseEnd,
        'read_date': readDate,
      };

  factory ReadingEntry.fromMap(Map<String, dynamic> map) => ReadingEntry(
        id: map['id'] as int?,
        bookIndex: map['book_index'] as int,
        chapter: map['chapter'] as int,
        verseStart: map['verse_start'] as int,
        verseEnd: map['verse_end'] as int,
        readDate: map['read_date'] as String,
      );

  ReadingEntry copyWith({
    int? id,
    int? bookIndex,
    int? chapter,
    int? verseStart,
    int? verseEnd,
    String? readDate,
  }) =>
      ReadingEntry(
        id: id ?? this.id,
        bookIndex: bookIndex ?? this.bookIndex,
        chapter: chapter ?? this.chapter,
        verseStart: verseStart ?? this.verseStart,
        verseEnd: verseEnd ?? this.verseEnd,
        readDate: readDate ?? this.readDate,
      );

  @override
  String toString() =>
      'ReadingEntry($bookIndex, ch$chapter, v$verseStart-$verseEnd, $readDate)';

  @override
  bool operator ==(Object other) =>
      other is ReadingEntry &&
      bookIndex == other.bookIndex &&
      chapter == other.chapter &&
      verseStart == other.verseStart &&
      verseEnd == other.verseEnd &&
      readDate == other.readDate;

  @override
  int get hashCode =>
      Object.hash(bookIndex, chapter, verseStart, verseEnd, readDate);
}
