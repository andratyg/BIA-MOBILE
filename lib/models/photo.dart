class Photo {
  final int id;
  final String url;
  final String fullUrl;
  final String? analysis;
  final DateTime createdAt;

  Photo({
    required this.id,
    required this.url,
    required this.fullUrl,
    this.analysis,
    required this.createdAt,
  });

  bool get isAnalyzed => analysis != null && analysis!.isNotEmpty;

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
      fullUrl: json['full_url'] ?? json['url'] ?? '',
      analysis: json['analysis'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
