class VideoItem {
  final String title;
  final String date;
  final String thumbnail;
  final String videoUrl;
  final String category;
  bool isBookmarked;

  VideoItem({
    required this.title,
    required this.date,
    required this.thumbnail,
    required this.videoUrl,
    required this.category,
    required this.isBookmarked,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'thumbnail': thumbnail,
      'videoUrl': videoUrl,
      'category': category,
      'isBookmarked': isBookmarked,
    };
  }

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      category: json['category'] ?? '',
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  VideoItem copyWith({
    String? title,
    String? date,
    String? thumbnail,
    String? videoUrl,
    String? category,
    bool? isBookmarked,
  }) {
    return VideoItem(
      title: title ?? this.title,
      date: date ?? this.date,
      thumbnail: thumbnail ?? this.thumbnail,
      videoUrl: videoUrl ?? this.videoUrl,
      category: category ?? this.category,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
