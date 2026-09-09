import 'package:flutter/material.dart';
import '../theme.dart';

class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String statusLabel;
  final Color statusColor;
  final Color iconColor;
  final IconData icon;
  final List<double> history;
  final Color cardAccent;
  final double minValue;
  final double maxValue;
  final String? subtitleLabel;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.statusLabel,
    required this.statusColor,
    required this.iconColor,
    required this.icon,
    required this.history,
    required this.cardAccent,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    this.subtitleLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          // Left solid colored box
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),

          // Right texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4F46E5), // Purple/Indigo
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                    if (subtitleLabel != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        subtitleLabel!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  static const int _maxBars = 16;
  final List<double> data;
  final Color color;
  final double minValue;
  final double maxValue;

  const _MiniBarChart({
    required this.data,
    required this.color,
    this.minValue = 0.0,
    this.maxValue = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil paling banyak N data terakhir
    final recentData = data.length > _maxBars
        ? data.sublist(data.length - _maxBars)
        : data;

    final activeCount = recentData.length;
    final totalSlots = _maxBars;
    final emptyCount = totalSlots - activeCount;

    const double widgetHeight = 32.0;
    const double minBarHeight = 3.0;
    const double maxBarHeight = 32.0;
    final double valueRange = (maxValue - minValue) <= 0 ? 1.0 : (maxValue - minValue);

    return SizedBox(
      height: widgetHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(totalSlots, (slotIndex) {
          final isSlotEmpty = slotIndex < emptyCount;

          if (isSlotEmpty) {
            // Slot kosong sebelum data masuk (placeholder minimal)
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Container(
                  height: minBarHeight,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          }

          final dataIndex = slotIndex - emptyCount;
          final val = recentData[dataIndex];
          final isNewest = dataIndex == activeCount - 1;

          // Hitung rasio proporsional terhadap batas sensor
          final ratio = ((val - minValue) / valueRange).clamp(0.0, 1.0);

          // Tinggi bar: saat nilai 0/minimal -> minBarHeight (3px), saat nilai max -> maxBarHeight (32px)
          final barHeight = minBarHeight + (ratio * (maxBarHeight - minBarHeight));

          // Gradasi opacity: data terlama ~0.30 hingga data terbaru 1.0
          final double opacity = activeCount <= 1
              ? 1.0
              : (0.30 + (0.70 * (dataIndex / (activeCount - 1)))).clamp(0.30, 1.0);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuad,
                height: barHeight,
                decoration: BoxDecoration(
                  color: isNewest ? color : color.withOpacity(opacity),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
