import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/reading_repository.dart';
import '../models/reading_entry.dart';

// ─── Date helpers ─────────────────────────────────────────────────────────────

String todayDateString() => DateFormat('yyyy-MM-dd').format(DateTime.now());

// ─── Reading stats provider ───────────────────────────────────────────────────

/// Provides aggregated [ReadingStats] from the database.
/// Invalidate this provider whenever the DB changes to trigger a refresh.
final readingStatsProvider =
    AsyncNotifierProvider<ReadingStatsNotifier, ReadingStats>(
  ReadingStatsNotifier.new,
);

class ReadingStatsNotifier extends AsyncNotifier<ReadingStats> {
  @override
  Future<ReadingStats> build() async =>
      ReadingRepository.instance.computeStats();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ReadingRepository.instance.computeStats(),
    );
  }
}

// ─── Today's entries provider ─────────────────────────────────────────────────

/// Today's reading entries (for display in the add-reading bottom sheet).
final todayEntriesProvider =
    AsyncNotifierProvider<TodayEntriesNotifier, List<ReadingEntry>>(
  TodayEntriesNotifier.new,
);

class TodayEntriesNotifier extends AsyncNotifier<List<ReadingEntry>> {
  @override
  Future<List<ReadingEntry>> build() async =>
      ReadingRepository.instance.fetchForDate(todayDateString());

  Future<void> addEntry(ReadingEntry entry) async {
    await ReadingRepository.instance.insertEntry(entry);
    // Refresh both today's list and overall stats
    state = await AsyncValue.guard(
      () => ReadingRepository.instance.fetchForDate(todayDateString()),
    );
    ref.invalidate(readingStatsProvider);
  }

  Future<void> removeEntry(int id) async {
    await ReadingRepository.instance.deleteEntry(id);
    state = await AsyncValue.guard(
      () => ReadingRepository.instance.fetchForDate(todayDateString()),
    );
    ref.invalidate(readingStatsProvider);
  }
}
