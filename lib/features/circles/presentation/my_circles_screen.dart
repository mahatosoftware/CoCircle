import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'circle_controller.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../auth/domain/user_model.dart';
import '../../../../core/theme/app_pallete.dart';

class MyCirclesScreen extends ConsumerWidget {
  const MyCirclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circlesAsync = ref.watch(userCirclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Circles'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => context.push('/profile'),
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
                   Text('No circles yet', style: Theme.of(context).textTheme.titleMedium),
                   const SizedBox(height: 8),
                   ElevatedButton(
                     onPressed: () => _showAddOptions(context),
                     child: const Text('Get Started'),
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

              return ListView.builder(
                itemCount: circles.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final circle = circles[index];
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
                                    '$pendingCount Pending Request${pendingCount > 1 ? 's' : ''}',
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
        error: (err, stack) => Center(child: Text('Error: $err')),
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
                title: const Text('Create New Circle'),
                onTap: () {
                  context.pop();
                  context.push('/create-circle');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.group_add_outlined, size: 28),
                title: const Text('Join Existing Circle'),
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
}
