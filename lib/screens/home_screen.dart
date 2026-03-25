import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reading_plan_service.dart';
import '../data/reading_repository.dart';
import '../models/reading_entry.dart';
import '../providers/reading_providers.dart';
import '../widgets/add_reading_sheet.dart';
import '../widgets/progress_ring.dart';
import '../widgets/todays_reading_bar.dart';
import 'detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowPlanPrompt());
  }

  Future<void> _maybeShowPlanPrompt() async {
    if (!mounted) return;
    final show = await ReadingPlanService.shouldShowPrompt();
    if (!show || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('OTC Reading Plan 2026'),
        content: const Text(
          'Would you like to pre-load the OTC Reading Plan 2026 '
          'entries into your tracker?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No thanks'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, load it'),
          ),
        ],
      ),
    );

    await ReadingPlanService.markOffered();

    if (confirmed == true && mounted) {
      await ReadingPlanService.insertPlan();
      ref.invalidate(readingStatsProvider);
      ref.invalidate(todayEntriesProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(readingStatsProvider);
    final todayEntriesAsync = ref.watch(todayEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BibleLog'),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text('Error loading data: $e'),
        ),
        data: (stats) => _HomeBody(
          stats: stats,
          todayEntriesAsync: todayEntriesAsync,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddReadingSheet.show(context),
        tooltip: 'Add reading',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HomeBody extends StatefulWidget {
  final ReadingStats stats;
  final AsyncValue<List<ReadingEntry>> todayEntriesAsync;

  const _HomeBody({
    required this.stats,
    required this.todayEntriesAsync,
  });

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  bool _showChapters = false;

  @override
  Widget build(BuildContext context) {
    final todayBar = widget.todayEntriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (todayEntries) => todayEntries.isNotEmpty
          ? TodaysReadingBar(
              todayEntries: todayEntries,
              verseCounts: widget.stats.verseCounts,
            )
          : const SizedBox.shrink(),
    );

    final ring = ProgressRing(
      stats: widget.stats,
      showChapters: _showChapters,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DetailScreen()),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          todayBar,
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Verses')),
              ButtonSegment(value: true, label: Text('Chapters')),
            ],
            selected: {_showChapters},
            onSelectionChanged: (s) =>
                setState(() => _showChapters = s.first),
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(height: 16),
          ring,
          const SizedBox(height: 16),
          const RingLegend(),
          const SizedBox(height: 32),
          _QuickStats(stats: widget.stats, showChapters: _showChapters),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final ReadingStats stats;
  final bool showChapters;
  const _QuickStats({required this.stats, this.showChapters = false});

  @override
  Widget build(BuildContext context) {
    final cs = showChapters ? stats.chapterStats : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatTile(
            label: 'Read once',
            value: '${showChapters ? cs!.once : stats.readOnceCount}',
            color: const Color(0xFF60A5FA),
          ),
          _StatTile(
            label: 'Read twice',
            value: '${showChapters ? cs!.twice : stats.readTwiceCount}',
            color: const Color(0xFF2563EB),
          ),
          _StatTile(
            label: '3× or more',
            value: '${showChapters ? cs!.threePlus : stats.readThreePlusCount}',
            color: const Color(0xFF93C5FD),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatTile(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
