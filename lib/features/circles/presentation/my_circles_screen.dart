import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'circle_controller.dart';
import '../../trips/presentation/trip_controller.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class MyCirclesScreen extends ConsumerStatefulWidget {
  const MyCirclesScreen({super.key});

  @override
  ConsumerState<MyCirclesScreen> createState() => _MyCirclesScreenState();
}

class _MyCirclesScreenState extends ConsumerState<MyCirclesScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circlesAsync = ref.watch(userCirclesProvider);
    final allTripsAsync = ref.watch(allUserTripsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
      appBar: AppBar(
        titleSpacing: 20,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search circles...',
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              )
            : Text(
                'My Circles',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : AppPallete.navy,
                ),
              ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              size: 24,
              color: isDark ? Colors.white : AppPallete.navy,
            ),
            tooltip: _isSearching ? 'Close search' : 'Search circles',
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.add_rounded,
              size: 26,
              color: isDark ? Colors.white : AppPallete.navy,
            ),
            tooltip: 'Create or Join Circle',
            onPressed: () => _showAddOptions(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: circlesAsync.when(
        data: (circles) {
          final filteredCircles = _searchQuery.isEmpty
              ? circles
              : circles.where((c) => c.name.toLowerCase().contains(_searchQuery)).toList();

          if (circles.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.groups_rounded,
              title: 'No Circles Yet',
              description: 'Create a Circle for your friends, family, or travel group to start collaborating on trips.',
              actionLabel: 'Create Circle',
              onAction: () => _showAddOptions(context),
            );
          }

          // Build map of trips count per circle
          final tripsByCircle = <String, int>{};
          allTripsAsync.whenData((trips) {
            for (final t in trips) {
              tripsByCircle[t.circleId] = (tripsByCircle[t.circleId] ?? 0) + 1;
            }
          });

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
                  ...filteredCircles.map((circle) {
                    final tripsCount = tripsByCircle[circle.id] ?? 2;
                    final membersCount = circle.memberIds.length;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppPallete.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => context.push('/circle/${circle.id}'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  // Circle Avatar
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppPallete.indigo.withValues(alpha: 0.8),
                                          AppPallete.indigo,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: circle.imageUrl != null && circle.imageUrl!.isNotEmpty
                                        ? ClipOval(
                                            child: Image.network(
                                              circle.imageUrl!,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Text(
                                                circle.name.isNotEmpty ? circle.name[0].toUpperCase() : 'C',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            circle.name.isNotEmpty ? circle.name[0].toUpperCase() : 'C',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Circle Name & Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          circle.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            letterSpacing: -0.2,
                                            color: isDark ? Colors.white : AppPallete.navy,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '$membersCount members • $tripsCount trips',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Chevron
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // "Create a Circle" bottom action card banner (from Wireframe 1 Screen 2)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppPallete.indigo.withValues(alpha: 0.2),
                        width: 1.2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push('/create-circle'),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppPallete.indigo.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.groups_rounded,
                                  color: AppPallete.indigo,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Create a Circle',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppPallete.indigo,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Start a group for trips, events and more',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppPallete.gray,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: AppPallete.indigo,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading circles: $err')),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Add or Join a Circle',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppPallete.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded, color: AppPallete.primary),
                  ),
                  title: const Text('Create New Circle', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Start a fresh space for your friends or family'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/create-circle');
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.group_add_rounded, color: Colors.amber),
                  ),
                  title: const Text('Join with Code', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Enter an invite code from a circle admin'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/join-circle');
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.blue),
                  ),
                  title: const Text('Scan QR Code', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Quickly scan a circle invite QR'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/scan-qr');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
