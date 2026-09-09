import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sensor_provider.dart';
import '../../theme.dart';
import '../../widgets/sensor_card.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SensorProvider>().startPolling(intervalSeconds: 2);
    });
  }

  @override
  void dispose() {
    context.read<SensorProvider>().stopPolling();
    super.dispose();
  }

  void _showLogoutDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar dari Akun?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun Verdatica?',
          style: TextStyle(color: VerdaticaTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: VerdaticaTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VerdaticaTheme.statusRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Ya, Keluar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi ☀️';
    if (hour >= 11 && hour < 15) return 'Selamat Siang 🌤️';
    if (hour >= 15 && hour < 18) return 'Selamat Sore ⛅';
    return 'Selamat Malam 🌙';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userName = context.watch<AuthProvider>().userName;
    final displayName = userName.isNotEmpty ? userName : 'Petani Pintar';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'V';

    return Scaffold(
      backgroundColor: const Color(0xFFEAF7EC), // Pastel Mint Green
      body: SafeArea(
        bottom: false,
        child: Consumer<SensorProvider>(
          builder: (context, sensor, _) {
            final data = sensor.latest;
            final history = sensor.history;
            final temp = data?.temperature ?? 34.0;
            final hum = data?.humidity ?? 50.0;
            final soil = data?.soilMoisture ?? 34.0;

            return RefreshIndicator(
              color: VerdaticaTheme.primary,
              backgroundColor: Colors.white,
              onRefresh: sensor.fetchSensor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar Header
                    Row(
                      children: [
                        // User Profile Avatar with Online Status
                        GestureDetector(
                          onTap: () => _showLogoutDialog(context),
                          child: Stack(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF15803D), Color(0xFF10B981)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF15803D).withValues(alpha: 0.28),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 1,
                                right: 1,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Greeting & User Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getGreeting(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4B6E59),
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F3E26),
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Notification Bell
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tidak ada notifikasi baru.'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFD1E7D6),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Color(0xFF1E293B),
                                  size: 21,
                                ),
                                Positioned(
                                  top: 9,
                                  right: 9,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Dark IoT Scanner Action Box
                        GestureDetector(
                          onTap: () => widget.onNavigateTab?.call(1), // Open Camera/Scan
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.center_focus_strong_rounded,
                                color: Color(0xFF22C55E),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Green Hero Banner Card ("dashboard")
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E676), Color(0xFF10B981)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Stack(
                          children: [
                            // Decorative White Stroke Waves
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _BannerWavePainter(),
                              ),
                            ),

                            // Content inside banner
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title "dashboard"
                                  const Text(
                                    'dashboard',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'selamat datang di verdatica!!!!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Aplikasi pembantu petani modern',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 22),

                                  // Bottom Row of Banner
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // 3 Metric Badges
                                      Row(
                                        children: [
                                          _buildBannerBadge(
                                            color: const Color(0xFFDC2626),
                                            icon: Icons.thermostat_rounded,
                                          ),
                                          const SizedBox(width: 8),
                                          _buildBannerBadge(
                                            color: const Color(0xFF2563EB),
                                            icon: Icons.water_drop_rounded,
                                          ),
                                          const SizedBox(width: 8),
                                          _buildBannerBadge(
                                            color: const Color(0xFFD97706),
                                            icon: Icons.eco_rounded,
                                          ),
                                        ],
                                      ),

                                      // Smart Farm Thumbnail
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          width: 124,
                                          height: 76,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.white.withValues(alpha: 0.8),
                                              width: 2,
                                            ),
                                          ),
                                          child: Image.asset(
                                            'assets/images/farm_banner.jpg',
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: Colors.white.withValues(alpha: 0.3),
                                              child: const Icon(
                                                Icons.grass_rounded,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sensor 1: SUHU
                    SensorCard(
                      title: 'SUHU',
                      value: temp.toStringAsFixed(0),
                      unit: '°C',
                      subtitleLabel: 'celsius',
                      statusLabel: 'Optimal',
                      statusColor: const Color(0xFFDC2626),
                      iconColor: const Color(0xFFC81E1E),
                      icon: Icons.thermostat_rounded,
                      history: history.map((h) => h.temperature).toList(),
                      cardAccent: const Color(0xFFDC2626),
                      minValue: 0.0,
                      maxValue: 50.0,
                    ),
                    const SizedBox(height: 14),

                    // Sensor 2: KELEMBAPAN UDARA
                    SensorCard(
                      title: 'KELEMBAPAN UDARA',
                      value: hum.toStringAsFixed(0),
                      unit: '%',
                      subtitleLabel: 'RH',
                      statusLabel: 'Ideal',
                      statusColor: const Color(0xFF2563EB),
                      iconColor: const Color(0xFF2563EB),
                      icon: Icons.water_drop_rounded,
                      history: history.map((h) => h.humidity).toList(),
                      cardAccent: const Color(0xFF2563EB),
                      minValue: 0.0,
                      maxValue: 100.0,
                    ),
                    const SizedBox(height: 14),

                    // Sensor 3: KELEMBAPAN TANAH
                    SensorCard(
                      title: 'KELEMBAPAN TANAH',
                      value: soil.toStringAsFixed(0),
                      unit: '%',
                      subtitleLabel: 'Moisture',
                      statusLabel: 'Optimal',
                      statusColor: const Color(0xFFD97706),
                      iconColor: const Color(0xFFD97706),
                      icon: Icons.eco_rounded,
                      history: history.map((h) => h.soilMoisture).toList(),
                      cardAccent: const Color(0xFFD97706),
                      minValue: 0.0,
                      maxValue: 100.0,
                    ),
                    const SizedBox(height: 22),

                    // Floating Action Button: "konsultasi ke pakar AI"
                    Center(
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        elevation: 1,
                        shadowColor: Colors.black.withValues(alpha: 0.1),
                        child: InkWell(
                          onTap: () => widget.onNavigateTab?.call(4), // Open Chat AI Tab
                          borderRadius: BorderRadius.circular(22),
                          splashColor: const Color(0xFF22C55E).withValues(alpha: 0.15),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'konsultasi ke pakar AI',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      color: Colors.black87,
                                      size: 20,
                                    ),
                                    SizedBox(height: 1),
                                    Text(
                                      'chat ai',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBannerBadge({
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

class _BannerWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    // Top right curve wave
    path.moveTo(size.width * 0.45, 0);
    path.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.15,
      size.width * 0.95,
      size.height * 0.05,
    );
    path.quadraticBezierTo(
      size.width * 1.05,
      size.height * 0.25,
      size.width * 0.92,
      size.height * 0.45,
    );

    // Bottom left curve
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.85,
      size.width * 0.55,
      size.height,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
