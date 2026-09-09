import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/photo.dart';
import '../../theme.dart';

class PhotoDetailSheet extends StatelessWidget {
  final Photo photo;

  const PhotoDetailSheet({super.key, required this.photo});

  String _formatDate(DateTime dt) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: VerdaticaTheme.cardBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      'Detail Analisis Tanaman',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: VerdaticaTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: photo.isAnalyzed
                            ? VerdaticaTheme.primaryLight
                            : const Color(0xFFFEF9C3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: photo.isAnalyzed
                              ? VerdaticaTheme.primary.withValues(alpha: 0.2)
                              : const Color(0xFFFDE047),
                        ),
                      ),
                      child: Text(
                        photo.isAnalyzed ? '✓ Teranalisis' : 'Pending',
                        style: TextStyle(
                          color: photo.isAnalyzed
                              ? VerdaticaTheme.primary
                              : VerdaticaTheme.statusYellow,
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: VerdaticaTheme.cardBorderSubtle, height: 1),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo container
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          photo.fullUrl,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 250,
                            color: VerdaticaTheme.primarySurface,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                color: VerdaticaTheme.textMuted,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Timestamp row
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: VerdaticaTheme.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(photo.createdAt),
                            style: const TextStyle(
                              color: VerdaticaTheme.textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Analysis Section
                      if (photo.isAnalyzed) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Hasil Diagnosis AI',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: VerdaticaTheme.textPrimary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              tooltip: 'Salin hasil analisis',
                              color: VerdaticaTheme.primary,
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: photo.analysis ?? ''));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Hasil analisis disalin ke clipboard!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: VerdaticaTheme.bgLight,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: VerdaticaTheme.cardBorder, width: 1.2),
                          ),
                          child: SelectableText(
                            photo.analysis!,
                            style: const TextStyle(
                              color: VerdaticaTheme.textPrimary,
                              fontSize: 14,
                              height: 1.65,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF9C3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFDE047)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.hourglass_empty_rounded,
                                  color: Color(0xFFD97706), size: 22),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Foto ini belum memiliki hasil analisis AI.',
                                  style: TextStyle(
                                    color: Color(0xFF92400E),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
