class MissionMaterial {
  final int id;
  final String title;
  final String description;
  final String category; // 'Tracts', 'Bible Studies', 'Discipleship', 'Other'
  final String url;
  final int downloadCount;
  final String fileType; // 'PDF', 'Word', 'Link'

  MissionMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.url,
    required this.downloadCount,
    required this.fileType,
  });

  factory MissionMaterial.fromJson(Map<String, dynamic> json) {
    return MissionMaterial(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] ?? '',
      category: json['category'] ?? 'Tracts',
      url: json['url'] ?? '',
      downloadCount: json['downloadCount'] ?? 0,
      fileType: json['fileType'] ?? 'PDF',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'url': url,
      'downloadCount': downloadCount,
      'fileType': fileType,
    };
  }
}
