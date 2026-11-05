import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/ai_models.dart';
import '../domain/ai_service_interface.dart';

class ClaudeAiService implements IAiService {
  final String apiKey;
  final String modelName;
  final http.Client _client;

  ClaudeAiService({
    required this.apiKey,
    this.modelName = 'claude-3-5-sonnet-20241022',
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<String> generateText({
    required List<AiMessage> messages,
    AiRequestOptions options = const AiRequestOptions(),
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('Claude API Key is not configured in Firebase.');
    }

    final url = Uri.parse('https://api.anthropic.com/v1/messages');

    String? systemMessage;
    final formattedMessages = <Map<String, dynamic>>[];

    for (final m in messages) {
      if (m.role == AiRole.system) {
        systemMessage = m.content;
      } else {
        formattedMessages.add({
          'role': m.role == AiRole.assistant || m.role == AiRole.model ? 'assistant' : 'user',
          'content': m.content,
        });
      }
    }

    final bodyMap = <String, dynamic>{
      'model': modelName,
      'messages': formattedMessages,
      'max_tokens': options.maxTokens,
      'temperature': options.temperature,
    };
    if (systemMessage != null) {
      bodyMap['system'] = systemMessage;
    }

    final response = await _client.post(
      url,
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode != 200) {
      throw Exception('Claude API Error (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final content = json['content'] as List?;
    if (content == null || content.isEmpty) {
      throw Exception('Claude returned an empty response.');
    }

    return content[0]['text'] as String? ?? '';
  }

  @override
  Future<Map<String, dynamic>> generateStructuredJson({
    required List<AiMessage> messages,
    required Map<String, dynamic> schema,
    AiRequestOptions options = const AiRequestOptions(),
  }) async {
    final systemPrompt = AiMessage(
      role: AiRole.system,
      content: 'Return ONLY valid JSON matching this schema: ${jsonEncode(schema)}. Do not include markdown tags.',
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
