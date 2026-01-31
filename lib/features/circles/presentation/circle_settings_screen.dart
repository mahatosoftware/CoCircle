import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../auth/domain/user_model.dart';
import 'circle_controller.dart';

final circleMembersProvider = FutureProvider.family<List<UserModel>, List<String>>((ref, memberIds) async {
  if (memberIds.isEmpty) return [];
  return ref.watch(authRepositoryProvider).getUsersByIds(memberIds);
});

class CircleSettingsScreen extends ConsumerWidget {
  final String circleId;
  const CircleSettingsScreen({super.key, required this.circleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circleAsync = ref.watch(circleDetailsProvider(circleId));
    // getCurrentUser is Future. 
    // I should probably use a FutureProvider for user or just use authStateChanges.
    // Let's use authStateChanges which gives Stream<UserModel?>.
    // Stream usage is tricky inside build without StreamBuilder/ref.watch logic for streams.
    // Let's just use a simple FutureProvider for "currentUser" or better:
    // The authRepositoryProvider has `getCurrentUser`. 
    // Let's wrap user fetching in a provider or handle it in the body.
    
    return Scaffold(
      appBar: AppBar(title: const Text('Circle Settings')),
      body: circleAsync.when(
        data: (circle) {
           return StreamBuilder<UserModel?>(
             stream: ref.watch(authRepositoryProvider).authStateChanges,
             builder: (context, snapshot) {
                final currentUser = snapshot.data;
                final isUserAdmin = currentUser != null && circle.adminIds.contains(currentUser.uid);
                
                final membersAsync = ref.watch(circleMembersProvider(circle.memberIds));
                final pendingAsync = ref.watch(circleMembersProvider(circle.pendingMemberIds));
                final inviteLink = 'https://cocircle.app/join/${circle.code}';

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ... Cards ...
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Text(circle.name, style: Theme.of(context).textTheme.headlineSmall),
                              const SizedBox(height: 8),
                              Text('Code: ${circle.code}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                              const SizedBox(height: 24),
                              QrImageView(
                                data: circle.code,
                                version: QrVersions.auto,
                                size: 200.0,
                                backgroundColor: Colors.white,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.share),
                                  label: const Text('Share Invite Link'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppPallete.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: () {
                                    // ignore: deprecated_member_use
                                    Share.share('Join my circle "${circle.name}" on CoCircle! Use code: ${circle.code} or click here: $inviteLink');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),

                      // Pending Requests
                      if (isUserAdmin && circle.pendingMemberIds.isNotEmpty) ...[
                         Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Pending Requests (${circle.pendingMemberIds.length})', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.orange)),
                          ),
                          const SizedBox(height: 8),
                          pendingAsync.when(
                            data: (pending) => ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: pending.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final member = pending[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: member.photoUrl != null ? NetworkImage(member.photoUrl!) : null,
                                    child: member.photoUrl == null ? Text(member.displayName[0].toUpperCase()) : null,
                                  ),
                                  title: Text(member.displayName),
                                  subtitle: Text(member.email),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        onPressed: () => ref.read(circleControllerProvider.notifier).approveMember(circleId: circle.id, memberId: member.uid, context: context),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () => ref.read(circleControllerProvider.notifier).rejectMember(circleId: circle.id, memberId: member.uid, context: context),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, s) => Text('Error: $e'),
                          ),
                          const SizedBox(height: 32),
                      ],
                      // Members List
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Members (${circle.memberIds.length})', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),

                      membersAsync.when(
                        data: (members) => ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: members.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final member = members[index];
                            final isMemberAdmin = circle.adminIds.contains(member.uid);
                            final isSelf = currentUser?.uid == member.uid;
                            
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: member.photoUrl != null ? NetworkImage(member.photoUrl!) : null,
                                child: member.photoUrl == null ? Text(member.displayName[0].toUpperCase()) : null,
                              ),
                              title: Row(
                                children: [
                                  Text(member.displayName),
                                  if (isMemberAdmin) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                      child: const Text('Admin', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold))
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Text(member.email),
                              trailing: (isUserAdmin && !isSelf) 
                                ? PopupMenuButton<String>(
                                    itemBuilder: (context) => [
                                      if (!isMemberAdmin)
                                        const PopupMenuItem(
                                          value: 'promote',
                                          child: Row(
                                            children: [
                                              Icon(Icons.security, size: 20, color: Colors.orange),
                                              SizedBox(width: 8),
                                              Text('Make Admin'),
                                            ],
                                          ),
                                        ),
                                      if (isMemberAdmin)
                                        const PopupMenuItem(
                                          value: 'demote',
                                          child: Row(
                                            children: [
                                              Icon(Icons.security_update_warning, size: 20, color: Colors.orange),
                                              SizedBox(width: 8),
                                              Text('Demote to Member'),
                                            ],
                                          ),
                                        ),
                                      const PopupMenuItem(
                                        value: 'remove',
                                        child: Row(
                                          children: [
                                            Icon(Icons.person_remove, size: 20, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Remove Member', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'promote') {
                                        ref.read(circleControllerProvider.notifier).promoteToAdmin(
                                          circleId: circle.id, 
                                          memberId: member.uid, 
                                          context: context
                                        );
                                      } else if (value == 'demote') {
                                        ref.read(circleControllerProvider.notifier).demoteFromAdmin(
                                          circleId: circle.id, 
                                          memberId: member.uid, 
                                          context: context
                                        );
                                      } else if (value == 'remove') {
                                        // Confirm dialog for removal
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Remove Member?'),
                                            content: Text('Are you sure you want to remove ${member.displayName} from this circle?'),
                                            actions: [
                                              TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
                                              TextButton(
                                                onPressed: () {
                                                  context.pop();
                                                  ref.read(circleControllerProvider.notifier).removeMember(
                                                    circleId: circle.id, 
                                                    memberId: member.uid, 
                                                    context: context,
                                                    isSelf: false,
                                                  );
                                                }, 
                                                child: const Text('Remove', style: TextStyle(color: Colors.red))
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.more_vert),
                                  )
                                : null,
                            );
                          },
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error loading members: $e'),
                      ),

                      const SizedBox(height: 40),
                      
                      // Leave Circle Button
                      if (currentUser != null) 
                         SizedBox(
                           width: double.infinity,
                           child: OutlinedButton.icon(
                             onPressed: () {
                                // Successor rule: If user is the ONLY admin, they must promote someone else first
                                final otherAdmins = circle.adminIds.where((id) => id != currentUser.uid).toList();
                                
                                if (isUserAdmin && otherAdmins.isEmpty && circle.memberIds.length > 1) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Cannot Leave Circle'),
                                      content: const Text('You are the only admin. Please promote another member to admin before leaving.'),
                                      actions: [
                                        TextButton(onPressed: () => context.pop(), child: const Text('OK')),
                                      ],
                                    ),
                                  );
                                  return;
                                }

                                // Confirm dialog
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Leave Circle?'),
                                    content: const Text('Are you sure you want to leave this circle?'),
                                    actions: [
                                      TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () {
                                          context.pop();
                                          ref.read(circleControllerProvider.notifier).removeMember(
                                             circleId: circle.id, 
                                             memberId: currentUser.uid, 
                                             context: context,
                                             isSelf: true
                                          );
                                        }, 
                                        child: const Text('Leave', style: TextStyle(color: Colors.red))
                                      ),
                                    ],
                                  ),
                                );
                              },
                             icon: const Icon(Icons.exit_to_app, color: Colors.red),
                             label: const Text('Leave Circle', style: TextStyle(color: Colors.red)),
                             style: OutlinedButton.styleFrom(
                               side: const BorderSide(color: Colors.red),
                               padding: const EdgeInsets.symmetric(vertical: 12),
                             ),
                           ),
                         ),
                       const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    ),
    );
  }
}
