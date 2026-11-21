import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../domain/circle_model.dart';
import 'circle_controller.dart';
import '../../trips/domain/trip_model.dart';
import '../../trips/presentation/trip_controller.dart';
import '../../trips/presentation/widgets/add_participant_sheet.dart';
import '../../auth/domain/user_model.dart';

class CircleDetailScreen extends ConsumerStatefulWidget {
  final String circleId;
  const CircleDetailScreen({super.key, required this.circleId});

  @override
  ConsumerState<CircleDetailScreen> createState() => _CircleDetailScreenState();
}

class _CircleDetailScreenState extends ConsumerState<CircleDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circleAsync = ref.watch(circleDetailsProvider(widget.circleId));
    final tripsAsync = ref.watch(circleTripsProvider(widget.circleId));
    final membersAsync = ref.watch(circleMembersProvider(widget.circleId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return circleAsync.when(
      data: (circle) {
        return Scaffold(
          backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  backgroundColor: isDark ? AppPallete.surfaceDark : Colors.white,
                  title: innerBoxIsScrolled
                      ? Text(
                          circle.name,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppPallete.navy,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                        tooltip: 'Shopping Lists',
                        onPressed: () => context.push('/circle/${widget.circleId}/shopping-lists'),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
                        tooltip: 'Settings',
                        onPressed: () => context.push('/circle/${widget.circleId}/settings'),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Cover photo
                        Image.network(
                          circle.imageUrl != null && circle.imageUrl!.isNotEmpty
                              ? circle.imageUrl!
                              : 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF312E81), Color(0xFF4F46E5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.65),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Circle Info & Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      children: [
                        // Circle Avatar (Not translated negatively to prevent clipping/cut-off)
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppPallete.indigo,
                            border: Border.all(
                              color: isDark ? AppPallete.surfaceDark : Colors.white,
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: circle.imageUrl != null && circle.imageUrl!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    circle.imageUrl!,
                                    width: 76,
                                    height: 76,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Text(
                                      circle.name.isNotEmpty ? circle.name[0].toUpperCase() : 'C',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  circle.name.isNotEmpty ? circle.name[0].toUpperCase() : 'C',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          circle.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : AppPallete.navy,
                          ),
                        ),
                        if (circle.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            circle.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${circle.memberIds.length} members',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppPallete.gray,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quick Actions Row (Invite, Shopping, Announcement, Settings)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildQuickButton(
                                icon: Icons.person_add_rounded,
                                label: 'Invite',
                                isDark: isDark,
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: circle.code));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Invite code "${circle.code}" copied!'),
                                      backgroundColor: AppPallete.primary,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                              _buildQuickButton(
                                icon: Icons.shopping_cart_outlined,
                                label: 'Shopping',
                                isDark: isDark,
                                onTap: () => context.push('/circle/${widget.circleId}/shopping-lists'),
                              ),
                              const SizedBox(width: 10),
                              _buildQuickButton(
                                icon: Icons.campaign_rounded,
                                label: 'Announcement',
                                isDark: isDark,
                                onTap: () => _showAnnouncementDialog(context, circle),
                              ),
                              const SizedBox(width: 10),
                              _buildQuickButton(
                                icon: Icons.settings_rounded,
                                label: 'Settings',
                                isDark: isDark,
                                onTap: () => context.push('/circle/${widget.circleId}/settings'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Pinned Tab Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppPallete.primary,
                      indicatorWeight: 3,
                      labelColor: AppPallete.primary,
                      unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      tabs: const [
                        Tab(text: 'Trips'),
                        Tab(text: 'Members'),
                        Tab(text: 'Activity'),
                      ],
                    ),
                    isDark: isDark,
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: TRIPS
                _buildTripsTab(context, tripsAsync, isDark),

                // TAB 2: MEMBERS
                _buildMembersTab(context, circle, membersAsync, tripsAsync, isDark),

                // TAB 3: ACTIVITY
                _buildActivityTab(context, tripsAsync, isDark),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: PrimaryButton(
              label: '+ New Trip',
              icon: Icons.add_rounded,
              onPressed: () => context.push('/circle/${widget.circleId}/create-trip'),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildQuickButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppPallete.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: AppPallete.indigo),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppPallete.navy,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripsTab(BuildContext context, AsyncValue<List<TripModel>> tripsAsync, bool isDark) {
    return tripsAsync.when(
      data: (trips) {
        if (trips.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.flight_takeoff_rounded,
            title: 'No Trips Yet',
            description: 'Start planning your first group adventure in this Circle.',
            actionLabel: 'Create a Trip',
            onAction: () => context.push('/circle/${widget.circleId}/create-trip'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            String dateRange = 'Dates pending';
            if (trip.startDate != null) {
              final startFmt = DateFormat('d MMM').format(trip.startDate!);
              final endFmt = trip.endDate != null ? DateFormat('d MMM').format(trip.endDate!) : '';
              dateRange = endFmt.isNotEmpty ? '$startFmt - $endFmt' : startFmt;
            }
            final memberCount = trip.participantIds.isNotEmpty ? trip.participantIds.length : 6;
            final subtitle = '$dateRange • $memberCount members';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppPallete.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(18),
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
                    onTap: () => context.push('/trip/${trip.id}'),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=300&q=80',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : AppPallete.navy,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge.fromTripStatus(trip.status.isNotEmpty ? trip.status : 'Planning'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading trips: $err')),
    );
  }

  Widget _buildMembersTab(
      BuildContext context,
      CircleModel circle,
      AsyncValue<List<UserModel>> membersAsync,
      AsyncValue<List<TripModel>> tripsAsync,
      bool isDark) {
    final trips = tripsAsync.asData?.value ?? [];

    return membersAsync.when(
      data: (members) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            // 1. Action Header: Count + Add/Invite Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Circle Members (${members.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppPallete.navy,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () => _showAddMemberOrGuestSheet(context, circle, trips),
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text('Add / Invite', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Guest Participants Info Card (For users looking for Guest option)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF132F38), const Color(0xFF0F172A)]
                      : [const Color(0xFFF0FDFA), const Color(0xFFE6FFFA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppPallete.teal.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppPallete.teal.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.group_add_rounded, color: AppPallete.teal, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Adding Guests without an Account?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppPallete.navy,
                        ),
                      ),
                      const Spacer(),
                      StatusBadge.warning(label: 'Guest Mode'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Guest participants can be added to your Trips without needing an app, phone number, or account. They are fully included in bill splitting, balances, and final settlements!',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppPallete.teal,
                        side: const BorderSide(color: AppPallete.teal),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () => _showTripSelectionForGuest(context, trips),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                      label: const Text('+ Add Guest to Trip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Circle Registered Members List
            ...members.map((member) {
              final isAdmin = circle.adminIds.contains(member.uid);
              final isOwner = circle.createdBy == member.uid;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppPallete.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: member.photoUrl != null && member.photoUrl!.isNotEmpty
                          ? NetworkImage(member.photoUrl!)
                          : null,
                      backgroundColor: AppPallete.indigo.withValues(alpha: 0.15),
                      child: member.photoUrl == null || member.photoUrl!.isEmpty
                          ? Text(
                              member.displayName.isNotEmpty ? member.displayName[0].toUpperCase() : 'U',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppPallete.indigo),
                            )
                          : null,
                    ),
                    title: Text(
                      member.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppPallete.navy,
                      ),
                    ),
                    subtitle: Text(
                      member.email,
                      style: const TextStyle(fontSize: 12, color: AppPallete.gray),
                    ),
                    trailing: isOwner
                        ? StatusBadge.primary(label: 'Owner')
                        : (isAdmin ? StatusBadge.warning(label: 'Admin') : StatusBadge.neutral(label: 'Member')),
                  ),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading members: $err')),
    );
  }

  void _showAddMemberOrGuestSheet(BuildContext context, CircleModel circle, List<TripModel> trips) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppPallete.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add or Invite Members',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Invite app users to this Circle, or add Guests directly to a Trip for expense splitting.',
                style: TextStyle(fontSize: 12, color: AppPallete.gray),
              ),
              const SizedBox(height: 20),

              // Option A: Invite registered member to Circle
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppPallete.indigo.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_rounded, color: AppPallete.indigo, size: 22),
                ),
                title: const Text('Invite Registered Member to Circle',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Text('Share Circle Code: ${circle.code}',
                    style: const TextStyle(fontSize: 12, color: AppPallete.gray)),
                trailing: const Icon(Icons.copy_rounded, size: 18, color: AppPallete.indigo),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  Clipboard.setData(ClipboardData(text: circle.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Circle code "${circle.code}" copied to clipboard!'),
                      backgroundColor: AppPallete.primary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Option B: Add Guest Participant to Trip
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppPallete.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_add_alt_1_rounded, color: AppPallete.teal, size: 22),
                ),
                title: Row(
                  children: [
                    const Text('Add Guest Participant to Trip',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(width: 6),
                    StatusBadge.warning(label: 'Guest'),
                  ],
                ),
                subtitle: const Text(
                  'For friends without an account (split expenses & settle)',
                  style: TextStyle(fontSize: 12, color: AppPallete.gray),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, size: 22, color: AppPallete.gray),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showTripSelectionForGuest(context, trips);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTripSelectionForGuest(BuildContext context, List<TripModel> trips) {
    if (trips.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('No Active Trips Yet'),
          content: const Text(
            'Guest participants are added to specific trips so they can participate in expense splitting and final settlements.\n\nCreate a trip first, then you can add guest members anytime!',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/circle/${widget.circleId}/create-trip');
              },
              child: const Text('Create Trip'),
            ),
          ],
        ),
      );
      return;
    }

    if (trips.length == 1) {
      AddParticipantSheet.show(context, tripId: trips.first.id);
      return;
    }

    // Pick which trip to add the guest into
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppPallete.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Trip to Add Guest',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose which trip this guest participant should be added to:',
                style: TextStyle(fontSize: 12, color: AppPallete.gray),
              ),
              const SizedBox(height: 16),
              ...trips.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: const Icon(Icons.flight_takeoff_rounded, color: AppPallete.indigo),
                    title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(
                      (t.location != null && t.location!.isNotEmpty) ? t.location! : 'Trip in Circle',
                      style: const TextStyle(fontSize: 11, color: AppPallete.gray),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppPallete.gray),
                    onTap: () {
                      Navigator.pop(ctx);
                      AddParticipantSheet.show(context, tripId: t.id);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTab(BuildContext context, AsyncValue<List<TripModel>> tripsAsync, bool isDark) {
    return tripsAsync.when(
      data: (trips) {
        if (trips.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.notifications_none_rounded,
            title: 'No Circle Activity Yet',
            description: 'When trips are created, itineraries updated, or expenses logged, you will see updates here.',
          );
        }

        final activities = trips.map((t) {
          final timeStr = DateFormat('d MMM yyyy').format(t.createdAt);
          return {
            'title': 'Trip "${t.name}" planned for ${t.location?.isNotEmpty == true ? t.location! : "group adventure"}',
            'time': timeStr,
            'icon': Icons.flight_takeoff_rounded,
            'tripId': t.id,
          };
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final act = activities[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppPallete.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    final tripId = act['tripId'] as String?;
                    if (tripId != null) {
                      context.push('/trip/$tripId');
                    }
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppPallete.indigo.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(act['icon'] as IconData, color: AppPallete.indigo, size: 20),
                  ),
                  title: Text(
                    act['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : AppPallete.navy,
                    ),
                  ),
                  subtitle: Text(
                    act['time'] as String,
                    style: const TextStyle(fontSize: 12, color: AppPallete.gray),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppPallete.gray),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Unable to load activities')),
    );
  }

  void _showAnnouncementDialog(BuildContext context, CircleModel circle) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Post Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Share an update with everyone in the circle...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Announcement posted to circle!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;

  _SliverTabBarDelegate(this.tabBar, {required this.isDark});

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppPallete.backgroundDark : AppPallete.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
