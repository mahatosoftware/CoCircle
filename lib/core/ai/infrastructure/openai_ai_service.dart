import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/ai_models.dart';
import '../domain/ai_service_interface.dart';

class OpenAiService implements IAiService {
  final String apiKey;
  final String modelName;
  final String baseUrl;
  final http.Client _client;

  OpenAiService({
    required this.apiKey,
    this.modelName = 'gpt-4o-mini',
    this.baseUrl = 'https://api.openai.com/v1',
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<String> generateText({
    required List<AiMessage> messages,
    AiRequestOptions options = const AiRequestOptions(),
  }) async {
    if (apiKey.isEmpty &&
        !baseUrl.contains('localhost') &&
        !baseUrl.contains('127.0.0.1')) {
      throw Exception('OpenAI API Key is not configured in Firebase.');
    }

    final url = Uri.parse('$baseUrl/chat/completions');

    final formattedMessages = messages.map((m) {
      return {
        'role': m.role == AiRole.assistant || m.role == AiRole.model
            ? 'assistant'
            : m.role.name,
        'content': m.content,
      };
    }).toList();

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    final response = await _client
        .post(
          url,
          headers: headers,
          body: jsonEncode({
            'model': modelName,
            'messages': formattedMessages,
            'temperature': options.temperature,
            'max_tokens': options.maxTokens,
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw Exception(
        'OpenAI API Error (${response.statusCode}): ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw Exception('OpenAI returned empty response.');
    }

    return choices[0]['message']['content'] as String? ?? '';
  }

  @override
  Future<Map<String, dynamic>> generateStructuredJson({
    required List<AiMessage> messages,
    required Map<String, dynamic> schema,
    AiRequestOptions options = const AiRequestOptions(),
  }) async {
    final systemPrompt = AiMessage(
      role: AiRole.system,
      content:
          'Return ONLY valid JSON matching this schema: ${jsonEncode(schema)}. Do not include any text, explanations, or codeblocks.',
    );

    final responseText = await generateText(
      messages: [systemPrompt, ...messages],
      options: options,
    );

    final cleaned = responseText.replaceAll(RegExp(r'```json|```'), '').trim();
    return jsonDecode(cleaned) as Map<String, dynamic>;
  }

  @override
  Stream<String> streamText({
    required List<AiMessage> messages,
    AiRequestOptions options = const AiRequestOptions(),
  }) async* {
    final fullText = await generateText(messages: messages, options: options);
    yield fullText;
  }
}
