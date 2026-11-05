enum AiRole { user, system, assistant, model }

class AiMessage {
  final AiRole role;
  final String content;

  const AiMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'content': content,
      };

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      role: AiRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => AiRole.user,
      ),
      content: json['content'] as String? ?? '',
    );
  }
}

class AiRequestOptions {
  final double temperature;
  final int maxTokens;
  final Map<String, dynamic>? responseSchema;

  const AiRequestOptions({
    this.temperature = 0.7,
    this.maxTokens = 1024,
    this.responseSchema,
  });
}
