import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/ai_config_model.dart';
import 'data/firebase_ai_config_repository.dart';
import 'domain/ai_service_interface.dart';
import 'infrastructure/claude_ai_service.dart';
import 'infrastructure/gemini_ai_service.dart';
import 'infrastructure/openai_ai_service.dart';
import 'infrastructure/proxy_ai_service.dart';

/// Active AI Configuration state (defaults to empty until fetched from Firebase)
final aiConfigStateProvider = Provider<AiConfigModel>((ref) {
  final asyncConfig = ref.watch(aiConfigStreamProvider);
  return asyncConfig.asData?.value ?? AiConfigModel.empty();
});

/// Riverpod provider returning active IAiService implementation.
/// Automatically reconstructs when Firebase config changes in real-time.
final aiServiceProvider = Provider<IAiService>((ref) {
  final config = ref.watch(aiConfigStateProvider);

  if (!config.enabled) {
    throw Exception('AI features are currently disabled in Firebase config.');
  }

  switch (config.activeProvider.toLowerCase()) {
    case 'openai':
      return OpenAiService(
        apiKey: config.openaiApiKey,
        modelName: config.openaiModel,
        baseUrl: config.openaiBaseUrl,
      );

    case 'claude':
      return ClaudeAiService(
        apiKey: config.claudeApiKey,
        modelName: config.claudeModel,
      );

    case 'proxy':
      return ProxyAiService(
        proxyUrl: config.proxyUrl,
      );

    case 'gemini':
    default:
      return GeminiAiService(
        apiKey: config.geminiApiKey,
        modelName: config.geminiModel,
      );
  }
});
