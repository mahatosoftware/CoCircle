import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../circles/presentation/circle_controller.dart';
import '../data/guest_invite_service.dart';

class GuestGroupPreviewScreen extends ConsumerWidget {
  final String code;

  const GuestGroupPreviewScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewAsync = ref.watch(guestPreviewProvider(code));
    final authUser = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Invitation'),
        actions: [
          if (authUser != null)
            IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: 'My Circles',
              onPressed: () => context.go('/'),
            ),
        ],
      ),
      body: previewAsync.when(
        data: (preview) {
          if (preview == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.link_off, size: 70, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Invalid or Expired Invitation',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The code "$code" is either invalid, revoked, or has expired.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/join-circle'),
                      child: const Text('Enter Code Manually'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Group Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'GROUP INVITATION • ACTIVE',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            preview.tripName ?? preview.circleName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (preview.tripName != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Part of "${preview.circleName}"',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildHeroPill(Icons.people_outline, '${preview.memberCount} Friends'),
                              if (preview.location != null)
                                _buildHeroPill(Icons.place_outlined, preview.location!),
                              if (preview.datesString != null)
                                _buildHeroPill(Icons.calendar_today_outlined, preview.datesString!),
                              if (preview.totalBudget > 0)
                                _buildHeroPill(
                                  Icons.payments_outlined,
                                  'Budget: ${preview.currency} ${preview.totalBudget.toStringAsFixed(0)}',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section: What's Happening
                    const Text(
                      'What\'s Happening in the Group',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Open Polls Preview
                    if (preview.openPolls.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.poll_outlined, color: Colors.indigo, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Active Polls (${preview.openPolls.length})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...preview.openPolls.map((poll) {
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  poll.question,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 10),
                                ...poll.options.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final opt = entry.value;
                                  final count = idx < poll.voteCounts.length ? poll.voteCounts[idx] : 0;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(opt, style: const TextStyle(fontSize: 13)),
                                        Text('$count votes', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],

                    // Itinerary Highlights
                    if (preview.itineraryHighlights.isNotEmpty) ...[
                      const Row(
                        children: [
                          Icon(Icons.explore_outlined, color: Colors.teal, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Itinerary Preview',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: preview.itineraryHighlights.map((act) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, size: 14, color: Colors.teal),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(act, style: const TextStyle(fontSize: 13))),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Quick perks card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Why join on CoCircle?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          SizedBox(height: 6),
                          Text('• Split group expenses fairly with zero manual math', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 2),
                          Text('• Vote on group decisions and travel plans', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 2),
                          Text('• Save permanent memories & AI digital scrapbooks together', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Sticky Bottom Call-to-Action Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (authUser != null) {
                            // Already authenticated - execute join
                            ref.read(circleControllerProvider.notifier).joinCircleByCode(
                              code: code,
                              context: context,
                            );
                          } else {
                            // Guide guest to log in / sign up and then return to join
                            context.push('/login');
                          }
                        },
                        icon: const Icon(Icons.group_add),
                        label: Text(
                          authUser != null
                              ? 'Join "${preview.circleName}"'
                              : 'Sign in to Join "${preview.circleName}"',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading invitation: $e')),
      ),
    );
  }

  Widget _buildHeroPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
