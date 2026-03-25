import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/bible_data.dart';
import '../data/reading_repository.dart';

/// Ring colour palette (blue tiers: unread → 1x → 2x → 3x+)
class RingColors {
  static const unread = Color(0xFF334155);     // slate-700
  static const once = Color(0xFF60A5FA);       // blue-400
  static const twice = Color(0xFF2563EB);      // blue-600
  static const threePlus = Color(0xFF1E3A8A);  // blue-900
}

/// Donut progress ring showing Bible reading coverage segmented by read-count.
class ProgressRing extends StatelessWidget {
  final ReadingStats stats;
  final VoidCallback? onTap;
  final bool showChapters;

  const ProgressRing({super.key, required this.stats, this.onTap, this.showChapters = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final double once;
    final double twice;
    final double threePlus;
    final int distinctCount;
    final int totalCount;
    final String unitLabel;

    if (showChapters) {
      final cs = stats.chapterStats;
      once = cs.once.toDouble();
      twice = cs.twice.toDouble();
      threePlus = cs.threePlus.toDouble();
      distinctCount = cs.total;
      totalCount = totalBibleChapters;
      unitLabel = 'chapters';
    } else {
      once = stats.readOnceCount.toDouble();
      twice = stats.readTwiceCount.toDouble();
      threePlus = stats.readThreePlusCount.toDouble();
      distinctCount = stats.totalDistinctVersesRead;
      totalCount = totalBibleVerses;
      unitLabel = 'verses';
    }

    // Guard against all-zero (first launch)
    final hasData = (once + twice + threePlus) > 0;

    // Only show read sectors (no unread/gray)
    final sections = [
      if (once > 0)
        PieChartSectionData(
          value: once,
          color: RingColors.once,
          radius: 28,
          showTitle: false,
        ),
      if (twice > 0)
        PieChartSectionData(
          value: twice,
          color: RingColors.twice,
          radius: 28,
          showTitle: false,
        ),
      if (threePlus > 0)
        PieChartSectionData(
          value: threePlus,
          color: RingColors.threePlus,
          radius: 28,
          showTitle: false,
        ),
    ];

    final ratio = hasData ? (distinctCount / totalCount * 100) : 0.0;
    final ratioText = '${ratio.toStringAsFixed(2)}% of the Bible';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            hasData
                ? PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 100,
                      sectionsSpace: 1.5,
                      startDegreeOffset: -90,
                    ),
                  )
                : SizedBox.expand(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: RingColors.unread,
                          width: 28,
                        ),
                      ),
                    ),
                  ),
            // Centre label
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ratioText,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$distinctCount $unitLabel read',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Legend row shown below the ring.
class RingLegend extends StatelessWidget {
  const RingLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _LegendDot(color: RingColors.once, label: 'Read once'),
        SizedBox(width: 16),
        _LegendDot(color: RingColors.twice, label: 'Read twice'),
        SizedBox(width: 16),
        _LegendDot(color: RingColors.threePlus, label: 'Read 3+ times'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
