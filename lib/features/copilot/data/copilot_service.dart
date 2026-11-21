import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/ai/domain/ai_models.dart';
import '../../../core/ai/domain/ai_service_interface.dart';
import '../../trips/domain/itinerary_item_model.dart';
import '../../trips/domain/trip_planner_repository.dart';
import '../../tasks/domain/task_model.dart';
import '../../tasks/domain/task_repository.dart';
import '../../polls/domain/poll_model.dart';
import '../../polls/domain/poll_repository.dart';
import '../domain/copilot_models.dart';

class CopilotService {
  final IAiService _aiService;
  final TripPlannerRepository _tripPlannerRepository;
  final TaskRepository _taskRepository;
  final PollRepository _pollRepository;
  final FirebaseFirestore _firestore;

  CopilotService({
    required IAiService aiService,
    required TripPlannerRepository tripPlannerRepository,
    required TaskRepository taskRepository,
    required PollRepository pollRepository,
    FirebaseFirestore? firestore,
  })  : _aiService = aiService,
        _tripPlannerRepository = tripPlannerRepository,
        _taskRepository = taskRepository,
        _pollRepository = pollRepository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<CopilotMessage> processPrompt({
    required String prompt,
    required String tripId,
    required String tripName,
    DateTime? startDate,
    String? location,
    required List<String> memberNames,
    double totalExpenses = 0.0,
    List<String> existingTasks = const [],
    List<String> existingPolls = const [],
  }) async {
    final systemPrompt = '''
You are "CoCircle Magic", an intelligent AI Group Life Assistant for trip planning, events, group decisions, budgets, tasks, and expense management.
You operate with precision and safety:
1. Always give a helpful, friendly, natural-language explanation in "reply".
2. If the user request implies creating or updating a plan (trip itinerary, event schedule, budget allocation, polls, or tasks), generate a structured proposal in "proposal" with "hasProposal": true.
3. If the user is simply asking a question (e.g. "Who hasn't paid?", "What's our budget?", "Summarize expenses"), provide the answer in "reply" with "hasProposal": false.

Context for this group/trip:
- Trip/Group Name: $tripName
- Destination/Location: ${location ?? 'Not specified'}
- Start Date: ${startDate != null ? startDate.toIso8601String().split('T')[0] : 'Tentative'}
- Group Members (${memberNames.length}): ${memberNames.join(', ')}
- Total Confirmed Expenses Incurred: ₹${totalExpenses.toStringAsFixed(2)}
- Existing Tasks: ${existingTasks.isEmpty ? 'None' : existingTasks.join('; ')}
- Existing Polls: ${existingPolls.isEmpty ? 'None' : existingPolls.join('; ')}

Return ONLY valid JSON matching this exact structure:
{
  "reply": "Conversational response explaining what you did or answering the question.",
  "hasProposal": true or false,
  "proposal": {
    "type": "tripPlan" | "budget" | "poll" | "tasks" | "expenseSummary" | "generalInfo",
    "title": "Short title of the proposal",
    "description": "One sentence summary of the proposal",
    "totalEstimatedBudget": 48000.0,
    "perPersonBudget": 8000.0,
    "budgetItems": [
      {"category": "Accommodation", "amount": 15000.0, "note": "Resort / Villa for 2 nights"},
      {"category": "Transportation", "amount": 12000.0, "note": "Flights / Train / Cabs"},
      {"category": "Food", "amount": 10000.0, "note": "Meals, beach shacks, drinks"},
      {"category": "Activities", "amount": 6000.0, "note": "Water sports, sightseeing"},
      {"category": "Miscellaneous", "amount": 5000.0, "note": "Shopping, buffer"}
    ],
    "itinerary": [
      {
        "title": "Check-in & Sunset at Beach",
        "type": "lodging",
        "dayOffset": 0,
        "startHour": 14,
        "startMinute": 0,
        "location": "North Goa",
        "notes": "Unpack, relax, sunset drinks",
        "estimatedCost": 0.0
      }
    ],
    "polls": [
      {
        "question": "Which hotel should we book?",
        "options": ["Beach Resort (₹3,000/night)", "Boutique Hotel (₹2,200/night)", "Private Villa (₹4,000/night)"],
        "allowMultiple": false
      }
    ],
    "tasks": [
      {"title": "Book flights / train tickets", "assignedRole": "Admin"},
      {"title": "Pack sunscreen and beachwear", "assignedRole": "All"}
    ]
  }
}
''';

    try {
      final jsonResult = await _aiService.generateStructuredJson(
        messages: [
          AiMessage(role: AiRole.system, content: systemPrompt),
          AiMessage(role: AiRole.user, content: prompt),
        ],
        schema: {
          'type': 'object',
          'properties': {
            'reply': {'type': 'string'},
            'hasProposal': {'type': 'boolean'},
            'proposal': {'type': 'object'},
          },
          'required': ['reply', 'hasProposal'],
        },
        options: const AiRequestOptions(temperature: 0.6, maxTokens: 2500),
      );

      final reply = jsonResult['reply'] as String? ?? 'Here is your group plan proposal.';
      final hasProposal = jsonResult['hasProposal'] as bool? ?? false;

      CopilotProposal? proposal;
      if (hasProposal && jsonResult['proposal'] is Map) {
        final pMap = Map<String, dynamic>.from(jsonResult['proposal'] as Map);
        proposal = CopilotProposal.fromJson(pMap);
      }

      return CopilotMessage(
        role: AiRole.assistant,
        content: reply,
        proposal: proposal,
      );
    } catch (e) {
      debugPrint('[CopilotService error] $e');
      return CopilotMessage(
        role: AiRole.assistant,
        content:
            'I encountered an issue processing that with AI: ${e.toString()}. Please check your AI API key or retry.',
      );
    }
  }

  /// Commits approved proposal entities into Firestore safely
  Future<Map<String, int>> commitProposal({
    required String tripId,
    required String userId,
    required DateTime tripStartDate,
    required CopilotProposal proposal,
  }) async {
    int itineraryCount = 0;
    int taskCount = 0;
    int pollCount = 0;
    int budgetCommitmentCount = 0;

    // 1. Commit Itinerary Items
    for (final item in proposal.itinerary) {
      final startTime = DateTime(
        tripStartDate.year,
        tripStartDate.month,
        tripStartDate.day + item.dayOffset,
        item.startHour,
        item.startMinute,
      );

      final itineraryModel = ItineraryItemModel(
        id: const Uuid().v4(),
        tripId: tripId,
        title: item.title,
        type: item.type,
        startTime: startTime,
        location: item.location,
        notes: item.notes,
        cost: item.estimatedCost,
        createdBy: userId,
        createdAt: DateTime.now(),
      );

      final res = await _tripPlannerRepository.createItineraryItem(itineraryModel);
      res.fold((_) {}, (_) => itineraryCount++);
    }

    // 2. Commit Tasks
    for (final task in proposal.tasks) {
      final taskModel = TaskModel(
        id: const Uuid().v4(),
        tripId: tripId,
        title: task.assignedRole != null && task.assignedRole!.isNotEmpty
            ? '[${task.assignedRole}] ${task.title}'
            : task.title,
        createdBy: userId,
        createdAt: DateTime.now(),
      );
      final res = await _taskRepository.createTask(taskModel);
      res.fold((_) {}, (_) => taskCount++);
    }

    // 3. Commit Polls
    for (final poll in proposal.polls) {
      final pollModel = PollModel(
        id: const Uuid().v4(),
        tripId: tripId,
        creatorId: userId,
        question: poll.question,
        options: poll.options.map((opt) => PollOption(text: opt)).toList(),
        allowMultipleSelections: poll.allowMultiple,
        createdAt: DateTime.now(),
        isActive: true,
      );
      final res = await _pollRepository.createPoll(pollModel);
      res.fold((_) {}, (_) => pollCount++);
    }

    // 4. Commit Budget items as upcoming commitments
    if (proposal.budgetItems.isNotEmpty) {
      for (final budget in proposal.budgetItems) {
        if (budget.amount > 0) {
          final docRef = _firestore
              .collection('trips')
              .doc(tripId)
              .collection('budgetCommitments')
              .doc();
          await docRef.set({
            'id': docRef.id,
            'tripId': tripId,
            'title': '${budget.category}: ${budget.note ?? "Estimated allocation"}',
            'category': budget.category.toLowerCase(),
            'estimatedCost': budget.amount,
            'isBooked': false,
            'createdAt': Timestamp.now(),
            'createdBy': userId,
          });
          budgetCommitmentCount++;
        }
      }

      // Also save total budget if available
      if (proposal.totalEstimatedBudget != null && proposal.totalEstimatedBudget! > 0) {
        await _firestore.collection('trips').doc(tripId).set({
          'targetBudget': proposal.totalEstimatedBudget,
        }, SetOptions(merge: true));
      }
    }

    proposal.isApproved = true;

    return {
      'itinerary': itineraryCount,
      'tasks': taskCount,
      'polls': pollCount,
      'budget': budgetCommitmentCount,
    };
  }
}
