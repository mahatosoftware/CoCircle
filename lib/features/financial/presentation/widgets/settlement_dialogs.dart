import 'package:flutter/material.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../trips/domain/trip_participant_model.dart';

class RecordPaymentSheet extends StatefulWidget {
  final List<String> memberNames;
  final List<TripParticipantModel>? participants;
  final ValueChanged<Map<String, dynamic>> onRecord;

  const RecordPaymentSheet({
    super.key,
    required this.memberNames,
    this.participants,
    required this.onRecord,
  });

  static Future<void> show(
    BuildContext context, {
    required List<String> memberNames,
    List<TripParticipantModel>? participants,
    required ValueChanged<Map<String, dynamic>> onRecord,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: RecordPaymentSheet(
          memberNames: memberNames,
          participants: participants,
          onRecord: onRecord,
        ),
      ),
    );
  }

  @override
  State<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends State<RecordPaymentSheet> {
  late String _fromId;
  late String _toId;
  final _amountController = TextEditingController(text: '1250');
  final _refController = TextEditingController(text: 'UPI Ref: 4127849302');
  final _notesController = TextEditingController();
  String _method = 'UPI';
  bool _isConfirmed = true;

  @override
  void initState() {
    super.initState();
    if (widget.participants != null && widget.participants!.isNotEmpty) {
      _fromId = widget.participants!.length > 1 ? widget.participants![1].id : widget.participants!.first.id;
      _toId = widget.participants!.first.id;
    } else {
      _fromId = widget.memberNames.length > 1 ? widget.memberNames[1] : (widget.memberNames.isNotEmpty ? widget.memberNames.first : '');
      _toId = widget.memberNames.isNotEmpty ? widget.memberNames.first : '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  TripParticipantModel? _findParticipant(String id) {
    if (widget.participants == null) return null;
    return widget.participants!.cast<TripParticipantModel?>().firstWhere(
          (p) => p?.id == id || p?.name == id,
          orElse: () => null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasParticipants = widget.participants != null && widget.participants!.isNotEmpty;
    final fromParticipant = _findParticipant(_fromId);
    final toParticipant = _findParticipant(_toId);
    final isGuestInvolved = (fromParticipant?.isGuest == true) || (toParticipant?.isGuest == true);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Record Payment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : AppPallete.navy,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (isGuestInvolved)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFFB45309), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Recording on behalf of guest: ${fromParticipant?.isGuest == true ? fromParticipant!.name : toParticipant!.name}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),

            // From Member
            Text('From (Payer)', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppPallete.navy)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? AppPallete.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _fromId,
                  isExpanded: true,
                  items: hasParticipants
                      ? widget.participants!.map((p) {
                          return DropdownMenuItem<String>(
                            value: p.id,
                            child: Row(
                              children: [
                                Text(p.name),
                                if (p.isGuest) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Guest', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList()
                      : widget.memberNames.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _fromId = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // To Member
            Text('To (Recipient)', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppPallete.navy)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? AppPallete.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _toId,
                  isExpanded: true,
                  items: hasParticipants
                      ? widget.participants!.map((p) {
                          return DropdownMenuItem<String>(
                            value: p.id,
                            child: Row(
                              children: [
                                Text(p.name),
                                if (p.isGuest) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Guest', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList()
                      : widget.memberNames.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _toId = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Amount
            Text('Amount', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppPallete.navy)),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                filled: true,
                fillColor: isDark ? AppPallete.surfaceDark : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Method
            Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppPallete.navy)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? AppPallete.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _method,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'UPI', child: Text('UPI (GPay / PhonePe / Paytm)')),
                    DropdownMenuItem(value: 'Cash', child: Text('Cash in Hand')),
                    DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer / NEFT')),
                    DropdownMenuItem(value: 'Other', child: Text('Other / Manual Settlement')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _method = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Reference (optional)
            Text('Reference / Transaction ID (optional)', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppPallete.navy)),
            const SizedBox(height: 6),
            TextField(
              controller: _refController,
              decoration: InputDecoration(
                hintText: 'e.g. UPI Ref: 4127849302',
                filled: true,
                fillColor: isDark ? AppPallete.surfaceDark : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Notes
            Text('Notes (optional)', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppPallete.navy)),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'e.g. Settled for day 2 dinner & stay',
                filled: true,
                fillColor: isDark ? AppPallete.surfaceDark : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Verification toggle
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Verified manual confirmation',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Confirms the amount was received before updating the financial ledger',
                style: TextStyle(fontSize: 11, color: AppPallete.gray),
              ),
              value: _isConfirmed,
              activeColor: AppPallete.indigo,
              onChanged: (val) => setState(() => _isConfirmed = val ?? false),
            ),
            const SizedBox(height: 16),

            PrimaryButton(
              label: 'Record Payment',
              onPressed: _isConfirmed
                  ? () {
                      final amt = double.tryParse(_amountController.text) ?? 1250.0;
                      Navigator.pop(context);
                      widget.onRecord({
                        'from': _fromId,
                        'to': _toId,
                        'fromName': fromParticipant?.name ?? _fromId,
                        'toName': toParticipant?.name ?? _toId,
                        'amount': amt,
                        'method': _method,
                        'reference': _refController.text.trim(),
                        'notes': _notesController.text.trim(),
                        'onBehalfOfGuest': isGuestInvolved,
                      });
                    }
                  : null,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

class CloseTripSheet extends StatelessWidget {
  final VoidCallback onConfirmClose;

  const CloseTripSheet({super.key, required this.onConfirmClose});

  static Future<void> show(BuildContext context, {required VoidCallback onConfirmClose}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CloseTripSheet(onConfirmClose: onConfirmClose),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final checklist = [
      'Trip activities completed',
      'All expenses reviewed',
      'All payments recorded',
      'Write-offs (if any) approved',
      'No pending balances',
      'Final report generated',
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Close Trip',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : AppPallete.navy,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Verify all trip requirements are satisfied before archiving this trip workspace.',
              style: TextStyle(fontSize: 13, color: AppPallete.gray),
            ),
            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppPallete.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: checklist.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD1FAE5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Color(0xFF065F46),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppPallete.navy,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              label: 'Close Trip',
              backgroundColor: const Color(0xFF059669),
              onPressed: () {
                Navigator.pop(context);
                onConfirmClose();
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
