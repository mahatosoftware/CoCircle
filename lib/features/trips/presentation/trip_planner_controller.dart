import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/snackbar.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../data/trip_planner_repository_impl.dart';
import '../domain/itinerary_item_model.dart';
import '../domain/lodging_model.dart';
import '../domain/idea_model.dart';
import '../domain/packing_item_model.dart';
import '../../../core/ai/ai_provider.dart';
import '../../../core/ai/domain/ai_models.dart';
import '../../../core/ai/domain/ai_service_interface.dart';
import '../../../core/ai/data/ai_config_model.dart';
import '../../../core/ai/data/firebase_ai_config_repository.dart';
import '../../../core/ai/infrastructure/gemini_ai_service.dart';
import '../../../core/ai/infrastructure/openai_ai_service.dart';
import '../../../core/ai/infrastructure/claude_ai_service.dart';
import '../../../core/ai/infrastructure/proxy_ai_service.dart';

part 'trip_planner_controller.g.dart';

@Riverpod(keepAlive: true)
class TripPlannerController extends _$TripPlannerController {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  // Itinerary
  Future<void> createItineraryItem({
    required String tripId,
    required String title,
    required String type,
    required DateTime startTime,
    DateTime? endTime,
    bool hasStartTime = true,
    String? location,
    String? notes,
    double? cost,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    final item = ItineraryItemModel(
      id: const Uuid().v4(),
      tripId: tripId,
      title: title,
      type: type,
      startTime: startTime,
      endTime: endTime,
      hasStartTime: hasStartTime,
      location: location,
      notes: notes,
      cost: cost,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    final res = await ref
        .read(tripPlannerRepositoryProvider)
        .createItineraryItem(item);
    res.fold(
      (l) {
        debugPrint('Create itinerary item failed: ${l.message}');
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Activity added!');
        Navigator.pop(context);
      },
    );
  }

  Future<void> updateItineraryItem({
    required ItineraryItemModel item,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final res = await ref
        .read(tripPlannerRepositoryProvider)
        .updateItineraryItem(item);
    res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Activity updated!');
      },
    );
  }

  Future<void> deleteItineraryItem({
    required String itemId,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final res = await ref
        .read(tripPlannerRepositoryProvider)
        .deleteItineraryItem(itemId);
    res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Activity deleted');
      },
    );
  }

  // Lodging
  Future<void> createLodging({
    required String tripId,
    required String name,
    String? address,
    required DateTime checkIn,
    required DateTime checkOut,
    String? confirmationNumber,
    String? phoneNumber,
    String? notes,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    final lodging = LodgingModel(
      id: const Uuid().v4(),
      tripId: tripId,
      name: name,
      address: address,
      checkIn: checkIn,
      checkOut: checkOut,
      confirmationNumber: confirmationNumber,
      phoneNumber: phoneNumber,
      notes: notes,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    final res = await ref
        .read(tripPlannerRepositoryProvider)
        .createLodging(lodging);
    res.fold(
      (l) {
        debugPrint('Create lodging failed: ${l.message}');
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Lodging stay added!');
        Navigator.pop(context);
      },
    );
  }

  Future<void> updateLodging({
    required LodgingModel lodging,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final res = await ref
        .read(tripPlannerRepositoryProvider)
        .updateLodging(lodging);
    res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Lodging stay updated!');
      },
    );
  }

  Future<void> deleteLodging({
    required String lodgingId,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final res = await ref
        .read(tripPlannerRepositoryProvider)
        .deleteLodging(lodgingId);
    res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Lodging stay deleted');
      },
    );
  }

  // Ideas
  Future<void> createIdea({
    required String tripId,
    required String title,
    String? description,
    String? location,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    final idea = IdeaModel(
      id: const Uuid().v4(),
      tripId: tripId,
      title: title,
      description: description,
      location: location,
      votes: [],
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    final res = await ref.read(tripPlannerRepositoryProvider).createIdea(idea);
    res.fold(
      (l) {
        debugPrint('Create idea failed: ${l.message}');
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Idea added to board!');
        Navigator.pop(context);
      },
    );
  }

  Future<void> toggleVoteIdea({
    required String ideaId,
    required String userId,
    required BuildContext context,
  }) async {
    final res = await ref
        .read(tripPlannerRepositoryProvider)
        .toggleVoteIdea(ideaId, userId);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  Future<void> promoteIdeaToItinerary({
    required IdeaModel idea,
    required DateTime startTime,
    required String type,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    final itineraryItem = ItineraryItemModel(
      id: const Uuid().v4(),
      tripId: idea.tripId,
      title: idea.title,
      type: type,
      startTime: startTime,
      location: idea.location,
      notes: idea.description,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    final res = await ref
        .read(tripPlannerRepositoryProvider)
        .promoteIdeaToItinerary(idea.id, itineraryItem);
    res.fold(
      (l) {
        debugPrint('Promote idea failed: ${l.message}');
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Idea promoted to Itinerary!');
        Navigator.pop(context);
      },
    );
  }

  Future<void> deleteIdea({
    required String ideaId,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final res = await ref
        .read(tripPlannerRepositoryProvider)
        .deleteIdea(ideaId);
    res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Idea deleted');
      },
    );
  }

  // Packing List
  Future<void> createPackingItem({
    required String tripId,
    required String title,
    double quantity = 1.0,
    String? assignedTo,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    final item = PackingItemModel(
      id: const Uuid().v4(),
      tripId: tripId,
      title: title,
      quantity: quantity,
      assignedTo: assignedTo,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    final res = await ref
        .read(tripPlannerRepositoryProvider)
        .createPackingItem(item);
    res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Item added to packing list!');
      },
    );
  }

  Future<void> togglePackingItem({
    required String itemId,
    required bool isPacked,
    required BuildContext context,
  }) async {
    final res = await ref
        .read(tripPlannerRepositoryProvider)
        .togglePackingItem(itemId, isPacked);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  Future<void> assignPackingItem({
    required String itemId,
    required String? userId,
    required BuildContext context,
  }) async {
    final res = await ref
        .read(tripPlannerRepositoryProvider)
        .assignPackingItem(itemId, userId);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  Future<void> deletePackingItem({
    required String itemId,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final res = await ref
        .read(tripPlannerRepositoryProvider)
        .deletePackingItem(itemId);
    res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Item deleted');
      },
    );
  }

  Future<void> saveGeminiApiKey(String apiKey) async {
    final repository = ref.read(firebaseAiConfigRepositoryProvider);
    final currentConfig = ref.read(aiConfigStateProvider);
    final updatedConfig = AiConfigModel(
      activeProvider: 'gemini',
      geminiApiKey: apiKey.trim(),
      geminiModel: currentConfig.geminiModel,
      openaiApiKey: currentConfig.openaiApiKey,
      openaiModel: currentConfig.openaiModel,
      openaiBaseUrl: currentConfig.openaiBaseUrl,
      claudeApiKey: currentConfig.claudeApiKey,
      claudeModel: currentConfig.claudeModel,
      proxyUrl: currentConfig.proxyUrl,
      enabled: true,
    );
    await repository.updateAiConfig(updatedConfig);
  }

  Future<void> generateAiItinerary({
    required String tripId,
    required String destination,
    required DateTime startDate,
    required int numberOfDays,
    String vibe = 'balanced',
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    try {
      var config = ref.read(aiConfigStateProvider);

      if (config.geminiApiKey.isEmpty) {
        try {
          config = await ref
              .read(firebaseAiConfigRepositoryProvider)
              .getAiConfig()
              .timeout(const Duration(seconds: 5));
        } catch (_) {}
      }

      final activeProvider = config.activeProvider.toLowerCase();
      if (!config.enabled) {
        throw Exception('AI features are currently disabled in Firebase config.');
      }

      if (activeProvider == 'gemini' && config.geminiApiKey.isEmpty) {
        throw Exception(
          'Gemini API key is missing in Firebase document "config/ai_config". Please set your Gemini API key in Firestore.',
        );
      } else if (activeProvider == 'openai' && config.openaiApiKey.isEmpty) {
        throw Exception(
          'OpenAI API key is missing in Firebase document "config/ai_config". Please set your OpenAI API key in Firestore.',
        );
      } else if (activeProvider == 'claude' && config.claudeApiKey.isEmpty) {
        throw Exception(
          'Claude API key is missing in Firebase document "config/ai_config". Please set your Claude API key in Firestore.',
        );
      }

      final IAiService aiService;
      if (activeProvider == 'openai') {
        aiService = OpenAiService(
          apiKey: config.openaiApiKey,
          modelName: config.openaiModel,
          baseUrl: config.openaiBaseUrl,
        );
      } else if (activeProvider == 'claude') {
        aiService = ClaudeAiService(
          apiKey: config.claudeApiKey,
          modelName: config.claudeModel,
        );
      } else if (activeProvider == 'proxy') {
        aiService = ProxyAiService(proxyUrl: config.proxyUrl);
      } else {
        aiService = GeminiAiService(
          apiKey: config.geminiApiKey,
          modelName: config.geminiModel,
        );
      }

      final prompt =
          '''
Generate a detailed $numberOfDays-day trip itinerary for $destination starting on ${startDate.toIso8601String().split('T')[0]}. Vibe: $vibe.
Return JSON format with key "activities" containing an array of items:
[
  {
    "title": "Visit Shibuya Crossing",
    "type": "sightseeing", // Options: travel, lodging, dining, sightseeing, general
    "dayOffset": 0, // Day offset from start date (0 = Day 1)
    "startHour": 10,
    "startMinute": 0,
    "location": "Shibuya, Tokyo",
    "notes": "Iconic scramble crossing and shopping",
    "cost": 0.0
  }
]
''';

      final jsonResult = await aiService.generateStructuredJson(
        messages: [AiMessage(role: AiRole.user, content: prompt)],
        schema: {
          'type': 'object',
          'properties': {
            'activities': {'type': 'array'},
          },
        },
        options: const AiRequestOptions(maxTokens: 2048),
      );

      final activities = jsonResult['activities'] as List? ?? [];
      if (activities.isEmpty) {
        throw const FormatException(
          'The AI response did not contain any itinerary activities.',
        );
      }

      var createdCount = 0;
      for (final raw in activities) {
        if (raw is Map) {
          final activity = Map<String, dynamic>.from(raw);
          final dayOffset = (activity['dayOffset'] as num?)?.toInt() ?? 0;
          final startHour = (activity['startHour'] as num?)?.toInt() ?? 9;
          final startMinute = (activity['startMinute'] as num?)?.toInt() ?? 0;

          final itemStartTime = DateTime(
            startDate.year,
            startDate.month,
            startDate.day + dayOffset,
            startHour,
            startMinute,
          );

          final item = ItineraryItemModel(
            id: const Uuid().v4(),
            tripId: tripId,
            title: activity['title'] as String? ?? 'Activity',
            type: activity['type'] as String? ?? 'general',
            startTime: itemStartTime,
            location: activity['location'] as String?,
            notes: activity['notes'] as String?,
            cost: (activity['cost'] as num?)?.toDouble(),
            createdBy: user.uid,
            createdAt: DateTime.now(),
          );

          final result = await ref
              .read(tripPlannerRepositoryProvider)
              .createItineraryItem(item);
          result.fold(
            (failure) => throw Exception(
              'Could not save "${item.title}": ${failure.message}',
            ),
            (_) => createdCount++,
          );
        }
      }

      if (createdCount == 0) {
        throw const FormatException(
          'The AI response contained no valid itinerary activities.',
        );
      }

      state = const AsyncData(null);
      if (context.mounted) {
        showSnackBar(
          context,
          '$createdCount activities added to your itinerary!',
        );
      }
    } catch (e, st) {
      debugPrint('[AI Itinerary Generator] ERROR for destination "$destination" ($numberOfDays days, vibe: $vibe, tripId: $tripId): $e');
      debugPrint('[AI Itinerary Generator] Stack trace:\n$st');
      state = AsyncError(e.toString(), st);
      if (context.mounted) {
        showSnackBar(context, 'Failed to generate itinerary: ${e.toString()}');
      }
    }
  }
}

@riverpod
Stream<List<ItineraryItemModel>> tripItinerary(Ref ref, String tripId) {
  return ref.watch(tripPlannerRepositoryProvider).getItineraryStream(tripId);
}

@riverpod
Stream<List<LodgingModel>> tripLodging(Ref ref, String tripId) {
  return ref.watch(tripPlannerRepositoryProvider).getLodgingStream(tripId);
}

@riverpod
Stream<List<IdeaModel>> tripIdeas(Ref ref, String tripId) {
  return ref.watch(tripPlannerRepositoryProvider).getIdeasStream(tripId);
}

@riverpod
Stream<List<PackingItemModel>> tripPacking(Ref ref, String tripId) {
  return ref.watch(tripPlannerRepositoryProvider).getPackingStream(tripId);
}
