import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../domain/provisioning_state.dart';
import '../services/user_provisioning_service.dart';

final userProvisioningServiceProvider = Provider<UserProvisioningService>((ref) {
  return UserProvisioningService();
});

/// Streams latest provisioning status updates across all stages.
final provisioningStatusStreamProvider = StreamProvider<ProvisioningResult?>((ref) async* {
  if (UserProvisioningService.lastResult != null) {
    yield UserProvisioningService.lastResult;
  }
  yield* UserProvisioningService.statusStream;
});

class ProvisioningStateNotifier extends Notifier<ProvisioningResult?> {
  @override
  ProvisioningResult? build() {
    return UserProvisioningService.lastResult;
  }

  void setResult(ProvisioningResult? result) {
    state = result;
  }

  Future<ProvisioningResult> retryProvisioning(fb_auth.User user) async {
    final service = ref.read(userProvisioningServiceProvider);
    final previousRetries = state?.retryCount ?? 0;
    
    final inProgress = ProvisioningResult(
      status: ProvisioningStatus.in_progress,
      version: UserProvisioningService.currentProvisioningVersion,
      stage: 'retrying',
      retryCount: previousRetries + 1,
      updatedAt: DateTime.now(),
    );
    state = inProgress;

    final result = await service.retryProvisioning(user, currentRetries: previousRetries);
    state = result;
    return result;
  }

  void reset() {
    UserProvisioningService.resetState();
    state = null;
  }
}

final provisioningStateNotifierProvider =
    NotifierProvider<ProvisioningStateNotifier, ProvisioningResult?>(ProvisioningStateNotifier.new);
