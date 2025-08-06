class ApodItem {
  final String title;
  final String date;
  final String explanation;
  final String url;
  final String? hdurl;
  final String mediaType;
  final String? copyright;

  ApodItem({
    required this.title,
    required this.date,
    required this.explanation,
    required this.url,
    this.hdurl,
    this.mediaType = 'image',
    this.copyright,
  });

  // Factory constructor for creating ApodItem from JSON
  factory ApodItem.fromJson(Map<String, dynamic> json) {
    return ApodItem(
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      explanation: json['explanation'] ?? '',
      url: json['url'] ?? '',
      hdurl: json['hdurl'],
      mediaType: json['media_type'] ?? 'image',
      copyright: json['copyright'],
    );
  }

  // Convert ApodItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'explanation': explanation,
      'url': url,
      'hdurl': hdurl,
      'media_type': mediaType,
      'copyright': copyright,
    };
  }

  // Create a copy with updated fields
  ApodItem copyWith({
    String? title,
    String? date,
    String? explanation,
    String? url,
    String? hdurl,
    String? mediaType,
    String? copyright,
  }) {
    return ApodItem(
      title: title ?? this.title,
      date: date ?? this.date,
      explanation: explanation ?? this.explanation,
      url: url ?? this.url,
      hdurl: hdurl ?? this.hdurl,
      mediaType: mediaType ?? this.mediaType,
      copyright: copyright ?? this.copyright,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApodItem &&
        other.title == title &&
        other.date == date &&
        other.explanation == explanation &&
        other.url == url &&
        other.hdurl == hdurl &&
        other.mediaType == mediaType &&
        other.copyright == copyright;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        date.hashCode ^
        explanation.hashCode ^
        url.hashCode ^
        hdurl.hashCode ^
        mediaType.hashCode ^
        copyright.hashCode;
  }

  @override
  String toString() {
    return 'ApodItem(title: $title, date: $date, mediaType: $mediaType)';
  }
}