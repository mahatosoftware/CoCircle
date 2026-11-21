import 'package:uuid/uuid.dart';
import '../../../core/ai/domain/ai_models.dart';
import '../../../core/ai/domain/ai_service_interface.dart';
import '../domain/memory_model.dart';
import 'memory_repository.dart';

class ScrapbookAiService {
  final IAiService _aiService;
  final MemoryRepository _memoryRepository;

  ScrapbookAiService({
    required IAiService aiService,
    required MemoryRepository memoryRepository,
  })  : _aiService = aiService,
        _memoryRepository = memoryRepository;

  Future<TripScrapbook> generateTripScrapbook({
    required String tripId,
    required String tripName,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    required List<String> memberNames,
    List<String> itineraryTitles = const [],
    List<String> memoryCaptions = const [],
    double totalExpenses = 0.0,
  }) async {
    final days = (startDate != null && endDate != null)
        ? (endDate.difference(startDate).inDays + 1)
        : 3;
    final year = startDate?.year ?? DateTime.now().year;

    final prompt = '''
You are CoCircle Magic Memory Storyteller.
Create an emotional, fun, visual digital scrapbook and trip recap for this group trip/event.

Trip Details:
- Name: $tripName
- Destination: ${location ?? 'Amazing destination'}
- Duration: $days Days
- Members (${memberNames.length}): ${memberNames.join(', ')}
- Activities: ${itineraryTitles.isEmpty ? 'Beaches, exploring, dinners' : itineraryTitles.join(', ')}
- Photos/Moments captured: ${memoryCaptions.isEmpty ? 'Beach sunset, shack dinners, group selfies' : memoryCaptions.join('; ')}
- Total group expenses: ₹${totalExpenses.toStringAsFixed(0)}

Return ONLY valid JSON matching this schema:
{
  "title": "Our $tripName Diaries",
  "subtitle": "$days Days • ${memberNames.length} Friends • $year",
  "story": "A heartwarming, beautifully written 2-3 paragraph group recap highlighting friendship, shared adventures, food, and laughter.",
  "highlights": [
    "Catching the golden sunset together at the beach",
    "Epic group dinners and late-night laughs",
    "Discovering hidden local spots and cafes",
    "Creating unforgettable bonds that will last a lifetime"
  ],
  "superlatives": {
    "${memberNames.isNotEmpty ? memberNames.first : 'Friend'}": "Chief Explorer & Navigator",
    "${memberNames.length > 1 ? memberNames[1] : 'Friend'}": "Foodie & Cafe Connoisseur"
  }
}
''';

    try {
      final jsonResult = await _aiService.generateStructuredJson(
        messages: [AiMessage(role: AiRole.user, content: prompt)],
        schema: {
          'type': 'object',
          'properties': {
            'title': {'type': 'string'},
            'subtitle': {'type': 'string'},
            'story': {'type': 'string'},
            'highlights': {'type': 'array'},
            'superlatives': {'type': 'object'},
          },
          'required': ['title', 'subtitle', 'story', 'highlights'],
        },
        options: const AiRequestOptions(temperature: 0.7, maxTokens: 1200),
      );

      final title = jsonResult['title'] as String? ?? 'Our $tripName Diaries';
      final subtitle = jsonResult['subtitle'] as String? ??
          '$days Days • ${memberNames.length} Friends • $year';
      final story = jsonResult['story'] as String? ??
          'An unforgettable journey filled with laughter, great food, and memories that will last forever.';
      final highlights = (jsonResult['highlights'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final superlatives = (jsonResult['superlatives'] as Map?)
              ?.map((k, v) => MapEntry(k.toString(), v.toString())) ??
          {};

      final scrapbook = TripScrapbook(
        id: const Uuid().v4(),
        tripId: tripId,
        title: title,
        subtitle: subtitle,
        story: story,
        highlights: highlights,
        superlatives: superlatives,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _memoryRepository.saveScrapbook(scrapbook);
      return scrapbook;
    } catch (e) {
      // Fallback scrapbook
      final fallback = TripScrapbook(
        id: const Uuid().v4(),
        tripId: tripId,
        title: 'Our $tripName Diaries',
        subtitle: '$days Days • ${memberNames.length} Friends • $year',
        story:
            'Unforgettable moments filled with beaches, sunsets, wonderful meals, and bonds that will last forever. Every shared laugh and adventure made this trip special.',
        highlights: [
          'Exploring beautiful sights and local culture',
          'Sharing wonderful group meals and talks',
          'Cherishing sunsets and travel stories',
        ],
        superlatives: {
          for (var m in memberNames.take(3)) m: 'The Life of the Trip',
        },
        createdAt: DateTime.now(),
      );
      await _memoryRepository.saveScrapbook(fallback);
      return fallback;
    }
  }
}
