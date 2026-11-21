import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/ai/domain/ai_models.dart';
import '../../../core/ai/domain/ai_service_interface.dart';
import '../../trips/domain/itinerary_item_model.dart';
import '../../trips/domain/trip_planner_repository.dart';
import '../../tasks/domain/task_model.dart';
import '../../tasks/domain/task_repository.dart';
import 'poll_model.dart';
import 'poll_repository.dart';

enum DecisionActionType {
  itineraryActivity,
  task,
  budgetCommitment,
}

class DecisionEngineService {
  final IAiService _aiService;
  final PollRepository _pollRepository;
  final TripPlannerRepository _tripPlannerRepository;
  final TaskRepository _taskRepository;
  final FirebaseFirestore _firestore;

  DecisionEngineService({
    required IAiService aiService,
    required PollRepository pollRepository,
    required TripPlannerRepository tripPlannerRepository,
    required TaskRepository taskRepository,
    FirebaseFirestore? firestore,
  })  : _aiService = aiService,
        _pollRepository = pollRepository,
        _tripPlannerRepository = tripPlannerRepository,
        _taskRepository = taskRepository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Generates AI recommendation for a poll based on question, options, and current votes
  Future<String> generateAiRecommendation({
    required PollModel poll,
    required String tripName,
    required int totalMembers,
  }) async {
    final optionsSummary = StringBuffer();
    for (int i = 0; i < poll.options.length; i++) {
      final opt = poll.options[i];
      optionsSummary.writeln('- Option ${i + 1}: "${opt.text}" (${opt.voteCount} votes)');
    }

    final prompt = '''
You are CoCircle Decision Engine, an analytical AI for group decision making.
Analyze this group poll and provide a smart, objective recommendation.

Trip/Group: $tripName
Total Group Members: $totalMembers
Poll Question: "${poll.question}"
Options & Current Votes:
$optionsSummary

Instructions:
1. Identify which option is leading or has strongest consensus.
2. If there are prices, amenities, dates, or trade-offs mentioned in the options, compare them objectively (e.g. cost-per-person savings vs convenience).
3. Conclude with a clear, concise 2-3 sentence recommendation for the group.
''';

    try {
      final recommendation = await _aiService.generateText(
        messages: [AiMessage(role: AiRole.user, content: prompt)],
        options: const AiRequestOptions(temperature: 0.4, maxTokens: 400),
      );

      final trimmed = recommendation.trim();

      // Persist recommendation to Firestore
      final updatedPoll = poll.copyWith(aiRecommendation: trimmed);
      await _pollRepository.updatePoll(updatedPoll);

      return trimmed;
    } catch (e) {
      debugPrint('[DecisionEngine] AI recommendation error: $e');
      throw Exception('Failed to generate recommendation: $e');
    }
  }

  /// Converts a winning poll option into an actionable entity (Itinerary item, Task, or Budget item)
  Future<String> convertDecisionToAction({
    required PollModel poll,
    required int winningOptionIndex,
    required DecisionActionType actionType,
    required String currentUserId,
    DateTime? activityDate,
    double? costEstimate,
  }) async {
    if (winningOptionIndex < 0 || winningOptionIndex >= poll.options.length) {
      throw Exception('Invalid winning option index');
    }

    final winningOption = poll.options[winningOptionIndex];
    String resultMessage = '';

    switch (actionType) {
      case DecisionActionType.itineraryActivity:
        final date = activityDate ?? poll.createdAt.add(const Duration(days: 1));
        final item = ItineraryItemModel(
          id: const Uuid().v4(),
          tripId: poll.tripId,
          title: winningOption.text,
          type: 'general',
          startTime: DateTime(date.year, date.month, date.day, 10, 0),
          notes: 'Decided by group poll: "${poll.question}" (${winningOption.voteCount} votes)',
          cost: costEstimate,
          createdBy: currentUserId,
          createdAt: DateTime.now(),
        );
        final res = await _tripPlannerRepository.createItineraryItem(item);
        res.fold(
          (l) => throw Exception(l.message),
          (_) => resultMessage = 'Converted into Itinerary Activity: "${item.title}"',
        );
        break;

      case DecisionActionType.task:
        final task = TaskModel(
          id: const Uuid().v4(),
          tripId: poll.tripId,
          title: 'Action: ${winningOption.text}',
          createdBy: currentUserId,
          createdAt: DateTime.now(),
        );
        final res = await _taskRepository.createTask(task);
        res.fold(
          (l) => throw Exception(l.message),
          (_) => resultMessage = 'Converted into Task: "${task.title}"',
        );
        break;

      case DecisionActionType.budgetCommitment:
        final docRef = _firestore
            .collection('trips')
            .doc(poll.tripId)
            .collection('budgetCommitments')
            .doc();
        await docRef.set({
          'id': docRef.id,
          'tripId': poll.tripId,
          'title': winningOption.text,
          'category': 'decision',
          'estimatedCost': costEstimate ?? 0.0,
          'isBooked': true,
          'notes': 'Booked from poll decision: "${poll.question}"',
          'createdAt': Timestamp.now(),
          'createdBy': currentUserId,
        });
        resultMessage = 'Converted into Budget Commitment: "${winningOption.text}"';
        break;
    }

    // Mark poll as converted
    final updatedPoll = poll.copyWith(
      winningOptionIndex: winningOptionIndex,
      convertedToAction: true,
      isActive: false,
      closedAt: DateTime.now(),
    );
    await _pollRepository.updatePoll(updatedPoll);

    return resultMessage;
  }
}
