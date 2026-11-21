import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../financial/presentation/widgets/settlement_dialogs.dart';
import '../trip_participant_controller.dart';
import 'add_participant_sheet.dart';
import 'convert_guest_dialog.dart';
import 'participant_detail_screen.dart';

class TripMembersTab extends ConsumerStatefulWidget {
  final String tripId;

  const TripMembersTab({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<TripMembersTab> createState() => _TripMembersTabState();
}

class _TripMembersTabState extends ConsumerState<TripMembersTab> {
  String _selectedFilter = 'all'; // 'all', 'registered', 'guest'
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final participantsAsync = ref.watch(tripParticipantsProvider(widget.tripId));
    final balancesAsync = ref.watch(tripParticipantBalancesProvider(widget.tripId));

    return Scaffold(
      backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
      body: participantsAsync.when(
        data: (participants) {
          final registeredCount = participants.where((p) => p.isRegistered).length;
          final guestCount = participants.where((p) => p.isGuest).length;

          // Apply filter
          var filteredList = participants.where((p) {
            if (_selectedFilter == 'registered') return p.isRegistered;
            if (_selectedFilter == 'guest') return p.isGuest;
            return true;
          }).toList();

          // Apply search
          if (_searchQuery.trim().isNotEmpty) {
            final query = _searchQuery.toLowerCase().trim();
            filteredList = filteredList.where((p) {
              final nameMatch = p.name.toLowerCase().contains(query);
              final emailMatch = p.email?.toLowerCase().contains(query) ?? false;
              final phoneMatch = p.phoneNumber?.contains(query) ?? false;
              return nameMatch || emailMatch || phoneMatch;
            }).toList();
          }

          return Column(
            children: [
              // 1. Search Bar & Add Button Header
              Container(
                color: isDark ? AppPallete.surfaceDark : Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search members & guests...',
                          hintStyle: const TextStyle(fontSize: 13, color: AppPallete.gray),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppPallete.gray),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => AddParticipantSheet.show(context, tripId: widget.tripId),
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),

              // 2. Segment Filters (All, Registered, Guests)
              Container(
                width: double.infinity,
                color: isDark ? AppPallete.surfaceDark : Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        id: 'all',
                        label: 'All Participants (${participants.length})',
                        icon: Icons.people_alt_outlined,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        id: 'registered',
                        label: 'Registered ($registeredCount)',
                        icon: Icons.verified_outlined,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        id: 'guest',
                        label: 'Guests ($guestCount)',
                        icon: Icons.person_outline_rounded,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

              // 3. Participants List
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppPallete.indigo.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.people_outline_rounded, size: 28, color: AppPallete.indigo),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No matches for "$_searchQuery"'
                                    : 'No participants in this filter',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Tap "+ Add" to add guests or circle members to the trip.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppPallete.gray, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final participant = filteredList[index];

                          return balancesAsync.when(
                            data: (balances) {
                              final balance = balances[participant.id];
                              final paid = balance?.totalPaid ?? 0.0;
                              final share = balance?.totalShare ?? 0.0;
                              final net = balance?.netBalance ?? 0.0;
                              final isSettled = balance?.isSettled ?? true;
                              final owes = balance?.owes ?? false;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppPallete.surfaceDark : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                  boxShadow: AppPallete.cardShadow,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () => ParticipantDetailScreen.show(
                                      context,
                                      tripId: widget.tripId,
                                      participant: participant,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              // Avatar with Badge
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: 46,
                                                    height: 46,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: LinearGradient(
                                                        colors: participant.isGuest
                                                            ? [const Color(0xFF14BBA6), const Color(0xFF0D9488)]
                                                            : [AppPallete.indigo, const Color(0xFF7C3AED)],
                                                      ),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      participant.initials,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 17,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: Container(
                                                      padding: const EdgeInsets.all(2),
                                                      decoration: BoxDecoration(
                                                        color: participant.isGuest
                                                            ? AppPallete.teal
                                                            : AppPallete.indigo,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(color: Colors.white, width: 1),
                                                      ),
                                                      child: Icon(
                                                        participant.isGuest
                                                            ? Icons.person_outline_rounded
                                                            : Icons.check,
                                                        size: 9,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 12),

                                              // Name & Subtitle
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            participant.name,
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.w800,
                                                              fontSize: 15,
                                                              letterSpacing: -0.2,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: participant.isGuest
                                                                ? AppPallete.teal.withValues(alpha: 0.12)
                                                                : AppPallete.indigo.withValues(alpha: 0.12),
                                                            borderRadius: BorderRadius.circular(8),
                                                            border: Border.all(
                                                              color: participant.isGuest
                                                                  ? AppPallete.teal.withValues(alpha: 0.3)
                                                                  : AppPallete.indigo.withValues(alpha: 0.3),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            participant.isGuest ? 'Guest' : 'Member',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.w800,
                                                              color: participant.isGuest
                                                                  ? AppPallete.teal
                                                                  : AppPallete.indigo,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      participant.isGuest
                                                          ? 'Guest added by organizer'
                                                          : (participant.email ?? 'Registered CoCircle account'),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Context menu
                                              PopupMenuButton<String>(
                                                icon: const Icon(Icons.more_vert_rounded, size: 20),
                                                onSelected: (val) {
                                                  if (val == 'details') {
                                                    ParticipantDetailScreen.show(
                                                      context,
                                                      tripId: widget.tripId,
                                                      participant: participant,
                                                    );
                                                  } else if (val == 'payment') {
                                                    RecordPaymentSheet.show(
                                                      context,
                                                      memberNames: [participant.name],
                                                      onRecord: (_) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text('Payment recorded! 🤝')),
                                                        );
                                                      },
                                                    );
                                                  } else if (val == 'convert') {
                                                    ConvertGuestDialog.show(
                                                      context,
                                                      tripId: widget.tripId,
                                                      guest: participant,
                                                    );
                                                  }
                                                },
                                                itemBuilder: (ctx) => [
                                                  const PopupMenuItem(
                                                    value: 'details',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.info_outline_rounded, size: 18),
                                                        SizedBox(width: 8),
                                                        Text('View Dossier'),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'payment',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.payment_rounded, size: 18, color: AppPallete.indigo),
                                                        SizedBox(width: 8),
                                                        Text('Record Payment'),
                                                      ],
                                                    ),
                                                  ),
                                                  if (participant.isGuest)
                                                    const PopupMenuItem(
                                                      value: 'convert',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.link_rounded, size: 18, color: Color(0xFF10B981)),
                                                          SizedBox(width: 8),
                                                          Text('Link to Account'),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Financial Micro-Bar
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                _buildFinanceMiniStat('Paid', '₹${paid.toStringAsFixed(0)}', AppPallete.navy, isDark),
                                                Container(width: 1, height: 20, color: const Color(0xFFE2E8F0)),
                                                _buildFinanceMiniStat('Share', '₹${share.toStringAsFixed(0)}', AppPallete.gray, isDark),
                                                Container(width: 1, height: 20, color: const Color(0xFFE2E8F0)),
                                                _buildFinanceMiniStat(
                                                  'Balance',
                                                  isSettled
                                                      ? 'Settled'
                                                      : (owes ? 'Owes ₹${(-net).toStringAsFixed(0)}' : '+₹${net.toStringAsFixed(0)}'),
                                                  isSettled
                                                      ? const Color(0xFF10B981)
                                                      : (owes ? AppPallete.coral : const Color(0xFF059669)),
                                                  isDark,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            loading: () => const LinearProgressIndicator(),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading participants: $e')),
      ),
    );
  }

  Widget _buildFilterChip({
    required String id,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedFilter == id;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
            ),
          ),
        ],
      ),
      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      selectedColor: AppPallete.indigo,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppPallete.indigo : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      onSelected: (val) {
        setState(() => _selectedFilter = id);
      },
    );
  }

  Widget _buildFinanceMiniStat(String label, String value, Color valueColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppPallete.gray),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark && valueColor == AppPallete.navy ? Colors.white : valueColor,
          ),
        ),
      ],
    );
  }
}
