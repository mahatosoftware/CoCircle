import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cocircle/features/trips/presentation/trip_controller.dart';
import 'package:cocircle/features/circles/presentation/circle_controller.dart';
import 'package:cocircle/features/financial/settlements/presentation/settlement_controller.dart';
import 'package:cocircle/features/financial/expenses/domain/expense_model.dart';
import 'package:cocircle/features/financial/expenses/presentation/expense_controller.dart';
import 'package:cocircle/features/financial/settlements/domain/settlement_model.dart';
import 'package:cocircle/l10n/app_localizations.dart';
import 'package:cocircle/features/auth/domain/user_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:cocircle/features/auth/data/auth_repository_impl.dart';
import 'package:cocircle/core/utils/snackbar.dart';

class SettlementList extends ConsumerWidget {
  final String tripId;
  final String currency;
  const SettlementList({super.key, required this.tripId, required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripDetailsProvider(tripId));
    final activeSettlementsAsync = ref.watch(activeSettlementsProvider(tripId));
    final expensesAsync = ref.watch(tripExpensesProvider(tripId));
    final currentUserAsync = ref.watch(authStateChangesProvider);
    final l10n = AppLocalizations.of(context)!;

    return tripAsync.when(
      data: (trip) {
        final membersAsync = ref.watch(circleMembersProvider(trip.circleId));

        return activeSettlementsAsync.when(
          data: (settlements) {
            return membersAsync.when(
              data: (members) {
                return expensesAsync.when(
                  data: (expenses) {
                    final currentUser = currentUserAsync.value;
                    final isUserVpaEmpty = currentUser == null || currentUser.vpa == null || currentUser.vpa!.isEmpty;

                    final isAnyReceiverVpaEmpty = settlements.any((t) {
                      final receiver = members.firstWhereOrNull((m) => m.uid == t.toUid);
                      return receiver == null || receiver.vpa == null || receiver.vpa!.isEmpty;
                    });

                    final isInr = currency.toUpperCase() == 'INR' || currency == '₹';
                    final showUpiMessage = isInr && (isUserVpaEmpty || isAnyReceiverVpaEmpty);
                    final history = expenses.where((e) => e.category == ExpenseCategory.settlement.name).toList();

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showUpiMessage)
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline, color: Colors.blue),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        l10n.enableUpiMessage,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => context.push('/profile'),
                                  child: Text(l10n.goToProfile),
                                ),
                              ],
                            ),
                          ),
                        if (settlements.isEmpty && history.isEmpty)
                          _buildEmptyState(context, ref)
                        else ...[
                          if (settlements.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                              child: Text(
                                l10n.activeSettlements,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ...settlements.asMap().entries.map((entry) {
                              final t = entry.value;
                              return _buildActiveSettlementCard(context, ref, t, members);
                            }),
                          ],
                          if (history.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                              child: Text(
                                l10n.settlementHistory,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ...history.map((expense) => _buildHistoryTile(context, expense, members)),
                          ],
                          const SizedBox(height: 100),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Error loading history: $e')),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(child: Text('Error loading members: $err')),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Center(child: Text(l10n.calculateSettlementsError(e.toString()))),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text(l10n.loadTripError(err.toString()))),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.green[100]),
          const SizedBox(height: 24),
          Text(
            l10n.allSettledUp,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.allSettledUpDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSettlementCard(BuildContext context, WidgetRef ref, SettlementTransaction t, List<UserModel> members) {
    final l10n = AppLocalizations.of(context)!;
    final fromMember = members.firstWhereOrNull((m) => m.uid == t.fromUid);
    final toMember = members.firstWhereOrNull((m) => m.uid == t.toUid);
    final fromName = fromMember?.displayName ?? t.fromUid.substring(0, 4);
    final toName = toMember?.displayName ?? t.toUid.substring(0, 4);

    final currentUser = FirebaseAuth.instance.currentUser;
    final isPayer = currentUser?.uid == t.fromUid;
    final isReceiver = currentUser?.uid == t.toUid;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.send, color: Colors.green, size: 20),
              ),
              title: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  children: [
                    TextSpan(text: fromName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' ${l10n.paysLabel('', '').split('  ').first.split('pays').first.isEmpty ? ' pays ' : l10n.paysLabel('', '').replaceAll('{from}', '').replaceAll('{to}', '')} '),
                    TextSpan(text: toName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              trailing: Text(
                '$currency${t.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
              ),
            ),
//             if (isPayer && toMember?.vpa != null && (currency.toUpperCase() == 'INR' || currency == '₹'))
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton.icon(
//                     onPressed: () => _initiateUpiTransaction(context, t, toMember!, currency),
//                     icon: const Icon(Icons.account_balance_outlined, size: 18),
//                     label: const Text('Pay via UPI'),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.green,
//                       side: const BorderSide(color: Colors.green),
//                     ),
//                   ),
//                 ),
//               ),
            if (isPayer || isReceiver)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmSettleUp(context, ref, t, fromName, toName),
                  icon: const Icon(Icons.check),
                  label: Text(l10n.settleUp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context, ExpenseModel expense, List<UserModel> members) {
    final l10n = AppLocalizations.of(context)!;
    final fromUid = expense.payerId;
    final toUid = expense.splitDetails.keys.first;

    final fromMember = members.firstWhereOrNull((m) => m.uid == fromUid);
    final toMember = members.firstWhereOrNull((m) => m.uid == toUid);

    final fromName = fromMember?.displayName ?? fromUid.substring(0, 4);
    final toName = toMember?.displayName ?? toUid.substring(0, 4);

    return ListTile(
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(l10n.settledWithLabel(fromName, toName)),
      subtitle: Text(DateFormat.MMMd().format(expense.date)),
      trailing: Text(
        '$currency${expense.amount.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _confirmSettleUp(BuildContext context, WidgetRef ref, SettlementTransaction t, String fromName, String toName) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isPayer = currentUser?.uid == t.fromUid;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.settleUp),
          content: Text(isPayer
              ? l10n.confirmPaidMessage(currency, t.amount, toName)
              : l10n.confirmReceivedMessage(currency, t.amount, fromName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(settlementControllerProvider.notifier).settleUp(
                      tripId: tripId,
                      fromUid: t.fromUid,
                      toUid: t.toUid,
                      amount: t.amount,
                      context: context, // Using outer context
                    );
                Navigator.pop(dialogContext);
              },
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
  }

  void _showUPIReviewSheet(
    BuildContext context,
    SettlementTransaction t,
    UserModel receiver,
    String currency,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Review Payment',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildReviewRow('Amount', '$currency${t.amount.toStringAsFixed(2)}', isBold: true),
            const Divider(height: 32),
            _buildReviewRow('To', receiver.displayName),
            const SizedBox(height: 8),
            _buildReviewRow('UPI ID', receiver.vpa ?? ''),
            const SizedBox(height: 8),
            _buildReviewRow('Note', 'CoCircle Settlement'),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Verify the receiver's name inside the UPI app before confirming.",
                      style: TextStyle(fontSize: 12, color: Colors.amber[900]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _launchUPIIntent(context, t, receiver, currency);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Open UPI App', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _initiateUpiTransaction(
    BuildContext context,
    SettlementTransaction t,
    UserModel receiver,
    String currency,
  ) async {
    _showUPIReviewSheet(context, t, receiver, currency);
  }

  Future<void> _launchUPIIntent(
    BuildContext context,
    SettlementTransaction t,
    UserModel receiver,
    String currency,
  ) async {
    if (receiver.vpa == null) return;

    final String receiverVpa = receiver.vpa!;
    final String receiverName = receiver.displayName.replaceAll(RegExp(r'[^\w\s]'), '');
    final String amount = t.amount.toStringAsFixed(2);
    final String transactionRef = DateTime.now().millisecondsSinceEpoch.toString().substring(3, 13);
    const String transactionNote = 'CoCircle Settlement';

    final String query = 'pa=${Uri.encodeComponent(receiverVpa)}'
        '&pn=${Uri.encodeComponent(receiverName)}'
        '&am=$amount'
        '&tr=$transactionRef'
        '&tn=${Uri.encodeComponent(transactionNote)}'
        '&cu=INR';

    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (!isIOS) {
      // Android: Standard system picker via upi://
      final Uri upiUri = Uri.parse('upi://pay?$query');
      if (await canLaunchUrl(upiUri)) {
        await launchUrl(upiUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) showSnackBar(context, 'No UPI apps found to handle this request.');
      }
      return;
    }

    // iOS Implementation: Check specific apps because there's no system picker
    final List<_IOSUpiApp> apps = [
      _IOSUpiApp(name: 'Google Pay', scheme: 'tez://pay?'),
      _IOSUpiApp(name: 'PhonePe', scheme: 'phonepe://pay?'),
      _IOSUpiApp(name: 'Paytm', scheme: 'paytmmp://pay?'),
      _IOSUpiApp(name: 'BHIM', scheme: 'bhim://pay?'),
      _IOSUpiApp(name: 'Amazon Pay', scheme: 'amazonpay://pay?'),
    ];

    final List<_IOSUpiApp> installedApps = [];
    for (var app in apps) {
      if (await canLaunchUrl(Uri.parse(app.scheme))) {
        installedApps.add(app);
      }
    }

    if (installedApps.isEmpty) {
      // Fallback to generic upi://
      final Uri genericUri = Uri.parse('upi://pay?$query');
      if (await canLaunchUrl(genericUri)) {
        await launchUrl(genericUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) showSnackBar(context, 'No UPI apps found on this device.');
      }
      return;
    }

    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Select UPI App', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...installedApps.map((app) => ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.green),
                    title: Text(app.name),
                    onTap: () async {
                      Navigator.pop(context);
                      final Uri launchUri = Uri.parse('${app.scheme}$query');
                      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
                    },
                  )),
              ListTile(
                leading: const Icon(Icons.open_in_new),
                title: const Text('Default UPI App'),
                onTap: () async {
                  Navigator.pop(context);
                  await launchUrl(Uri.parse('upi://pay?$query'), mode: LaunchMode.externalApplication);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }
  }
}

class _IOSUpiApp {
  final String name;
  final String scheme;
  _IOSUpiApp({required this.name, required this.scheme});
}
