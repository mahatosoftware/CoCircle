import 'package:uuid/uuid.dart';
import '../../../core/ai/domain/ai_models.dart';

enum CopilotProposalType {
  tripPlan,
  budget,
  poll,
  tasks,
  expenseSummary,
  generalInfo,
}

class ProposedItineraryItem {
  final String title;
  final String type; // travel, lodging, dining, sightseeing, general
  final int dayOffset; // 0 = Day 1
  final int startHour;
  final int startMinute;
  final String? location;
  final String? notes;
  final double? estimatedCost;

  const ProposedItineraryItem({
    required this.title,
    this.type = 'general',
    this.dayOffset = 0,
    this.startHour = 9,
    this.startMinute = 0,
    this.location,
    this.notes,
    this.estimatedCost,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'type': type,
        'dayOffset': dayOffset,
        'startHour': startHour,
        'startMinute': startMinute,
        'location': location,
        'notes': notes,
        'estimatedCost': estimatedCost,
      };

  factory ProposedItineraryItem.fromJson(Map<String, dynamic> json) {
    return ProposedItineraryItem(
      title: json['title'] as String? ?? 'Activity',
      type: json['type'] as String? ?? 'general',
      dayOffset: (json['dayOffset'] as num?)?.toInt() ?? 0,
      startHour: (json['startHour'] as num?)?.toInt() ?? 9,
      startMinute: (json['startMinute'] as num?)?.toInt() ?? 0,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ??
          (json['cost'] as num?)?.toDouble(),
    );
  }
}

class ProposedBudgetItem {
  final String category;
  final double amount;
  final String? note;

  const ProposedBudgetItem({
    required this.category,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'category': category,
        'amount': amount,
        'note': note,
      };

  factory ProposedBudgetItem.fromJson(Map<String, dynamic> json) {
    return ProposedBudgetItem(
      category: json['category'] as String? ?? 'General',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] as String?,
    );
  }
}

class ProposedPoll {
  final String question;
  final List<String> options;
  final bool allowMultiple;

  const ProposedPoll({
    required this.question,
    required this.options,
    this.allowMultiple = false,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'allowMultiple': allowMultiple,
      };

  factory ProposedPoll.fromJson(Map<String, dynamic> json) {
    return ProposedPoll(
      question: json['question'] as String? ?? '',
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
      allowMultiple: json['allowMultiple'] as bool? ?? false,
    );
  }
}

class ProposedTask {
  final String title;
  final String? assignedRole;

  const ProposedTask({
    required this.title,
    this.assignedRole,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'assignedRole': assignedRole,
      };

  factory ProposedTask.fromJson(Map<String, dynamic> json) {
    return ProposedTask(
      title: json['title'] as String? ?? '',
      assignedRole: json['assignedRole'] as String?,
    );
  }
}

class CopilotProposal {
  final String id;
  final CopilotProposalType type;
  final String title;
  final String description;
  final List<ProposedItineraryItem> itinerary;
  final List<ProposedBudgetItem> budgetItems;
  final List<ProposedPoll> polls;
  final List<ProposedTask> tasks;
  final double? totalEstimatedBudget;
  final double? perPersonBudget;
  bool isApproved;
  bool isRejected;

  CopilotProposal({
    String? id,
    required this.type,
    required this.title,
    required this.description,
    this.itinerary = const [],
    this.budgetItems = const [],
    this.polls = const [],
    this.tasks = const [],
    this.totalEstimatedBudget,
    this.perPersonBudget,
    this.isApproved = false,
    this.isRejected = false,
  }) : id = id ?? const Uuid().v4();

  bool get hasContent =>
      itinerary.isNotEmpty ||
      budgetItems.isNotEmpty ||
      polls.isNotEmpty ||
      tasks.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'description': description,
        'itinerary': itinerary.map((i) => i.toJson()).toList(),
        'budgetItems': budgetItems.map((b) => b.toJson()).toList(),
        'polls': polls.map((p) => p.toJson()).toList(),
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'totalEstimatedBudget': totalEstimatedBudget,
        'perPersonBudget': perPersonBudget,
        'isApproved': isApproved,
        'isRejected': isRejected,
      };

  factory CopilotProposal.fromJson(Map<String, dynamic> json) {
    return CopilotProposal(
      id: json['id'] as String?,
      type: CopilotProposalType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => CopilotProposalType.tripPlan,
      ),
      title: json['title'] as String? ?? 'Proposed Plan',
      description: json['description'] as String? ?? '',
      itinerary: (json['itinerary'] as List?)
              ?.map((e) => ProposedItineraryItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      budgetItems: (json['budgetItems'] as List?)
              ?.map((e) => ProposedBudgetItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      polls: (json['polls'] as List?)
              ?.map((e) => ProposedPoll.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      tasks: (json['tasks'] as List?)
              ?.map((e) => ProposedTask.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      totalEstimatedBudget: (json['totalEstimatedBudget'] as num?)?.toDouble(),
      perPersonBudget: (json['perPersonBudget'] as num?)?.toDouble(),
      isApproved: json['isApproved'] as bool? ?? false,
      isRejected: json['isRejected'] as bool? ?? false,
    );
  }
}

class CopilotMessage {
  final String id;
  final AiRole role;
  final String content;
  final CopilotProposal? proposal;
  final DateTime timestamp;

  CopilotMessage({
    String? id,
    required this.role,
    required this.content,
    this.proposal,
    DateTime? timestamp,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();
}
