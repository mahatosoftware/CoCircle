import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../circles/presentation/circle_controller.dart';
import '../trip_controller.dart';
import '../trip_participant_controller.dart';
import '../../domain/trip_participant_model.dart';

class AddParticipantSheet extends ConsumerStatefulWidget {
  final String tripId;
  final VoidCallback? onParticipantAdded;
  final ValueChanged<TripParticipantModel>? onLocalParticipantCreated;

  const AddParticipantSheet({
    super.key,
    required this.tripId,
    this.onParticipantAdded,
    this.onLocalParticipantCreated,
  });

  static Future<void> show(
    BuildContext context, {
    required String tripId,
    VoidCallback? onParticipantAdded,
    ValueChanged<TripParticipantModel>? onLocalParticipantCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddParticipantSheet(
          tripId: tripId,
          onParticipantAdded: onParticipantAdded,
          onLocalParticipantCreated: onLocalParticipantCreated,
        ),
      ),
    );
  }

  @override
  ConsumerState<AddParticipantSheet> createState() => _AddParticipantSheetState();
}

class _AddParticipantSheetState extends ConsumerState<AddParticipantSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _guestFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitGuest() async {
    if (!_guestFormKey.currentState!.validate()) return;

    if (widget.onLocalParticipantCreated != null) {
      final guest = TripParticipantModel(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        tripId: widget.tripId,
        name: _nameController.text.trim(),
        participantType: TripParticipantType.guest,
        phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        addedBy: 'organizer',
        createdAt: DateTime.now(),
        status: 'active',
      );
      widget.onLocalParticipantCreated!(guest);
      Navigator.pop(context);
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await ref
        .read(tripParticipantControllerProvider.notifier)
        .addGuestParticipant(
          tripId: widget.tripId,
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          notes: _notesController.text.trim(),
          context: context,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        widget.onParticipantAdded?.call();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Trip Participant',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: isDark ? Colors.white : AppPallete.navy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Add registered members or guests without an account',
                        style: TextStyle(fontSize: 12, color: AppPallete.gray),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppPallete.indigo,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_alt_1_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Add Guest'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_outlined, size: 16),
                      SizedBox(width: 6),
                      Text('From Circle'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAddGuestTab(isDark),
                _buildFromCircleTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddGuestTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Form(
        key: _guestFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informational callout
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppPallete.teal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppPallete.teal.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppPallete.teal, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Guests don\'t need the app or an account. They can be split in expenses and settled up by you.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF99F6E4) : const Color(0xFF0F766E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Required Name
            Text(
              'Full Name *',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? Colors.white : AppPallete.navy,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'e.g. Amit Kumar',
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter the participant\'s name';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Optional Phone
            Text(
              'Phone Number (Optional)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'e.g. +91 98765 43210',
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // Optional Email
            Text(
              'Email Address (Optional)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'e.g. amit@example.com',
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // Optional Notes
            Text(
              'Notes (Optional)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. Rahul\'s friend joining for weekend',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Icon(Icons.notes_rounded, size: 20),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            PrimaryButton(
              label: 'Add Guest Participant',
              icon: Icons.person_add_rounded,
              isLoading: _isSubmitting,
              onPressed: _submitGuest,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFromCircleTab(bool isDark) {
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));

    return tripAsync.when(
      data: (trip) {
        final circleMembersAsync = ref.watch(circleMembersProvider(trip.circleId));
        final existingParticipantsAsync = ref.watch(tripParticipantsProvider(widget.tripId));

        return circleMembersAsync.when(
          data: (circleMembers) {
            final existingIds = existingParticipantsAsync.asData?.value
                    .map((p) => p.userId ?? p.id)
                    .toSet() ??
                {};

            final availableMembers = circleMembers
                .where((m) => !existingIds.contains(m.uid))
                .toList();

            if (availableMembers.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 48, color: AppPallete.teal),
                    const SizedBox(height: 12),
                    const Text(
                      'All Circle Members Added',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Every member of this circle is already in this trip. You can add external guests in the Add Guest tab.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppPallete.gray),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: availableMembers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final member = availableMembers[index];
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppPallete.indigo.withValues(alpha: 0.1),
                      child: Text(
                        member.displayName.isNotEmpty
                            ? member.displayName[0].toUpperCase()
                            : 'M',
                        style: const TextStyle(
                          color: AppPallete.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      member.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: Text(
                      member.email,
                      style: const TextStyle(fontSize: 11, color: AppPallete.gray),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final success = await ref
                            .read(tripParticipantControllerProvider.notifier)
                            .addCircleMemberToTrip(
                              tripId: widget.tripId,
                              userId: member.uid,
                              displayName: member.displayName,
                              photoUrl: member.photoUrl,
                              context: context,
                            );
                        if (success && mounted) {
                          widget.onParticipantAdded?.call();
                        }
                      },
                      child: const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading circle members: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
