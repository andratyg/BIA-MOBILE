import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sensor_provider.dart';
import '../../theme.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Timer? _laporanTimer;
  final List<String> _activityLog = [];
  static const int _maxLog = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLaporanPolling();
    });
  }

  void _startLaporanPolling() {
    _fetchAndLog();
    _laporanTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchAndLog();
    });
  }

  Future<void> _fetchAndLog() async {
    if (!mounted) return;
    final sensor = context.read<SensorProvider>();
    await sensor.fetchSensor();
    if (!mounted) return;
    final latest = sensor.latest;
    if (latest != null) {
      final h = latest.timestamp.hour.toString().padLeft(2, '0');
      final m = latest.timestamp.minute.toString().padLeft(2, '0');
      final log =
          'Data diperbarui $h:$m (Suhu: ${latest.temperature.toStringAsFixed(1)}°C)';
      if (mounted) {
        setState(() {
          _activityLog.insert(0, log);
          if (_activityLog.length > _maxLog) {
            _activityLog.removeAt(_activityLog.length - 1);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _laporanTimer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '-';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<SensorProvider>(
      builder: (context, sensor, _) {
        final data = sensor.latest;
        final temp = data?.temperature ?? 0.0;
        final hum = data?.humidity ?? 0.0;
        final soil = data?.soilMoisture ?? 0.0;
        final history = sensor.history;

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: VerdaticaTheme.headerGradient,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Laporan Sensor',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Telemetri & Analitik Real-time',
                                  style: TextStyle(
                                    color: Color(0xFFBBF7D0),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // LIVE indicator badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: sensor.isLive
                                  ? Colors.white.withValues(alpha: 0.18)
                                  : Colors.red.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: sensor.isLive
                                        ? const Color(0xFF4ADE80)
                                        : const Color(0xFFF87171),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  sensor.isLive ? 'LIVE' : 'Offline',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Summary cards row
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Status Sistem',
                          value: sensor.isLive ? 'Online' : 'Offline',
                          icon: Icons.sensors_rounded,
                          color: sensor.isLive
                              ? VerdaticaTheme.statusGreen
                              : VerdaticaTheme.statusRed,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Update Terakhir',
                          value: _formatTime(sensor.lastUpdate),
                          icon: Icons.access_time_rounded,
                          color: VerdaticaTheme.statusBlue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Total Sampel',
                          value: '${history.length} Data',
                          icon: Icons.storage_rounded,
                          color: VerdaticaTheme.statusOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section Title: Indikator Sensor
                  const Text(
                    'Indikator Sensor & Ambang Batas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: VerdaticaTheme.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sensor progress cards
                  _SensorProgressCard(
                    title: 'Suhu Udara',
                    value: temp,
                    max: 50,
                    unit: '°C',
                    statusText: temp < 20 ? 'Sejuk' : (temp <= 33 ? 'Optimal (20-33°C)' : 'Tinggi (>33°C)'),
                    color: VerdaticaTheme.statusRed,
                    icon: Icons.thermostat_rounded,
                  ),
                  const SizedBox(height: 12),
                  _SensorProgressCard(
                    title: 'Kelembapan Udara',
                    value: hum,
                    max: 100,
                    unit: '%',
                    statusText: hum < 40 ? 'Kering (<40%)' : (hum <= 80 ? 'Optimal (40-80%)' : 'Lembap (>80%)'),
                    color: VerdaticaTheme.statusBlue,
                    icon: Icons.water_drop_rounded,
                  ),
                  const SizedBox(height: 12),
                  _SensorProgressCard(
                    title: 'Kelembapan Tanah',
                    value: soil,
                    max: 100,
                    unit: '%',
                    statusText: soil < 40 ? 'Perlu Disiram (<40%)' : (soil <= 70 ? 'Ideal (40-70%)' : 'Basah (>70%)'),
                    color: VerdaticaTheme.statusOrange,
                    icon: Icons.grass_rounded,
                  ),
                  const SizedBox(height: 24),

                  // Temperature Trend Chart
                  if (history.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: VerdaticaTheme.cardBorder, width: 1.2),
                        boxShadow: VerdaticaTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Tren Suhu Terkini',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: VerdaticaTheme.textPrimary,
                                ),
                              ),
                              Text(
                                '12 Titik Terakhir',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: VerdaticaTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _BarChart(data: history.map((h) => h.temperature).toList()),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Activity log Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: VerdaticaTheme.cardBorder, width: 1.2),
                      boxShadow: VerdaticaTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: VerdaticaTheme.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.history_rounded,
                                color: VerdaticaTheme.primary,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Log Aktivitas Telemetri',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: VerdaticaTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (_activityLog.isEmpty)
                          const Text(
                            'Menunggu sinkronisasi data sensor...',
                            style: TextStyle(
                              color: VerdaticaTheme.textMuted,
                              fontSize: 12.5,
                            ),
                          )
                        else
                          ...List.generate(_activityLog.length, (i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: i == 0 ? VerdaticaTheme.primary : VerdaticaTheme.textMuted,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _activityLog[i],
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: i == 0
                                            ? VerdaticaTheme.textPrimary
                                            : VerdaticaTheme.textSecondary,
                                        fontWeight: i == 0
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SensorProgressCard extends StatelessWidget {
  final String title;
  final double value;
  final double max;
  final String unit;
  final String statusText;
  final Color color;
  final IconData icon;

  const _SensorProgressCard({
    required this.title,
    required this.value,
    required this.max,
    required this.unit,
    required this.statusText,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value / max).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VerdaticaTheme.cardBorder, width: 1.2),
        boxShadow: VerdaticaTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: VerdaticaTheme.textPrimary,
                      ),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${value.toStringAsFixed(1)}$unit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: VerdaticaTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<double> data;

  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final chartData = data.length > 12 ? data.sublist(data.length - 12) : data;
    final maxVal = chartData.reduce((a, b) => a > b ? a : b);
    final minVal = chartData.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal) <= 0 ? 1.0 : (maxVal - minVal);

    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: chartData.asMap().entries.map((entry) {
          final i = entry.key;
          final v = entry.value;
          final normalized = ((v - minVal) / range).clamp(0.0, 1.0);
          final barH = 20 + normalized * 65;
          final isLast = i == chartData.length - 1;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isLast)
                    Text(
                      '${v.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: VerdaticaTheme.primary,
                      ),
                    ),
                  const SizedBox(height: 3),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: barH,
                    decoration: BoxDecoration(
                      gradient: isLast
                          ? VerdaticaTheme.primaryGradient
                          : LinearGradient(
                              colors: [
                                const Color(0xFFEF4444).withValues(alpha: 0.35),
                                const Color(0xFFEF4444).withValues(alpha: 0.65),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VerdaticaTheme.cardBorder, width: 1.2),
        boxShadow: VerdaticaTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: VerdaticaTheme.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: VerdaticaTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
