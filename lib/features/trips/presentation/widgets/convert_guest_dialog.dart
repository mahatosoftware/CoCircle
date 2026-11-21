import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../circles/presentation/circle_controller.dart';
import '../trip_controller.dart';
import '../trip_participant_controller.dart';
import '../../domain/trip_participant_model.dart';

class ConvertGuestDialog extends ConsumerStatefulWidget {
  final String tripId;
  final TripParticipantModel guest;

  const ConvertGuestDialog({
    super.key,
    required this.tripId,
    required this.guest,
  });

  static Future<void> show(
    BuildContext context, {
    required String tripId,
    required TripParticipantModel guest,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ConvertGuestDialog(tripId: tripId, guest: guest),
    );
  }

  @override
  ConsumerState<ConvertGuestDialog> createState() => _ConvertGuestDialogState();
}

class _ConvertGuestDialogState extends ConsumerState<ConvertGuestDialog> {
  String? _selectedUserId;
  String? _selectedDisplayName;
  final _manualUidController = TextEditingController();
  final _manualNameController = TextEditingController();
  bool _useManual = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _manualUidController.dispose();
    _manualNameController.dispose();
    super.dispose();
  }

  Future<void> _handleConvert() async {
    final userId = _useManual
        ? _manualUidController.text.trim()
        : _selectedUserId;
    final displayName = _useManual
        ? _manualNameController.text.trim()
        : (_selectedDisplayName ?? widget.guest.name);

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or specify a registered account')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await ref
        .read(tripParticipantControllerProvider.notifier)
        .convertGuestToRegistered(
          tripId: widget.tripId,
          participantId: widget.guest.id,
          registeredUserId: userId,
          registeredDisplayName: displayName,
          context: context,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppPallete.surfaceDark : Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppPallete.indigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.link_rounded, color: AppPallete.indigo, size: 22),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Link Guest Account',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Link "${widget.guest.name}" with their newly registered CoCircle account.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 12),

            // Safety Guarantee Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5).withValues(alpha: isDark ? 0.2 : 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: Color(0xFF059669), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All historical expenses, paid amounts, splits, and settlements are strictly preserved under their ID.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (!_useManual) ...[
              const Text(
                'Select Registered Member from Circle:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const SizedBox(height: 8),
              tripAsync.when(
                data: (trip) {
                  final circleMembersAsync = ref.watch(circleMembersProvider(trip.circleId));
                  final participantsAsync = ref.watch(tripParticipantsProvider(widget.tripId));

                  return circleMembersAsync.when(
                    data: (circleMembers) {
                      final registeredUidsInTrip = participantsAsync.asData?.value
                              .where((p) => p.isRegistered && p.userId != null)
                              .map((p) => p.userId!)
                              .toSet() ??
                          {};

                      final eligibleMembers = circleMembers
                          .where((m) => !registeredUidsInTrip.contains(m.uid))
                          .toList();

                      if (eligibleMembers.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'No unclaimed circle members found. Use manual UID linking below.',
                            style: TextStyle(fontSize: 12, color: AppPallete.gray),
                          ),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        value: _selectedUserId,
                        decoration: InputDecoration(
                          hintText: 'Choose circle member',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: eligibleMembers.map((m) {
                          return DropdownMenuItem<String>(
                            value: m.uid,
                            child: Text(
                              '${m.displayName} (${m.email})',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedUserId = val;
                            final m = eligibleMembers.firstWhere((e) => e.uid == val);
                            _selectedDisplayName = m.displayName;
                          });
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _useManual = true),
                  child: const Text('Enter UID manually instead', style: TextStyle(fontSize: 12)),
                ),
              ),
            ] else ...[
              const Text(
                'Registered Account Details:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _manualNameController,
                decoration: InputDecoration(
                  labelText: 'Account Display Name',
                  hintText: widget.guest.name,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _manualUidController,
                decoration: InputDecoration(
                  labelText: 'Firebase Auth UID',
                  hintText: 'e.g. u4Xk9LpQ...',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _useManual = false),
                  child: const Text('Select from circle members', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallete.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isSubmitting ? null : _handleConvert,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Confirm Link', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
