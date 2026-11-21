class GuestPollPreview {
  final String id;
  final String question;
  final List<String> options;
  final List<int> voteCounts;
  final bool allowMultiple;
  final bool isActive;

  const GuestPollPreview({
    required this.id,
    required this.question,
    required this.options,
    required this.voteCounts,
    this.allowMultiple = false,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'voteCounts': voteCounts,
        'allowMultiple': allowMultiple,
        'isActive': isActive,
      };

  factory GuestPollPreview.fromJson(Map<String, dynamic> json) {
    return GuestPollPreview(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
      voteCounts: (json['voteCounts'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      allowMultiple: json['allowMultiple'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class GuestGroupPreview {
  final String circleId;
  final String circleCode;
  final String circleName;
  final String? tripId;
  final String? tripName;
  final String? location;
  final String? datesString;
  final int memberCount;
  final List<String> memberNames;
  final List<String> itineraryHighlights;
  final List<GuestPollPreview> openPolls;
  final double totalBudget;
  final int pendingTasksCount;
  final String currency;
  final bool isActive;
  final DateTime? expiresAt;

  const GuestGroupPreview({
    required this.circleId,
    required this.circleCode,
    required this.circleName,
    this.tripId,
    this.tripName,
    this.location,
    this.datesString,
    required this.memberCount,
    this.memberNames = const [],
    this.itineraryHighlights = const [],
    this.openPolls = const [],
    this.totalBudget = 0.0,
    this.pendingTasksCount = 0,
    this.currency = 'INR',
    this.isActive = true,
    this.expiresAt,
  });
}
