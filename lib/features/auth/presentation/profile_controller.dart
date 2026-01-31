import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_repository_impl.dart';
import 'package:cocircle/core/utils/snackbar.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> updateProfile({
    required String name,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).updateUserProfile(name: name);
    
    result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        showSnackBar(context, 'Failed to update profile: ${failure.message}');
      },
      (_) {
        state = const AsyncData(null);
        showSnackBar(context, 'Profile updated successfully!');
      },
    );
  }
}
