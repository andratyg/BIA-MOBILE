class ApiConfig {
  // Base URL — ganti di sini kalau domain berubah
  static const String baseUrl = 'https://bia2026-production.up.railway.app';

  // Auth
  static const String login = '/api/login';
  static const String register = '/api/register';
  static const String getUserName = '/api/usn';

  // Sensor
  static const String sensor = '/api/sensor/1';

  // Photo / Gallery
  static const String photos = '/api/photos';
  static const String analyzeImage = '/api/analyze-image';

  // Chat
  static const String chat = '/api/chat';
}
