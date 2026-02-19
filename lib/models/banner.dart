class BannerModel {
  final int id;
  final String? title;
  final String imageUrl;
  final String? link;
  final bool status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BannerModel({
    required this.id,
    this.title,
    required this.imageUrl,
    this.link,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'],
      imageUrl: json['image_url'] ?? '',
      link: json['link'],
      status: json['status'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'link': link,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'BannerModel(id: $id, title: $title, imageUrl: $imageUrl, link: $link, status: $status)';
  }
}
