import 'ai_models.dart';

abstract class IAiService {
  /// Generate plain text completion from prompt history
  Future<String> generateText({
    required List<AiMessage> messages,
    AiRequestOptions options = const AiRequestOptions(),
  });

  /// Generate structured JSON matching a target schema
  Future<Map<String, dynamic>> generateStructuredJson({
    required List<AiMessage> messages,
    required Map<String, dynamic> schema,
    AiRequestOptions options = const AiRequestOptions(),
  });

  /// Stream text completion chunks for real-time output
  Stream<String> streamText({
    required List<AiMessage> messages,
    AiRequestOptions options = const AiRequestOptions(),
  });
}
