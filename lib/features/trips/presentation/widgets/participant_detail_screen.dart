import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../financial/expenses/presentation/expense_controller.dart';
import '../../../financial/presentation/widgets/settlement_dialogs.dart';
import '../../../reports/presentation/expense_report_config_screen.dart';
import '../trip_participant_controller.dart';
import '../../domain/trip_participant_model.dart';
import 'convert_guest_dialog.dart';

class ParticipantDetailScreen extends ConsumerStatefulWidget {
  final String tripId;
  final TripParticipantModel participant;
  final String currency;

  const ParticipantDetailScreen({
    super.key,
    required this.tripId,
    required this.participant,
    this.currency = '₹',
  });

  static Future<void> show(
    BuildContext context, {
    required String tripId,
    required TripParticipantModel participant,
    String currency = '₹',
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ParticipantDetailScreen(
          tripId: tripId,
          participant: participant,
          currency: currency,
        ),
      ),
    );
  }

  @override
  ConsumerState<ParticipantDetailScreen> createState() => _ParticipantDetailScreenState();
}

class _ParticipantDetailScreenState extends ConsumerState<ParticipantDetailScreen> {
  late TripParticipantModel _participant;

  @override
  void initState() {
    super.initState();
    _participant = widget.participant;
  }

  void _showEditGuestDialog(BuildContext context) {
    final nameController = TextEditingController(text: _participant.name);
    final phoneController = TextEditingController(text: _participant.phoneNumber ?? '');
    final emailController = TextEditingController(text: _participant.email ?? '');
    final notesController = TextEditingController(text: _participant.notes ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Guest Details', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number (Optional)'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email (Optional)'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final updated = _participant.copyWith(
                  name: name,
                  phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                  email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                );
                final success = await ref
                    .read(tripParticipantControllerProvider.notifier)
                    .updateParticipant(participant: updated, context: context);
                if (success && mounted) {
                  setState(() => _participant = updated);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _handleRemove(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Participant?'),
        content: Text(
          'Are you sure you want to remove "${_participant.name}" from this trip?\n\n'
          'Participants with linked expenses, payments, or non-zero balances cannot be removed to preserve financial integrity.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppPallete.coral),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ref
          .read(tripParticipantControllerProvider.notifier)
          .removeParticipant(
            tripId: widget.tripId,
            participantId: _participant.id,
            participantName: _participant.name,
            context: context,
          );
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final balancesAsync = ref.watch(tripParticipantBalancesProvider(widget.tripId));
    final expensesAsync = ref.watch(tripExpensesProvider(widget.tripId));
    final paymentsAsync = ref.watch(tripPaymentsProvider(widget.tripId));

    return Scaffold(
      backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
      appBar: AppBar(
        title: Text(
          _participant.name,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? Colors.white : AppPallete.navy,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export Individual Statement',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExpenseReportConfigScreen(
                    tripId: widget.tripId,
                    initialParticipantId: _participant.id,
                  ),
                ),
              );
            },
          ),
          if (_participant.isGuest)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Guest Details',
              onPressed: () => _showEditGuestDialog(context),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == 'export') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExpenseReportConfigScreen(
                      tripId: widget.tripId,
                      initialParticipantId: _participant.id,
                    ),
                  ),
                );
              } else if (val == 'convert') {
                ConvertGuestDialog.show(context, tripId: widget.tripId, guest: _participant);
              } else if (val == 'remove') {
                _handleRemove(context);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.description_rounded, size: 18, color: AppPallete.indigo),
                    SizedBox(width: 8),
                    Text('Export Individual Statement'),
                  ],
                ),
              ),
              if (_participant.isGuest)
                const PopupMenuItem(
                  value: 'convert',
                  child: Row(
                    children: [
                      Icon(Icons.link_rounded, size: 18, color: AppPallete.indigo),
                      SizedBox(width: 8),
                      Text('Link to Registered Account'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove_rounded, size: 18, color: AppPallete.coral),
                    SizedBox(width: 8),
                    Text('Remove from Trip', style: TextStyle(color: AppPallete.coral)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Participant Profile Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppPallete.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
                boxShadow: AppPallete.cardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar with badge
                      Stack(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _participant.isGuest
                                    ? [const Color(0xFF14BBA6), const Color(0xFF0D9488)]
                                    : [AppPallete.indigo, const Color(0xFF7C3AED)],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _participant.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: _participant.isGuest ? AppPallete.teal : AppPallete.indigo,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: Icon(
                                _participant.isGuest ? Icons.person_outline_rounded : Icons.verified_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _participant.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      color: isDark ? Colors.white : AppPallete.navy,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _participant.isGuest
                                        ? AppPallete.teal.withValues(alpha: 0.12)
                                        : AppPallete.indigo.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _participant.isGuest
                                          ? AppPallete.teal.withValues(alpha: 0.3)
                                          : AppPallete.indigo.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    _participant.isGuest ? 'Guest' : 'Registered',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: _participant.isGuest ? AppPallete.teal : AppPallete.indigo,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (_participant.email != null)
                              Text(
                                _participant.email!,
                                style: const TextStyle(fontSize: 12, color: AppPallete.gray),
                              ),
                            if (_participant.phoneNumber != null)
                              Text(
                                _participant.phoneNumber!,
                                style: const TextStyle(fontSize: 12, color: AppPallete.gray),
                              ),
                            if (_participant.notes != null && _participant.notes!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '"${_participant.notes}"',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_participant.convertedAt != null) ...[
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.link_rounded, size: 16, color: Color(0xFF10B981)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Linked to CoCircle account on ${DateFormat('d MMM yyyy').format(_participant.convertedAt!)}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Financial Dossier Cards
            balancesAsync.when(
              data: (balances) {
                final balance = balances[_participant.id];
                final paid = balance?.totalPaid ?? 0.0;
                final share = balance?.totalShare ?? 0.0;
                final net = balance?.netBalance ?? 0.0;
                final isSettled = balance?.isSettled ?? true;
                final owes = balance?.owes ?? false;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Snapshot',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppPallete.navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            title: 'Amount Paid',
                            amount: '${widget.currency} ${paid.toStringAsFixed(0)}',
                            color: AppPallete.indigo,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricTile(
                            title: 'Expense Share',
                            amount: '${widget.currency} ${share.toStringAsFixed(0)}',
                            color: const Color(0xFF64748B),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: owes
                            ? const Color(0xFFFEE2E2).withValues(alpha: isDark ? 0.2 : 0.7)
                            : (net > 0
                                ? const Color(0xFFD1FAE5).withValues(alpha: isDark ? 0.2 : 0.7)
                                : (isDark ? AppPallete.surfaceDark : Colors.white)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: owes
                              ? AppPallete.coral.withValues(alpha: 0.4)
                              : (net > 0 ? const Color(0xFF10B981).withValues(alpha: 0.4) : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Net Balance',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: owes
                                      ? AppPallete.coral
                                      : (net > 0 ? const Color(0xFF059669) : AppPallete.gray),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isSettled
                                    ? 'Settled (₹0)'
                                    : (owes
                                        ? 'Owes ${widget.currency} ${(-net).toStringAsFixed(0)}'
                                        : 'To Receive ${widget.currency} ${net.toStringAsFixed(0)}'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: owes
                                      ? AppPallete.coral
                                      : (net > 0 ? const Color(0xFF059669) : AppPallete.navy),
                                ),
                              ),
                            ],
                          ),
                          if (owes || net > 0)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: owes ? AppPallete.indigo : const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                RecordPaymentSheet.show(
                                  context,
                                  memberNames: [_participant.name],
                                  onRecord: (rec) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Payment recorded! 🤝')),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.payment_rounded, size: 16),
                              label: const Text('Record Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // 3. Expense Participation History
            expensesAsync.when(
              data: (expenses) {
                final participantExpenses = expenses.where((e) {
                  final isPayer = e.payerId == _participant.id || e.payers.containsKey(_participant.id);
                  final inSplit = e.splitDetails.containsKey(_participant.id);
                  return isPayer || inSplit;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Expense History',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: isDark ? Colors.white : AppPallete.navy,
                          ),
                        ),
                        Text(
                          '${participantExpenses.length} entries',
                          style: const TextStyle(fontSize: 12, color: AppPallete.gray),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (participantExpenses.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? AppPallete.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                        ),
                        child: const Center(
                          child: Text(
                            'No expenses logged with this participant yet.',
                            style: TextStyle(color: AppPallete.gray, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ...participantExpenses.map((exp) {
                        final isPayer = exp.payerId == _participant.id || exp.payers.containsKey(_participant.id);
                        final paidAmount = exp.payers[_participant.id] ?? (exp.payerId == _participant.id ? exp.amount : 0.0);
                        final shareAmount = exp.splitDetails[_participant.id] ?? 0.0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppPallete.surfaceDark : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppPallete.indigo.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.receipt_long_rounded, color: AppPallete.indigo, size: 20),
                            ),
                            title: Text(
                              exp.title,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            subtitle: Text(
                              '${DateFormat('d MMM').format(exp.date)} • ${isPayer ? "Paid: ${widget.currency} ${paidAmount.toStringAsFixed(0)}" : "Share: ${widget.currency} ${shareAmount.toStringAsFixed(0)}"}',
                              style: const TextStyle(fontSize: 11, color: AppPallete.gray),
                            ),
                            trailing: Text(
                              '${widget.currency} ${exp.amount.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ),
                        );
                      }),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // 4. Payment History
            paymentsAsync.when(
              data: (payments) {
                final relatedPayments = payments.where((p) =>
                    p.fromMemberId == _participant.id || p.toMemberId == _participant.id).toList();

                if (relatedPayments.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recorded Payments',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppPallete.navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...relatedPayments.map((pmt) {
                      final isSender = pmt.fromMemberId == _participant.id;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppPallete.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.handshake_rounded, color: Color(0xFF10B981), size: 20),
                          ),
                          title: Text(
                            isSender ? 'Payment Sent (${pmt.paymentMethod.toUpperCase()})' : 'Payment Received (${pmt.paymentMethod.toUpperCase()})',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          subtitle: Text(
                            '${DateFormat('d MMM yyyy').format(pmt.paymentDate)}${pmt.recordedOnBehalfOfGuest ? " • Recorded on behalf of guest" : ""}',
                            style: const TextStyle(fontSize: 11, color: AppPallete.gray),
                          ),
                          trailing: Text(
                            '${isSender ? "-" : "+"}${widget.currency} ${pmt.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: isSender ? AppPallete.coral : const Color(0xFF059669),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: true,
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          padding: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Export Statement',
                  icon: Icons.download_rounded,
                  height: 44,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExpenseReportConfigScreen(
                          tripId: widget.tripId,
                          initialParticipantId: _participant.id,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Record Payment',
                  icon: Icons.payments_rounded,
                  height: 44,
                  onPressed: () {
                    RecordPaymentSheet.show(
                      context,
                      memberNames: [_participant.name],
                      participants: [_participant],
                      onRecord: (rec) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment recorded! 🤝')),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String amount,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppPallete.gray),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
