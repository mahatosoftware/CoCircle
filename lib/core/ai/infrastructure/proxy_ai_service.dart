import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/ai_models.dart';
import '../domain/ai_service_interface.dart';

class ProxyAiService implements IAiService {
  final String proxyUrl;
  final http.Client _client;

  ProxyAiService({
    required this.proxyUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<String> generateText({
    required List<AiMessage> messages,
    AiRequestOptions options = const AiRequestOptions(),
  }) async {
    if (proxyUrl.isEmpty) {
      throw Exception('Proxy URL is not configured in Firebase AI Config.');
    }

    final response = await _client.post(
      Uri.parse(proxyUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'messages': messages.map((m) => m.toJson()).toList(),
        'temperature': options.temperature,
        'maxTokens': options.maxTokens,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('AI Proxy Error (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['text'] as String? ?? json['content'] as String? ?? '';
  }

  @override
  Future<Map<String, dynamic>> generateStructuredJson({
    required List<AiMessage> messages,
    required Map<String, dynamic> schema,
    AiRequestOptions options = const AiRequestOptions(),
  }) async {
    final responseText = await generateText(
      messages: messages,
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
