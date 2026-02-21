import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'circle_controller.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../auth/domain/user_model.dart';
import 'package:cocircle/features/notifications/presentation/notification_controller.dart';
import 'package:cocircle/features/notifications/domain/notification_model.dart';
import '../domain/circle_model.dart';
import 'package:cocircle/l10n/app_localizations.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/native_ad_widget.dart';

class MyCirclesScreen extends ConsumerWidget {
  const MyCirclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circlesAsync = ref.watch(userCirclesProvider);
    final pendingApprovalsAsync = ref.watch(pendingApprovalsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final totalNotificationCount = (pendingApprovalsAsync.value?.length ?? 0) + unreadCount;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => context.push('/profile'),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () => _showNotifications(context, ref),
              ),
              if (totalNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$totalNotificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
         IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: circlesAsync.when(
        data: (circles) {
          if (circles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.group_off_outlined, size: 60, color: Colors.grey),
                   const SizedBox(height: 16),
                   Text(l10n.noCircles, style: Theme.of(context).textTheme.titleMedium),
                   const SizedBox(height: 8),
                   ElevatedButton(
                     onPressed: () => _showAddOptions(context),
                     child: Text(l10n.getStarted),
                   )
                ],
              ),
            );
          }
          return StreamBuilder<UserModel?>(
            stream: ref.watch(authRepositoryProvider).authStateChanges,
            builder: (context, snapshot) {
              final currentUser = snapshot.data;
              if (currentUser == null) return const Center(child: CircularProgressIndicator());

              final int adInterval = 3;
              final int totalItems = circles.length + (circles.length / adInterval).floor();

              return ListView.builder(
                itemCount: totalItems,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  if (index > 0 && (index + 1) % (adInterval + 1) == 0) {
                    return const NativeAdWidget();
                  }

                  final circleIndex = index - (index / (adInterval + 1)).floor();
                  if (circleIndex >= circles.length) return const SizedBox.shrink();
                  
                  final circle = circles[circleIndex];
                  final pendingCount = circle.pendingMemberIds.length;
                  final isAdmin = circle.adminIds.contains(currentUser.uid);
                  final showBadge = isAdmin && pendingCount > 0;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppPallete.primary,
                        child: Text(circle.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(circle.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(circle.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                          if (showBadge) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.info_outline, size: 14, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.pendingRequest(pendingCount),
                                    style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                         context.push('/circle/${circle.id}');
                      },
                    ),
                  );
                },
              );
            }
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(l10n.errorWithDetails(err.toString()))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add_circle_outline, size: 28),
                title: Text(AppLocalizations.of(context)!.createCircleTitle),
                onTap: () {
                  context.pop();
                  context.push('/create-circle');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.group_add_outlined, size: 28),
                title: Text(AppLocalizations.of(context)!.joinCircleTitle),
                onTap: () {
                   context.pop();
                   context.push('/join-circle');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showNotifications(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            final pendingCircles = ref.watch(pendingApprovalsProvider).value ?? [];
            final notifications = ref.watch(userNotificationsProvider).value ?? [];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notifications',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (notifications.any((n) => !n.isRead))
                        TextButton(
                          onPressed: () => ref.read(notificationControllerProvider.notifier).markAllAsRead(),
                          child: Text(AppLocalizations.of(context)!.markAllAsRead),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        if (pendingCircles.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(AppLocalizations.of(context)!.circleRequests, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          ),
                          ...pendingCircles.map((circle) {
                            final count = circle.pendingMemberIds.length;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.withValues(alpha: 0.1),
                                child: const Icon(Icons.group_add, color: Colors.orange),
                              ),
                              title: Text(circle.name),
                              subtitle: Text(AppLocalizations.of(context)!.waitingSummary(count)),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                context.pop();
                                context.push('/circle/${circle.id}/settings');
                              },
                            );
                          }),
                          const Divider(),
                        ],
                        if (notifications.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(AppLocalizations.of(context)!.recentActivity, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          ),
                          ...notifications.map((n) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: n.isRead ? Colors.grey[100] : AppPallete.primary.withValues(alpha: 0.1),
                              child: Icon(
                                _getNotificationIcon(n.type),
                                color: n.isRead ? Colors.grey : AppPallete.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              n.title,
                              style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.body),
                                Text(
                                  _formatTimestamp(n.timestamp, context),
                                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            onTap: () {
                              ref.read(notificationControllerProvider.notifier).markAsRead(n.id);
                              context.pop();
                              context.push(n.targetPath);
                            },
                          )),
                        ],
                        if (pendingCircles.isEmpty && notifications.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(child: Text(AppLocalizations.of(context)!.allCaughtUp)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.expenseAdded: return Icons.add_shopping_cart;
      case NotificationType.expenseUpdated: return Icons.edit_note;
      case NotificationType.expenseDeleted: return Icons.delete_sweep;
      case NotificationType.circleJoinRequest: return Icons.person_add;
      case NotificationType.pollCreated: return Icons.poll;
      case NotificationType.pollOptionAdded: return Icons.add_chart;
      case NotificationType.pollUpdated: return Icons.edit_calendar;
    }
  }

  String _formatTimestamp(DateTime dt, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }
}
