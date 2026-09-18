class LiveTvChannel {
  final String id;
  final String name;
  final String logo;
  final String category;
  final String country;
  final String language;
  final String streamUrl;
  final String quality;
  final String? httpReferrer;
  final String? httpUserAgent;
  final bool isGeoBlocked;

  const LiveTvChannel({
    required this.id,
    required this.name,
    required this.logo,
    this.category = 'General',
    this.country = 'Global',
    this.language = 'ara',
    required this.streamUrl,
    this.quality = 'HD',
    this.httpReferrer,
    this.httpUserAgent,
    this.isGeoBlocked = false,
  });

  factory LiveTvChannel.fromJson(Map<String, dynamic> json) {
    return LiveTvChannel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Channel',
      logo: json['logo'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      country: json['country'] as String? ?? 'Global',
      language: json['language'] as String? ?? 'ara',
      streamUrl: json['streamUrl'] as String? ?? '',
      quality: json['quality'] as String? ?? 'HD',
      httpReferrer: json['httpReferrer'] as String?,
      httpUserAgent: json['httpUserAgent'] as String?,
      isGeoBlocked: json['isGeoBlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'category': category,
      'country': country,
      'language': language,
      'streamUrl': streamUrl,
      'quality': quality,
      'httpReferrer': httpReferrer,
      'httpUserAgent': httpUserAgent,
      'isGeoBlocked': isGeoBlocked,
    };
  }

  LiveTvChannel copyWith({
    String? id,
    String? name,
    String? logo,
    String? category,
    String? country,
    String? language,
    String? streamUrl,
    String? quality,
    String? httpReferrer,
    String? httpUserAgent,
    bool? isGeoBlocked,
  }) {
    return LiveTvChannel(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      category: category ?? this.category,
      country: country ?? this.country,
      language: language ?? this.language,
      streamUrl: streamUrl ?? this.streamUrl,
      quality: quality ?? this.quality,
      httpReferrer: httpReferrer ?? this.httpReferrer,
      httpUserAgent: httpUserAgent ?? this.httpUserAgent,
      isGeoBlocked: isGeoBlocked ?? this.isGeoBlocked,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveTvChannel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          streamUrl == other.streamUrl;

  @override
  int get hashCode => id.hashCode ^ streamUrl.hashCode;
}
