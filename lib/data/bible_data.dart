/// Static Bible structure: 66 books, verse counts per chapter.
/// No Bible text is stored — only structural data used for navigation
/// and verse-range expansion.
library;

class BibleBook {
  final int index; // 0-based, 0 = Genesis, 65 = Revelation
  final String name;
  final String abbreviation;
  final bool isOldTestament;

  /// List of verse counts, one entry per chapter (1-based indexing: [0] unused, [1] = ch1).
  /// We store index 0 as 0 for convenience so `versesInChapter[chapterNumber]` works directly.
  final List<int> versesPerChapter;

  const BibleBook({
    required this.index,
    required this.name,
    required this.abbreviation,
    required this.isOldTestament,
    required this.versesPerChapter,
  });

  int get chapterCount => versesPerChapter.length - 1; // subtract the leading 0

  int get totalVerses =>
      versesPerChapter.fold(0, (sum, v) => sum + v); // leading 0 is harmless

  int versesInChapter(int chapter) => versesPerChapter[chapter];
}

/// The canonical 66-book Protestant Bible.
/// versesPerChapter[0] is always 0 (unused placeholder so chapter numbers are 1-based).
const List<BibleBook> bibleBooks = [
  // ─── OLD TESTAMENT ───────────────────────────────────────────────────────

  BibleBook(
    index: 0,
    name: 'Genesis',
    abbreviation: 'Gen',
    isOldTestament: true,
    versesPerChapter: [
      0, 31, 25, 24, 26, 32, 22, 24, 22, 29, 32, // 1-10
      32, 20, 18, 24, 21, 16, 27, 33, 38, 18, // 11-20
      34, 24, 20, 67, 34, 35, 46, 22, 35, 43, // 21-30
      55, 32, 20, 31, 29, 43, 36, 30, 23, 23, // 31-40
      57, 38, 34, 34, 28, 34, 31, 22, 33, 26, // 41-50
    ],
  ),
  BibleBook(
    index: 1,
    name: 'Exodus',
    abbreviation: 'Exo',
    isOldTestament: true,
    versesPerChapter: [
      0, 22, 25, 22, 31, 23, 30, 25, 32, 35, 29, // 1-10
      10, 51, 22, 31, 27, 36, 16, 27, 25, 26, // 11-20
      36, 31, 33, 18, 40, 37, 21, 43, 46, 38, // 21-30
      18, 35, 23, 35, 35, 38, 29, 31, 43, 38, // 31-40
    ],
  ),
  BibleBook(
    index: 2,
    name: 'Leviticus',
    abbreviation: 'Lev',
    isOldTestament: true,
    versesPerChapter: [
      0, 17, 16, 17, 35, 19, 30, 38, 36, 24, 20, // 1-10
      47, 8, 59, 57, 33, 34, 16, 30, 37, 27, // 11-20
      20, 33, 44, 23, 55, 46, 34, // 21-27
    ],
  ),
  BibleBook(
    index: 3,
    name: 'Numbers',
    abbreviation: 'Num',
    isOldTestament: true,
    versesPerChapter: [
      0, 54, 34, 51, 49, 31, 27, 89, 26, 23, 36, // 1-10
      35, 16, 33, 45, 41, 50, 13, 32, 22, 29, // 11-20
      35, 41, 30, 25, 18, 65, 23, 31, 40, 16, // 21-30
      54, 42, 56, 29, 34, 13, // 31-36
    ],
  ),
  BibleBook(
    index: 4,
    name: 'Deuteronomy',
    abbreviation: 'Deu',
    isOldTestament: true,
    versesPerChapter: [
      0, 46, 37, 29, 49, 33, 25, 26, 20, 29, 22, // 1-10
      32, 32, 18, 29, 23, 22, 20, 22, 21, 20, // 11-20
      23, 30, 25, 22, 19, 19, 26, 68, 29, 20, // 21-30
      30, 52, 29, 12, // 31-34
    ],
  ),
  BibleBook(
    index: 5,
    name: 'Joshua',
    abbreviation: 'Jos',
    isOldTestament: true,
    versesPerChapter: [
      0, 18, 24, 17, 24, 15, 27, 26, 35, 27, 43, // 1-10
      23, 24, 33, 15, 63, 10, 18, 28, 51, 9, // 11-20
      45, 34, 16, 33, // 21-24
    ],
  ),
  BibleBook(
    index: 6,
    name: 'Judges',
    abbreviation: 'Jdg',
    isOldTestament: true,
    versesPerChapter: [
      0, 36, 23, 31, 24, 31, 40, 25, 35, 57, 18, // 1-10
      40, 15, 25, 20, 20, 31, 13, 31, 30, 48, // 11-20
      25, // 21
    ],
  ),
  BibleBook(
    index: 7,
    name: 'Ruth',
    abbreviation: 'Rut',
    isOldTestament: true,
    versesPerChapter: [0, 22, 23, 18, 22],
  ),
  BibleBook(
    index: 8,
    name: '1 Samuel',
    abbreviation: '1Sa',
    isOldTestament: true,
    versesPerChapter: [
      0, 28, 36, 21, 22, 12, 21, 17, 22, 27, 27, // 1-10
      15, 25, 23, 52, 35, 23, 58, 30, 24, 42, // 11-20
      15, 23, 29, 22, 44, 25, 12, 25, 11, 31, // 21-30
      13, // 31
    ],
  ),
  BibleBook(
    index: 9,
    name: '2 Samuel',
    abbreviation: '2Sa',
    isOldTestament: true,
    versesPerChapter: [
      0, 27, 32, 39, 12, 25, 23, 29, 18, 13, 19, // 1-10
      27, 31, 39, 33, 37, 23, 29, 33, 43, 26, // 11-20
      22, 51, 39, 25, // 21-24
    ],
  ),
  BibleBook(
    index: 10,
    name: '1 Kings',
    abbreviation: '1Ki',
    isOldTestament: true,
    versesPerChapter: [
      0, 53, 46, 28, 34, 18, 38, 51, 66, 28, 29, // 1-10
      43, 33, 34, 31, 34, 34, 24, 46, 21, 43, // 11-20
      29, 53, // 21-22
    ],
  ),
  BibleBook(
    index: 11,
    name: '2 Kings',
    abbreviation: '2Ki',
    isOldTestament: true,
    versesPerChapter: [
      0, 18, 25, 27, 44, 27, 33, 20, 29, 37, 36, // 1-10
      21, 21, 25, 29, 38, 20, 41, 37, 37, 21, // 11-20
      26, 20, 37, 20, 30, // 21-25
    ],
  ),
  BibleBook(
    index: 12,
    name: '1 Chronicles',
    abbreviation: '1Ch',
    isOldTestament: true,
    versesPerChapter: [
      0, 54, 55, 24, 43, 26, 81, 40, 40, 44, 14, // 1-10
      47, 40, 14, 17, 29, 43, 27, 17, 19, 8, // 11-20
      30, 19, 32, 31, 31, 32, 34, 21, 30, // 21-29
    ],
  ),
  BibleBook(
    index: 13,
    name: '2 Chronicles',
    abbreviation: '2Ch',
    isOldTestament: true,
    versesPerChapter: [
      0, 17, 18, 17, 22, 14, 42, 22, 18, 31, 19, // 1-10
      23, 16, 22, 15, 19, 14, 19, 34, 11, 37, // 11-20
      20, 12, 21, 27, 28, 23, 9, 27, 36, 27, // 21-30
      21, 33, 25, 33, 27, 23, // 31-36
    ],
  ),
  BibleBook(
    index: 14,
    name: 'Ezra',
    abbreviation: 'Ezr',
    isOldTestament: true,
    versesPerChapter: [0, 11, 70, 13, 24, 17, 22, 28, 36, 15, 44],
  ),
  BibleBook(
    index: 15,
    name: 'Nehemiah',
    abbreviation: 'Neh',
    isOldTestament: true,
    versesPerChapter: [
      0, 11, 20, 32, 23, 19, 19, 73, 18, 38, 39, // 1-10
      36, 47, 31, // 11-13
    ],
  ),
  BibleBook(
    index: 16,
    name: 'Esther',
    abbreviation: 'Est',
    isOldTestament: true,
    versesPerChapter: [0, 22, 23, 15, 17, 14, 14, 10, 17, 32, 3],
  ),
  BibleBook(
    index: 17,
    name: 'Job',
    abbreviation: 'Job',
    isOldTestament: true,
    versesPerChapter: [
      0, 22, 13, 26, 21, 27, 30, 21, 22, 35, 22, // 1-10
      20, 25, 28, 22, 35, 22, 16, 21, 29, 29, // 11-20
      34, 30, 17, 25, 6, 14, 23, 28, 25, 31, // 21-30
      40, 22, 33, 37, 16, 33, 24, 41, 30, 24, // 31-40
      34, 17, // 41-42
    ],
  ),
  BibleBook(
    index: 18,
    name: 'Psalms',
    abbreviation: 'Psa',
    isOldTestament: true,
    versesPerChapter: [
      0, 6, 12, 8, 8, 12, 10, 17, 9, 20, 18, // 1-10
      7, 8, 6, 7, 5, 11, 15, 50, 14, 9, // 11-20
      13, 31, 6, 10, 22, 12, 14, 9, 11, 12, // 21-30
      24, 11, 22, 22, 28, 12, 40, 22, 13, 17, // 31-40
      13, 11, 5, 26, 17, 11, 9, 14, 20, 23, // 41-50
      19, 9, 6, 7, 23, 13, 11, 11, 17, 12, // 51-60
      8, 12, 11, 10, 13, 20, 7, 35, 36, 5, // 61-70
      24, 20, 28, 23, 10, 12, 20, 72, 13, 19, // 71-80
      16, 8, 18, 12, 13, 17, 7, 18, 52, 17, // 81-90
      16, 15, 5, 23, 11, 13, 12, 9, 9, 5, // 91-100
      8, 28, 22, 35, 45, 48, 43, 13, 31, 7, // 101-110
      10, 10, 9, 8, 18, 19, 2, 29, 176, 7, // 111-120
      8, 9, 4, 8, 5, 6, 5, 6, 8, 8, // 121-130
      3, 18, 3, 3, 21, 26, 9, 8, 24, 13, // 131-140
      10, 7, 12, 15, 21, 10, 20, 14, 9, 6, // 141-150
    ],
  ),
  BibleBook(
    index: 19,
    name: 'Proverbs',
    abbreviation: 'Pro',
    isOldTestament: true,
    versesPerChapter: [
      0, 33, 22, 35, 27, 23, 35, 27, 36, 18, 32, // 1-10
      31, 28, 25, 35, 33, 33, 28, 24, 29, 30, // 11-20
      31, 29, 35, 34, 28, 28, 27, 28, 27, 33, // 21-30
      31, // 31
    ],
  ),
  BibleBook(
    index: 20,
    name: 'Ecclesiastes',
    abbreviation: 'Ecc',
    isOldTestament: true,
    versesPerChapter: [0, 18, 26, 22, 16, 20, 12, 29, 17, 18, 20, 10, 14],
  ),
  BibleBook(
    index: 21,
    name: 'Song of Solomon',
    abbreviation: 'Son',
    isOldTestament: true,
    versesPerChapter: [0, 17, 17, 11, 16, 16, 13, 13, 14],
  ),
  BibleBook(
    index: 22,
    name: 'Isaiah',
    abbreviation: 'Isa',
    isOldTestament: true,
    versesPerChapter: [
      0, 31, 22, 26, 6, 30, 13, 25, 22, 21, 34, // 1-10
      16, 6, 22, 32, 9, 14, 14, 7, 25, 6, // 11-20
      17, 25, 18, 23, 12, 21, 13, 29, 24, 33, // 21-30
      9, 20, 24, 17, 10, 22, 38, 22, 8, 31, // 31-40
      29, 25, 28, 28, 25, 13, 15, 22, 26, 11, // 41-50
      23, 15, 12, 17, 13, 12, 21, 14, 21, 22, // 51-60
      11, 12, 19, 12, 25, 24, // 61-66
    ],
  ),
  BibleBook(
    index: 23,
    name: 'Jeremiah',
    abbreviation: 'Jer',
    isOldTestament: true,
    versesPerChapter: [
      0, 19, 37, 25, 31, 31, 30, 34, 22, 26, 25, // 1-10
      23, 17, 27, 22, 21, 21, 27, 23, 15, 18, // 11-20
      14, 30, 40, 10, 38, 24, 22, 17, 32, 24, // 21-30
      40, 44, 26, 22, 19, 32, 20, 28, 18, 16, // 31-40
      18, 22, 13, 30, 5, 28, 7, 47, 39, 46, // 41-50
      64, 34, // 51-52
    ],
  ),
  BibleBook(
    index: 24,
    name: 'Lamentations',
    abbreviation: 'Lam',
    isOldTestament: true,
    versesPerChapter: [0, 22, 22, 66, 22, 22],
  ),
  BibleBook(
    index: 25,
    name: 'Ezekiel',
    abbreviation: 'Eze',
    isOldTestament: true,
    versesPerChapter: [
      0, 28, 10, 27, 17, 17, 14, 27, 18, 11, 22, // 1-10
      25, 28, 23, 23, 8, 63, 24, 32, 14, 49, // 11-20
      32, 31, 49, 27, 17, 21, 36, 26, 21, 26, // 21-30
      18, 32, 33, 31, 15, 38, 28, 23, 29, 49, // 31-40
      26, 20, 27, 31, 25, 24, 23, 35, // 41-48
    ],
  ),
  BibleBook(
    index: 26,
    name: 'Daniel',
    abbreviation: 'Dan',
    isOldTestament: true,
    versesPerChapter: [0, 21, 49, 30, 37, 31, 28, 28, 27, 27, 21, 45, 13],
  ),
  BibleBook(
    index: 27,
    name: 'Hosea',
    abbreviation: 'Hos',
    isOldTestament: true,
    versesPerChapter: [0, 11, 23, 5, 19, 15, 11, 16, 14, 17, 15, 12, 14, 16, 9],
  ),
  BibleBook(
    index: 28,
    name: 'Joel',
    abbreviation: 'Joe',
    isOldTestament: true,
    versesPerChapter: [0, 20, 32, 21],
  ),
  BibleBook(
    index: 29,
    name: 'Amos',
    abbreviation: 'Amo',
    isOldTestament: true,
    versesPerChapter: [0, 15, 16, 15, 13, 27, 14, 17, 14, 15],
  ),
  BibleBook(
    index: 30,
    name: 'Obadiah',
    abbreviation: 'Oba',
    isOldTestament: true,
    versesPerChapter: [0, 21],
  ),
  BibleBook(
    index: 31,
    name: 'Jonah',
    abbreviation: 'Jon',
    isOldTestament: true,
    versesPerChapter: [0, 17, 10, 10, 11],
  ),
  BibleBook(
    index: 32,
    name: 'Micah',
    abbreviation: 'Mic',
    isOldTestament: true,
    versesPerChapter: [0, 16, 13, 12, 13, 15, 16, 20],
  ),
  BibleBook(
    index: 33,
    name: 'Nahum',
    abbreviation: 'Nah',
    isOldTestament: true,
    versesPerChapter: [0, 15, 13, 19],
  ),
  BibleBook(
    index: 34,
    name: 'Habakkuk',
    abbreviation: 'Hab',
    isOldTestament: true,
    versesPerChapter: [0, 17, 20, 19],
  ),
  BibleBook(
    index: 35,
    name: 'Zephaniah',
    abbreviation: 'Zep',
    isOldTestament: true,
    versesPerChapter: [0, 18, 15, 20],
  ),
  BibleBook(
    index: 36,
    name: 'Haggai',
    abbreviation: 'Hag',
    isOldTestament: true,
    versesPerChapter: [0, 15, 23],
  ),
  BibleBook(
    index: 37,
    name: 'Zechariah',
    abbreviation: 'Zec',
    isOldTestament: true,
    versesPerChapter: [
      0, 21, 13, 10, 14, 11, 15, 14, 23, 17, 12, // 1-10
      17, 14, 9, 21, // 11-14
    ],
  ),
  BibleBook(
    index: 38,
    name: 'Malachi',
    abbreviation: 'Mal',
    isOldTestament: true,
    versesPerChapter: [0, 14, 17, 18, 6],
  ),

  // ─── NEW TESTAMENT ───────────────────────────────────────────────────────

  BibleBook(
    index: 39,
    name: 'Matthew',
    abbreviation: 'Mat',
    isOldTestament: false,
    versesPerChapter: [
      0, 25, 23, 17, 25, 48, 34, 29, 34, 38, 42, // 1-10
      14, 50, 58, 36, 39, 28, 27, 35, 30, 34, // 11-20
      46, 46, 39, 51, 46, 75, 66, 20, // 21-28
    ],
  ),
  BibleBook(
    index: 40,
    name: 'Mark',
    abbreviation: 'Mar',
    isOldTestament: false,
    versesPerChapter: [
      0, 45, 28, 35, 41, 43, 56, 37, 38, 50, 52, // 1-10
      33, 44, 37, 72, 47, 20, // 11-16
    ],
  ),
  BibleBook(
    index: 41,
    name: 'Luke',
    abbreviation: 'Luk',
    isOldTestament: false,
    versesPerChapter: [
      0, 80, 52, 38, 44, 39, 49, 50, 56, 62, 42, // 1-10
      54, 59, 35, 35, 32, 31, 37, 43, 48, 47, // 11-20
      38, 71, 56, 53, // 21-24
    ],
  ),
  BibleBook(
    index: 42,
    name: 'John',
    abbreviation: 'Joh',
    isOldTestament: false,
    versesPerChapter: [
      0, 51, 25, 36, 54, 47, 71, 53, 59, 41, 42, // 1-10
      57, 50, 38, 31, 27, 33, 26, 40, 42, 31, // 11-20
      25, // 21
    ],
  ),
  BibleBook(
    index: 43,
    name: 'Acts',
    abbreviation: 'Act',
    isOldTestament: false,
    versesPerChapter: [
      0, 26, 47, 26, 37, 42, 15, 60, 40, 43, 48, // 1-10
      30, 25, 52, 28, 41, 40, 34, 28, 41, 38, // 11-20
      40, 30, 35, 27, 27, 32, 44, 31, // 21-28
    ],
  ),
  BibleBook(
    index: 44,
    name: 'Romans',
    abbreviation: 'Rom',
    isOldTestament: false,
    versesPerChapter: [
      0, 32, 29, 31, 25, 21, 23, 25, 39, 33, 21, // 1-10
      36, 21, 14, 26, 33, 27, // 11-16
    ],
  ),
  BibleBook(
    index: 45,
    name: '1 Corinthians',
    abbreviation: '1Co',
    isOldTestament: false,
    versesPerChapter: [
      0, 31, 16, 23, 21, 13, 20, 40, 13, 27, 33, // 1-10
      34, 31, 13, 40, 58, 24, // 11-16
    ],
  ),
  BibleBook(
    index: 46,
    name: '2 Corinthians',
    abbreviation: '2Co',
    isOldTestament: false,
    versesPerChapter: [
      0, 24, 17, 18, 18, 21, 18, 16, 24, 15, 18, // 1-10
      33, 21, 14, // 11-13
    ],
  ),
  BibleBook(
    index: 47,
    name: 'Galatians',
    abbreviation: 'Gal',
    isOldTestament: false,
    versesPerChapter: [0, 24, 21, 29, 31, 26, 18],
  ),
  BibleBook(
    index: 48,
    name: 'Ephesians',
    abbreviation: 'Eph',
    isOldTestament: false,
    versesPerChapter: [0, 23, 22, 21, 32, 33, 24],
  ),
  BibleBook(
    index: 49,
    name: 'Philippians',
    abbreviation: 'Php',
    isOldTestament: false,
    versesPerChapter: [0, 30, 30, 21, 23],
  ),
  BibleBook(
    index: 50,
    name: 'Colossians',
    abbreviation: 'Col',
    isOldTestament: false,
    versesPerChapter: [0, 29, 23, 25, 18],
  ),
  BibleBook(
    index: 51,
    name: '1 Thessalonians',
    abbreviation: '1Th',
    isOldTestament: false,
    versesPerChapter: [0, 10, 20, 13, 18, 28],
  ),
  BibleBook(
    index: 52,
    name: '2 Thessalonians',
    abbreviation: '2Th',
    isOldTestament: false,
    versesPerChapter: [0, 12, 17, 18],
  ),
  BibleBook(
    index: 53,
    name: '1 Timothy',
    abbreviation: '1Ti',
    isOldTestament: false,
    versesPerChapter: [0, 20, 15, 16, 16, 25, 21],
  ),
  BibleBook(
    index: 54,
    name: '2 Timothy',
    abbreviation: '2Ti',
    isOldTestament: false,
    versesPerChapter: [0, 18, 26, 17, 22],
  ),
  BibleBook(
    index: 55,
    name: 'Titus',
    abbreviation: 'Tit',
    isOldTestament: false,
    versesPerChapter: [0, 16, 15, 15],
  ),
  BibleBook(
    index: 56,
    name: 'Philemon',
    abbreviation: 'Phm',
    isOldTestament: false,
    versesPerChapter: [0, 25],
  ),
  BibleBook(
    index: 57,
    name: 'Hebrews',
    abbreviation: 'Heb',
    isOldTestament: false,
    versesPerChapter: [
      0, 14, 18, 19, 16, 14, 20, 28, 13, 28, 39, // 1-10
      40, 29, 25, // 11-13
    ],
  ),
  BibleBook(
    index: 58,
    name: 'James',
    abbreviation: 'Jam',
    isOldTestament: false,
    versesPerChapter: [0, 27, 26, 18, 17, 20],
  ),
  BibleBook(
    index: 59,
    name: '1 Peter',
    abbreviation: '1Pe',
    isOldTestament: false,
    versesPerChapter: [0, 25, 25, 22, 19, 14],
  ),
  BibleBook(
    index: 60,
    name: '2 Peter',
    abbreviation: '2Pe',
    isOldTestament: false,
    versesPerChapter: [0, 21, 22, 18],
  ),
  BibleBook(
    index: 61,
    name: '1 John',
    abbreviation: '1Jo',
    isOldTestament: false,
    versesPerChapter: [0, 10, 29, 24, 21, 21],
  ),
  BibleBook(
    index: 62,
    name: '2 John',
    abbreviation: '2Jo',
    isOldTestament: false,
    versesPerChapter: [0, 13],
  ),
  BibleBook(
    index: 63,
    name: '3 John',
    abbreviation: '3Jo',
    isOldTestament: false,
    versesPerChapter: [0, 14],
  ),
  BibleBook(
    index: 64,
    name: 'Jude',
    abbreviation: 'Jud',
    isOldTestament: false,
    versesPerChapter: [0, 25],
  ),
  BibleBook(
    index: 65,
    name: 'Revelation',
    abbreviation: 'Rev',
    isOldTestament: false,
    versesPerChapter: [
      0, 20, 29, 22, 11, 14, 17, 17, 13, 21, 11, // 1-10
      19, 17, 18, 20, 8, 21, 18, 24, 21, 15, // 11-20
      27, 21, // 21-22
    ],
  ),
];

/// Total number of verses in this structural dataset.
const int totalBibleVerses = 31084;

/// Total number of chapters in the Protestant Bible.
const int totalBibleChapters = 1189;

/// Returns the [BibleBook] for a given 0-based book index.
BibleBook bookAt(int index) => bibleBooks[index];

/// Expands a passage range to a flat list of (bookIndex, chapter, verse) records.
/// verseStart and verseEnd are inclusive and 1-based.
List<({int bookIndex, int chapter, int verse})> expandPassage({
  required int bookIndex,
  required int chapter,
  required int verseStart,
  required int verseEnd,
}) {
  final result = <({int bookIndex, int chapter, int verse})>[];
  for (int v = verseStart; v <= verseEnd; v++) {
    result.add((bookIndex: bookIndex, chapter: chapter, verse: v));
  }
  return result;
}
