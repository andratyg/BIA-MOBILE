import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gallery_provider.dart';
import '../../models/photo.dart';
import '../../theme.dart';
import '../../widgets/photo_grid_card.dart';
import 'photo_detail_sheet.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleryProvider>().fetchPhotos();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Consumer<GalleryProvider>(
        builder: (context, gallery, _) {
          return CustomScrollView(
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
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Gallery Tanaman',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Riwayat foto & hasil analisis',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stat cards
                    Row(
                      children: [
                        _StatCard(
                          label: 'Total Foto',
                          value: gallery.totalPhotos.toString(),
                          icon: Icons.photo_library_rounded,
                          color: VerdaticaTheme.statusBlue,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Teranalisis',
                          value: gallery.analyzedCount.toString(),
                          icon: Icons.check_circle_rounded,
                          color: VerdaticaTheme.statusGreen,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Terbaru',
                          value: gallery.latestPhoto != null
                              ? _formatDate(gallery.latestPhoto!.createdAt)
                              : '-',
                          icon: Icons.calendar_today_rounded,
                          color: VerdaticaTheme.statusOrange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    TextField(
                      controller: _searchCtrl,
                      onChanged: gallery.search,
                      decoration: InputDecoration(
                        hintText: 'Cari foto atau tanaman...',
                        hintStyle: const TextStyle(
                          color: VerdaticaTheme.textMuted,
                          fontSize: 13.5,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search_rounded, color: VerdaticaTheme.primary),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  gallery.search('');
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
              // Grid or states
              if (gallery.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: VerdaticaTheme.primary,
                      strokeWidth: 3,
                    ),
                  ),
                )
              else if (gallery.error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.wifi_off_rounded,
                              size: 40,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            gallery.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: VerdaticaTheme.textSecondary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => gallery.fetchPhotos(),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: VerdaticaTheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (gallery.photos.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: VerdaticaTheme.primarySurface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: VerdaticaTheme.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Icon(
                              Icons.photo_library_outlined,
                              size: 48,
                              color: VerdaticaTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum Ada Foto Tanaman',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: VerdaticaTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Gunakan menu Scan untuk mengambil foto tanaman\ndan melihat riwayat analisis di sini.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: VerdaticaTheme.textSecondary,
                              fontSize: 12.5,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final photo = gallery.photos[i];
                        return PhotoGridCard(
                          photo: photo,
                          onTap: () => _showDetail(context, photo),
                        );
                      },
                      childCount: gallery.photos.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, Photo photo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PhotoDetailSheet(photo: photo),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: VerdaticaTheme.textMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
