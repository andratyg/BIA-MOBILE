import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../theme.dart';
import '../../widgets/gradient_button.dart';

class FindPhisikScreen extends StatefulWidget {
  const FindPhisikScreen({super.key});

  @override
  State<FindPhisikScreen> createState() => _FindPhisikScreenState();
}

class _FindPhisikScreenState extends State<FindPhisikScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  Uint8List? _imageBytes;
  bool _isAnalyzing = false;
  String? _analysisResult;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _imageFile = photo;
          _imageBytes = bytes;
          _analysisResult = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengakses media. Pastikan izin kamera/galeri sudah diberikan.';
      });
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pilih Sumber Foto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: VerdaticaTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ambil foto baru atau pilih dari galeri perangkat',
                  style: TextStyle(
                    fontSize: 13,
                    color: VerdaticaTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _SourceTile(
                        icon: Icons.camera_alt_rounded,
                        title: 'Kamera',
                        subtitle: 'Potret langsung',
                        color: VerdaticaTheme.primary,
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SourceTile(
                        icon: Icons.photo_library_rounded,
                        title: 'Galeri',
                        subtitle: 'Pilih dari album',
                        color: VerdaticaTheme.statusBlue,
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null || _imageBytes == null) return;
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          _imageBytes!,
          filename: _imageFile!.name.isNotEmpty ? _imageFile!.name : 'plant_photo.png',
        ),
      });

      final response = await ApiService.instance.postMultipart(
        ApiConfig.analyzeImage,
        formData,
      );

      final result = response.data;
      if (result['success'] == true) {
        final analysisText = result['analysis'] ?? (result['data'] is Map ? result['data']['analysis'] : null);
        setState(() {
          _analysisResult = analysisText as String? ?? 'Analisis selesai.';
          _isAnalyzing = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Analisis gagal. Coba lagi.';
          _isAnalyzing = false;
        });
      }
    } on DioException catch (e) {
      String message = 'Koneksi ke server gagal. Periksa internet.';
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map;
        final detail = data['error_detail'];
        if (detail is Map && detail['status'] == 'RESOURCE_EXHAUSTED') {
          message = 'Kuota Gemini AI di server sedang habis (Rate Limit). Silakan tunggu sebentar atau perbarui API Key di server Railway.';
        } else {
          message = data['message'] ?? message;
        }
      }
      setState(() {
        _errorMessage = message;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan. Coba lagi.';
        _isAnalyzing = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _imageFile = null;
      _imageBytes = null;
      _analysisResult = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
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
                          'Find Phisik',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Deteksi kondisi tanaman via foto',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Image preview or camera prompt
                if (_imageFile == null) _buildCameraPrompt(),
                if (_imageFile != null) _buildImagePreview(),
                const SizedBox(height: 16),
                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFFDC2626), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: Color(0xFFDC2626), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Action buttons
                if (_imageFile != null && _analysisResult == null) ...
                  [
                    const SizedBox(height: 16),
                    if (_isAnalyzing)
                      _buildAnalyzingLoader()
                    else ...
                      [
                        GradientButton(
                          text: 'Kirim & Analisis',
                          icon: Icons.biotech_rounded,
                          onPressed: _analyzeImage,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _showImageSourcePicker,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Pilih Foto Lain'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: VerdaticaTheme.primary,
                            side: const BorderSide(
                                color: VerdaticaTheme.primary),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                  ],
                // Analysis result
                if (_analysisResult != null) ...
                  [
                    const SizedBox(height: 20),
                    _buildAnalysisResult(),
                    const SizedBox(height: 16),
                    GradientButton(
                      text: 'Analisis Foto Baru',
                      icon: Icons.camera_alt_rounded,
                      onPressed: _reset,
                    ),
                  ],
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPrompt() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: VerdaticaTheme.cardBorder, width: 1.2),
        boxShadow: VerdaticaTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Interactive Dropzone Card
          InkWell(
            onTap: _showImageSourcePicker,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: VerdaticaTheme.primarySurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  bottom: BorderSide(color: VerdaticaTheme.cardBorderSubtle, width: 1.2),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: VerdaticaTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: VerdaticaTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_a_photo_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ambil / Unggah Foto Tanaman',
                      style: TextStyle(
                        color: VerdaticaTheme.primaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ketuk di sini untuk membuka kamera atau galeri',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: VerdaticaTheme.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tips & Guidelines row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildTipItem(Icons.wb_sunny_outlined, 'Pencahayaan terang'),
                const SizedBox(width: 8),
                _buildTipItem(Icons.center_focus_strong_rounded, 'Fokus pada daun'),
                const SizedBox(width: 8),
                _buildTipItem(Icons.crop_free_rounded, 'Bebas blur'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: VerdaticaTheme.bgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: VerdaticaTheme.cardBorderSubtle),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: VerdaticaTheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: VerdaticaTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imageBytes == null) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: VerdaticaTheme.cardBorder, width: 1.2),
        boxShadow: VerdaticaTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              _imageBytes!,
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: VerdaticaTheme.primary, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Foto siap dianalisis',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: VerdaticaTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _showImageSourcePicker,
                icon: const Icon(Icons.refresh_rounded, size: 15),
                label: const Text('Ganti Foto'),
                style: TextButton.styleFrom(
                  foregroundColor: VerdaticaTheme.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingLoader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VerdaticaTheme.cardBorder),
        boxShadow: VerdaticaTheme.cardShadow,
      ),
      child: Column(
        children: const [
          SizedBox(
            width: 38,
            height: 38,
            child: CircularProgressIndicator(
              color: VerdaticaTheme.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Sedang Menganalisis Tanaman...',
            style: TextStyle(
              color: VerdaticaTheme.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'AI Verdatica sedang memproses kondisi fisik & daun tanaman.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: VerdaticaTheme.textSecondary,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: VerdaticaTheme.cardBorder, width: 1.2),
        boxShadow: VerdaticaTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              gradient: VerdaticaTheme.headerGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(23)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Color(0xFF4ADE80),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Hasil Diagnosis AI Tanaman',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'SELESAI',
                    style: TextStyle(
                      color: Color(0xFF86EFAC),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Analysis Body
          Padding(
            padding: const EdgeInsets.all(18),
            child: SelectableText(
              _analysisResult!,
              style: const TextStyle(
                color: VerdaticaTheme.textPrimary,
                fontSize: 14,
                height: 1.65,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
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
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: VerdaticaTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
