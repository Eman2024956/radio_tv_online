class EpgProgram {
  final String channelId;
  final String title;
  final String description;
  final DateTime start;
  final DateTime stop;
  final String? category;

  const EpgProgram({
    required this.channelId,
    required this.title,
    this.description = '',
    required this.start,
    required this.stop,
    this.category,
  });

  bool get isCurrentlyAiring {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(stop);
  }

  double get progressPercentage {
    final now = DateTime.now();
    if (now.isBefore(start)) return 0.0;
    if (now.isAfter(stop)) return 1.0;
    final totalDuration = stop.difference(start).inSeconds;
    if (totalDuration <= 0) return 0.0;
    final elapsed = now.difference(start).inSeconds;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  factory EpgProgram.fromJson(Map<String, dynamic> json) {
    return EpgProgram(
      channelId: json['channelId'] as String? ?? '',
      title: json['title'] as String? ?? 'Program Guide',
      description: json['description'] as String? ?? '',
      start: DateTime.tryParse(json['start'] as String? ?? '') ?? DateTime.now(),
      stop: DateTime.tryParse(json['stop'] as String? ?? '') ??
          DateTime.now().add(const Duration(hours: 1)),
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channelId': channelId,
      'title': title,
      'description': description,
      'start': start.toIso8601String(),
      'stop': stop.toIso8601String(),
      'category': category,
    };
  }
}
