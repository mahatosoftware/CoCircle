class AiConfigModel {
  final String activeProvider; // 'openai', 'gemini', 'claude', 'proxy'
  final String geminiApiKey;
  final String geminiModel;
  final String openaiApiKey;
  final String openaiModel;
  final String openaiBaseUrl;
  final String claudeApiKey;
  final String claudeModel;
  final String proxyUrl;
  final bool enabled;

  const AiConfigModel({
    required this.activeProvider,
    required this.geminiApiKey,
    required this.geminiModel,
    required this.openaiApiKey,
    required this.openaiModel,
    required this.openaiBaseUrl,
    required this.claudeApiKey,
    required this.claudeModel,
    required this.proxyUrl,
    required this.enabled,
  });

  factory AiConfigModel.empty() {
    const envGeminiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    const envOpenAiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
    return const AiConfigModel(
      activeProvider: 'gemini',
      geminiApiKey: envGeminiKey,
      geminiModel: 'gemini-1.5-flash',
      openaiApiKey: envOpenAiKey,
      openaiModel: 'gpt-4o-mini',
      openaiBaseUrl: 'https://api.openai.com/v1',
      claudeApiKey: '',
      claudeModel: 'claude-3-5-sonnet-20241022',
      proxyUrl: '',
      enabled: true,
    );
  }

  factory AiConfigModel.fromJson(Map<String, dynamic> json) {
    const envGeminiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    const envOpenAiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

    final firestoreGeminiKey = json['geminiApiKey'] as String? ?? '';
    final firestoreOpenAiKey = json['openaiApiKey'] as String? ?? '';

    return AiConfigModel(
      activeProvider: json['activeProvider'] as String? ?? 'gemini',
      geminiApiKey: firestoreGeminiKey.isNotEmpty ? firestoreGeminiKey : envGeminiKey,
      geminiModel: json['geminiModel'] as String? ?? 'gemini-1.5-flash',
      openaiApiKey: firestoreOpenAiKey.isNotEmpty ? firestoreOpenAiKey : envOpenAiKey,
      openaiModel: json['openaiModel'] as String? ?? 'gpt-4o-mini',
      openaiBaseUrl:
          json['openaiBaseUrl'] as String? ?? 'https://api.openai.com/v1',
      claudeApiKey: json['claudeApiKey'] as String? ?? '',
      claudeModel:
          json['claudeModel'] as String? ?? 'claude-3-5-sonnet-20241022',
      proxyUrl: json['proxyUrl'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeProvider': activeProvider,
      'geminiApiKey': geminiApiKey,
      'geminiModel': geminiModel,
      'openaiApiKey': openaiApiKey,
      'openaiModel': openaiModel,
      'openaiBaseUrl': openaiBaseUrl,
      'claudeApiKey': claudeApiKey,
      'claudeModel': claudeModel,
      'proxyUrl': proxyUrl,
      'enabled': enabled,
    };
  }
}
