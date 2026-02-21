import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/snackbar.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../notifications/domain/notification_model.dart';
import '../../notifications/data/notification_repository_impl.dart';
import '../../circles/presentation/circle_controller.dart';
import '../../trips/presentation/trip_controller.dart';
import '../data/poll_repository_impl.dart';
import '../domain/poll_model.dart';

part 'poll_controller.g.dart';

@riverpod
class PollController extends _$PollController {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  Future<void> createPoll({
    required String tripId,
    required String question,
    required List<String> optionTexts,
    required bool allowMultipleSelections,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    final pollRepository = ref.read(pollRepositoryProvider);

    final user = await authRepository.getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    final pollId = const Uuid().v4();
    final now = DateTime.now();

    final poll = PollModel(
      id: pollId,
      tripId: tripId,
      creatorId: user.uid,
      question: question,
      options: optionTexts.map((text) => PollOption(text: text)).toList(),
      allowMultipleSelections: allowMultipleSelections,
      createdAt: now,
    );

    final result = await pollRepository.createPoll(poll);

    if (state.isLoading) {
      await result.fold(
        (l) async {
          state = AsyncError(l.message, StackTrace.current);
          showSnackBar(context, l.message);
        },
        (r) async {
          state = const AsyncData(null);
          Navigator.pop(context);
          showSnackBar(context, 'Poll created successfully!');

          // Send notifications
          final tripRes = await ref.read(tripDetailsProvider(tripId).future);
          final members = await ref.read(circleMembersProvider(tripRes.circleId).future);
          final notificationRepo = ref.read(notificationRepositoryProvider);

          for (final member in members) {
            if (member.uid != user.uid) {
              final notification = NotificationModel(
                id: const Uuid().v4(),
                title: 'New Poll Created',
                body: '${user.displayName} created a new poll: $question',
                type: NotificationType.pollCreated,
                targetPath: '/trip/$tripId?tab=polls',
                timestamp: DateTime.now(),
                recipientUid: member.uid,
                senderUid: user.uid,
                senderName: user.displayName,
                tripId: tripId,
              );
              await notificationRepo.sendNotification(notification);
            }
          }
        },
      );
    }
  }

  Future<void> vote({
    required String pollId,
    required int optionIndex,
    required BuildContext context,
  }) async {
    final authRepository = ref.read(authRepositoryProvider);
    final pollRepository = ref.read(pollRepositoryProvider);

    final user = await authRepository.getCurrentUser();
    if (user == null) return;

    final result = await pollRepository.vote(pollId, user.uid, optionIndex);

    result.fold(
      (l) => showSnackBar(context, l.message),
      (r) => null,
    );
  }

  Future<void> closePoll({
    required String pollId,
    required BuildContext context,
  }) async {
    final pollRepository = ref.read(pollRepositoryProvider);
    final result = await pollRepository.closePoll(pollId);
    result.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, 'Poll closed'),
    );
  }

  Future<void> addOption({
    required String pollId,
    required String tripId,
    required String question,
    required String optionText,
    required BuildContext context,
  }) async {
    final pollRepository = ref.read(pollRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);
    
    final user = await authRepository.getCurrentUser();
    if (user == null) return;

    final result = await pollRepository.addOption(pollId, optionText);

    await result.fold(
      (l) async => showSnackBar(context, l.message),
      (r) async {
        showSnackBar(context, 'Option added!');
        
        // Send notifications
        final tripRes = await ref.read(tripDetailsProvider(tripId).future);
        final members = await ref.read(circleMembersProvider(tripRes.circleId).future);
        final notificationRepo = ref.read(notificationRepositoryProvider);

        for (final member in members) {
          if (member.uid != user.uid) {
            // Notify everyone in the circle when a new option is added
            final notification = NotificationModel(
              id: const Uuid().v4(),
              title: 'New Option Added to Poll',
              body: '${user.displayName} added "$optionText" to poll: $question',
              type: NotificationType.pollOptionAdded,
              targetPath: '/trip/$tripId?tab=polls',
              timestamp: DateTime.now(),
              recipientUid: member.uid,
              senderUid: user.uid,
              senderName: user.displayName,
              tripId: tripId,
            );
            await notificationRepo.sendNotification(notification);
          }
        }
      },
    );
  }

  Future<void> updatePoll({
    required PollModel poll,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(pollRepositoryProvider).updatePoll(poll);
    result.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) async {
        state = const AsyncData(null);
        showSnackBar(context, 'Poll updated successfully!');

        // Send notifications
        final authRepo = ref.read(authRepositoryProvider);
        final user = await authRepo.getCurrentUser();
        if (user == null) return;

        final tripRes = await ref.read(tripDetailsProvider(poll.tripId).future);
        final members = await ref.read(circleMembersProvider(tripRes.circleId).future);
        final notificationRepo = ref.read(notificationRepositoryProvider);

        for (final member in members) {
          if (member.uid != user.uid) {
            final notification = NotificationModel(
              id: const Uuid().v4(),
              title: 'Poll Updated',
              body: '${user.displayName} updated the poll: ${poll.question}',
              type: NotificationType.pollUpdated,
              targetPath: '/trip/${poll.tripId}?tab=polls',
              timestamp: DateTime.now(),
              recipientUid: member.uid,
              senderUid: user.uid,
              senderName: user.displayName,
              tripId: poll.tripId,
            );
            await notificationRepo.sendNotification(notification);
          }
        }
      },
    );
  }

  Future<void> deletePoll({
    required String pollId,
    required BuildContext context,
  }) async {
    final result = await ref.read(pollRepositoryProvider).deletePoll(pollId);
    result.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, 'Poll deleted'),
    );
  }
}

@riverpod
Stream<List<PollModel>> tripPolls(Ref ref, String tripId) {
  return ref.watch(pollRepositoryProvider).getPollsStream(tripId).map((polls) {
    final sorted = List<PollModel>.from(polls)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  });
}
