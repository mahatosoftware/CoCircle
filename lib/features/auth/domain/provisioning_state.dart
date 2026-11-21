import 'user_model.dart';

enum ProvisioningStatus {
  pending,
  in_progress,
  completed,
  failed,
  needs_repair,
}

enum ProvisioningErrorType {
  network,
  permission,
  application,
}

class ProvisioningResult {
  final ProvisioningStatus status;
  final UserModel? user;
  final String? error;
  final ProvisioningErrorType? errorType;
  final int version;
  final String? stage;
  final int retryCount;
  final DateTime updatedAt;

  const ProvisioningResult({
    required this.status,
    this.user,
    this.error,
    this.errorType,
    this.version = 1,
    this.stage,
    this.retryCount = 0,
    required this.updatedAt,
  });

  bool get isCompleted => status == ProvisioningStatus.completed && user != null;
  bool get isFailed => status == ProvisioningStatus.failed;
  bool get isNeedsRepair => status == ProvisioningStatus.needs_repair;

  ProvisioningResult copyWith({
    ProvisioningStatus? status,
    UserModel? user,
    String? error,
    ProvisioningErrorType? errorType,
    int? version,
    String? stage,
    int? retryCount,
    DateTime? updatedAt,
  }) {
    return ProvisioningResult(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      errorType: errorType ?? this.errorType,
      version: version ?? this.version,
      stage: stage ?? this.stage,
      retryCount: retryCount ?? this.retryCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'provisioningStatus': status.name,
      'provisioningVersion': version,
      'provisioningUpdatedAt': updatedAt.toIso8601String(),
      if (stage != null) 'provisioningStage': stage,
      if (error != null) 'provisioningError': error,
      if (errorType != null) 'provisioningErrorType': errorType!.name,
      'provisioningRetryCount': retryCount,
    };
  }

  factory ProvisioningResult.fromMap(Map<String, dynamic> map, {UserModel? user}) {
    final statusStr = map['provisioningStatus'] as String?;
    final status = ProvisioningStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => ProvisioningStatus.pending,
    );

    final errorTypeStr = map['provisioningErrorType'] as String?;
    final errorType = errorTypeStr != null
        ? ProvisioningErrorType.values.firstWhere(
            (e) => e.name == errorTypeStr,
            orElse: () => ProvisioningErrorType.application,
          )
        : null;

    DateTime parsedDate;
    final rawDate = map['provisioningUpdatedAt'];
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return ProvisioningResult(
      status: status,
      user: user,
      error: map['provisioningError'] as String?,
      errorType: errorType,
      version: map['provisioningVersion'] as int? ?? 1,
      stage: map['provisioningStage'] as String?,
      retryCount: map['provisioningRetryCount'] as int? ?? 0,
      updatedAt: parsedDate,
    );
  }
}
