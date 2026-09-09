import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';

class SensorProvider extends ChangeNotifier {
  SensorData? _latest;
  bool _isLive = false;
  bool _isLoading = false;
  DateTime? _lastUpdate;
  final List<SensorData> _history = [];
  static const int _maxHistory = 20;

  SensorData? get latest => _latest;
  bool get isLive => _isLive;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdate => _lastUpdate;
  List<SensorData> get history => List.unmodifiable(_history);

  Timer? _timer;
  final Dio _dio = ApiService.instance.dio;

  void startPolling({int intervalSeconds = 2}) {
    stopPolling();
    fetchSensor(); // fetch immediately
    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      fetchSensor();
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> fetchSensor() async {
    try {
      final response = await _dio.get(ApiConfig.sensor);
      final data = SensorData.fromJson(response.data is List
          ? (response.data as List).first
          : response.data);
      _latest = data;
      _isLive = true;
      _lastUpdate = DateTime.now();
      _addToHistory(data);
      notifyListeners();
    } catch (e) {
      _isLive = false;
      notifyListeners();
    }
  }

  void _addToHistory(SensorData data) {
    _history.add(data);
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
