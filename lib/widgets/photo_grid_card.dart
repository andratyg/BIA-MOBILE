import 'package:flutter/material.dart';
import '../models/photo.dart';
import '../theme.dart';

class PhotoGridCard extends StatelessWidget {
  final Photo photo;
  final VoidCallback onTap;

  const PhotoGridCard({
    super.key,
    required this.photo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: VerdaticaTheme.cardBorder, width: 1.2),
            color: Colors.white,
            boxShadow: VerdaticaTheme.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: Image.network(
                  photo.fullUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: VerdaticaTheme.primarySurface,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        color: VerdaticaTheme.textMuted,
                        size: 32,
                      ),
                    ),
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: VerdaticaTheme.bgLight,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: VerdaticaTheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.75),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Status badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: photo.isAnalyzed
                        ? VerdaticaTheme.primary
                        : VerdaticaTheme.statusYellow,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        photo.isAnalyzed ? Icons.check_circle_rounded : Icons.schedule_rounded,
                        color: Colors.white,
                        size: 10,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        photo.isAnalyzed ? 'Teranalisis' : 'Pending',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Date
              Positioned(
                bottom: 8,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white70,
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatDate(photo.createdAt),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
