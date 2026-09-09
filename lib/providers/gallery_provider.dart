import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/photo.dart';
import '../services/api_service.dart';

class GalleryProvider extends ChangeNotifier {
  List<Photo> _photos = [];
  List<Photo> _filtered = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Photo> get photos => _filtered;
  List<Photo> get allPhotos => _photos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  int get totalPhotos => _photos.length;
  int get analyzedCount => _photos.where((p) => p.isAnalyzed).length;
  Photo? get latestPhoto => _photos.isNotEmpty ? _photos.first : null;

  final Dio _dio = ApiService.instance.dio;

  Future<void> fetchPhotos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get(ApiConfig.photos);
      final data = response.data as List? ?? [];
      _photos = data.map((json) => Photo.fromJson(json)).toList();
      _applyFilter();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat galeri. Periksa koneksi internet.';
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filtered = List.from(_photos);
    } else {
      final q = _searchQuery.toLowerCase();
      _filtered = _photos.where((p) {
        return (p.analysis?.toLowerCase().contains(q) ?? false) ||
            p.createdAt.toString().contains(q);
      }).toList();
    }
  }
}
