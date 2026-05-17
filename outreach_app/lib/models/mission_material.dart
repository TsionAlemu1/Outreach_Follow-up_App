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
    final int parsedId = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0;
    final String parsedTitle = json['title']?.toString() ?? 'Gospel Tract';
    final String parsedDesc = json['description']?.toString() ?? json['body']?.toString() ?? '';
    final String parsedCat = json['category']?.toString() ?? 'Tracts';
    final String parsedUrl = json['url']?.toString() ?? 'https://fellowship.materials/resource_$parsedId.pdf';
    final int dlCount = json['downloadCount'] is int ? json['downloadCount'] : int.tryParse(json['downloadCount']?.toString() ?? '') ?? (parsedId * 12);
    final String fileType = json['fileType']?.toString() ?? 'PDF';

    return MissionMaterial(
      id: parsedId,
      title: parsedTitle,
      description: parsedDesc,
      category: parsedCat,
      url: parsedUrl,
      downloadCount: dlCount,
      fileType: fileType,
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
