import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../domain/ai_models.dart';
import '../domain/ai_service_interface.dart';

class GeminiAiService implements IAiService {
  final String apiKey;
  final String modelName;
  final http.Client _client;

  GeminiAiService({
    required this.apiKey,
    this.modelName = 'gemini-1.5-flash',
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<String> generateText({
    required List<AiMessage> messages,
    AiRequestOptions options = const AiRequestOptions(),
    bool isJsonMode = false,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('Gemini API Key is not configured in Firebase.');
    }

    final cleanModelName = modelName.replaceFirst(RegExp(r'^models/'), '').trim();
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$cleanModelName:generateContent?key=$apiKey',
    );

    final contents = messages.map((m) {
      final role = m.role == AiRole.model || m.role == AiRole.assistant ? 'model' : 'user';
      return {
        'role': role,
        'parts': [
          {'text': m.content}
        ],
      };
    }).toList();

    final generationConfig = <String, dynamic>{
      'temperature': options.temperature,
      'maxOutputTokens': options.maxTokens,
    };
    if (isJsonMode) {
      generationConfig['responseMimeType'] = 'application/json';
    }

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': contents,
        'generationConfig': generationConfig,
      }),
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      debugPrint('[GeminiAiService Error] HTTP ${response.statusCode}: ${response.body}');
      throw Exception('Gemini API Error (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      debugPrint('[GeminiAiService Error] Empty candidates in response. Raw body: ${response.body}');
      throw Exception('Gemini returned an empty response.');
    }

    final parts = candidates[0]['content']?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      final finishReason = candidates[0]['finishReason'];
      debugPrint('[GeminiAiService Error] No text parts. Finish reason: $finishReason. Raw body: ${response.body}');
      throw Exception('No text content in Gemini response (Finish reason: $finishReason).');
    }

    return parts[0]['text'] as String? ?? '';
  }

  @override
  Future<Map<String, dynamic>> generateStructuredJson({
    required List<AiMessage> messages,
    required Map<String, dynamic> schema,
    AiRequestOptions options = const AiRequestOptions(maxTokens: 2048),
  }) async {
    final systemPrompt = AiMessage(
      role: AiRole.system,
      content: 'Return ONLY valid JSON matching this schema: ${jsonEncode(schema)}. Do not include markdown code block backticks or preamble text.',
    );

    final jsonOptions = AiRequestOptions(
      temperature: options.temperature,
      maxTokens: options.maxTokens < 2048 ? 2048 : options.maxTokens,
    );

    final responseText = await generateText(
      messages: [systemPrompt, ...messages],
      options: jsonOptions,
      isJsonMode: true,
    );

    final jsonString = _extractJson(responseText);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  static String _extractJson(String text) {
    var cleaned = text.trim();
    cleaned = cleaned.replaceAll(RegExp(r'^```(json)?', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'```$', multiLine: true), '').trim();

    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return cleaned.substring(start, end + 1);
    }
    return cleaned;
  }

  @override
  Stream<String> streamText({
    required List<AiMessage> messages,
    AiRequestOptions options = const AiRequestOptions(),
  }) async* {
    // Basic streaming fallback or REST text return
    final fullText = await generateText(messages: messages, options: options);
    yield fullText;
  }
}
