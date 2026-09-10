class SensorData {
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: _toDouble(
        json['suhu'] ?? json['temperature'] ?? json['temp'] ?? 0,
      ),
      humidity: _toDouble(
        json['kelembapan_udara'] ??
            json['kelembapan'] ??
            json['kelembaban_udara'] ??
            json['kelembaban'] ??
            json['lembap'] ??
            json['humidity'] ??
            json['hum'] ??
            0,
      ),
      soilMoisture: _toDouble(
        json['kelembapan_tanah'] ??
            json['kelembaban_tanah'] ??
            json['soil_moisture'] ??
            json['soil'] ??
            0,
      ),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
