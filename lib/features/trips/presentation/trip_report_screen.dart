import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../circles/presentation/circle_controller.dart';
import '../../financial/expenses/presentation/expense_controller.dart';
import '../../financial/settlements/presentation/settlement_controller.dart';
import 'trip_controller.dart';
import 'trip_planner_controller.dart';
import 'trip_participant_controller.dart';

class TripReportScreen extends ConsumerWidget {
  final String tripId;

  const TripReportScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripDetailsProvider(tripId));
    final expensesAsync = ref.watch(tripExpensesProvider(tripId));
    final itineraryAsync = ref.watch(tripItineraryProvider(tripId));
    final adjustmentsAsync = ref.watch(tripAdjustmentsProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consolidated Trip Report', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export Report (PDF / Excel / CSV)',
            onPressed: () => context.push('/trip/$tripId/export-report'),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Quick Share',
            onPressed: () => context.push('/trip/$tripId/export-report'),
          ),
        ],
      ),
      body: tripAsync.when(
        data: (trip) {
          final circleAsync = ref.watch(circleDetailsProvider(trip.circleId));
          final membersAsync = ref.watch(circleMembersProvider(trip.circleId));
          final participantsAsync = ref.watch(tripParticipantsProvider(tripId));
          final balancesAsync = ref.watch(tripParticipantBalancesProvider(tripId));
          final currency = circleAsync.value?.currency ?? '₹';

          final expenses = expensesAsync.value ?? [];
          final itinerary = itineraryAsync.value ?? [];
          final adjustments = adjustmentsAsync.value ?? [];
          final participants = participantsAsync.value ?? [];
          final balances = balancesAsync.value ?? {};

          final totalSpent = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
          final totalParticipants = participants.isNotEmpty ? participants.length : (membersAsync.value?.length ?? 1);
          final perPersonAvg = totalParticipants > 0 ? (totalSpent / totalParticipants) : totalSpent;

          // Category breakdown
          final Map<String, double> categoryBreakdown = {};
          for (final e in expenses) {
            categoryBreakdown[e.category] = (categoryBreakdown[e.category] ?? 0.0) + e.amount;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              // 1. Hero Card
              Card(
                elevation: 0,
                color: const Color(0xFFEEF2FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFC7D2FE)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusBadge.success(label: 'Trip Closed & Reconciled'),
                          Text(
                            DateFormat.yMMMd().format(trip.closedAt ?? DateTime.now()),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        trip.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Circle: ${circleAsync.value?.name ?? "CoCircle"} · Destination: ${trip.location ?? "Various"}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 20,
                        runSpacing: 10,
                        children: [
                          _buildMetric('Total Expenditure', '$currency${totalSpent.toStringAsFixed(0)}'),
                          _buildMetric('Per Person Avg', '$currency${perPersonAvg.toStringAsFixed(0)}'),
                          _buildMetric('Activities Done', '${itinerary.length} stops'),
                          _buildMetric(
                            'Participants',
                            '$totalParticipants (${participants.where((p) => p.isGuest).length} Guests)',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Export Report Prominent CTA Button
              OutlinedButton.icon(
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Export Official Financial Report (PDF / Excel / CSV)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppPallete.indigo,
                  side: const BorderSide(color: AppPallete.indigo),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => context.push('/trip/$tripId/export-report'),
              ),
              const SizedBox(height: 20),

              // 2. Financial Ledger & Category Breakdown
              const Text('Expense Category Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: categoryBreakdown.entries.map((entry) {
                      final pct = totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Text(
                              entry.key.toUpperCase(),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                            const Spacer(),
                            Text(
                              '$currency${entry.value.toStringAsFixed(0)} (${pct.toStringAsFixed(0)}%)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Participant Settlement & Reconciliation Table (Requirement 12)
              const Text('Participant Reconciliation & Settlement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (participants.isNotEmpty) ...[
                        for (final p in participants) ...[
                          Builder(builder: (_) {
                            final bal = balances[p.id];
                            final paid = bal?.totalPaidAmount ?? 0.0;
                            final share = bal?.totalShareAmount ?? 0.0;
                            final net = bal?.netAmount ?? 0.0;
                            final isSettled = (bal?.netPaise ?? 0) == 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: p.isGuest
                                        ? const Color(0xFFFEF3C7)
                                        : AppPallete.indigo.withValues(alpha: 0.15),
                                    child: Text(
                                      p.initials,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: p.isGuest ? const Color(0xFF92400E) : AppPallete.indigo,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              p.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            if (p.isGuest) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFEF3C7),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text('Guest', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                                              ),
                                            ],
                                          ],
                                        ),
                                        Text(
                                          'Paid: $currency${paid.toStringAsFixed(0)} · Share: $currency${share.toStringAsFixed(0)}',
                                          style: const TextStyle(fontSize: 11, color: AppPallete.gray),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        isSettled
                                            ? 'Settled'
                                            : (net > 0 ? '+$currency${net.toStringAsFixed(0)}' : '-$currency${(-net).toStringAsFixed(0)}'),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isSettled
                                              ? const Color(0xFF059669)
                                              : (net > 0 ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                                        ),
                                      ),
                                      Text(
                                        p.isGuest ? 'Guest participant' : 'Registered member',
                                        style: const TextStyle(fontSize: 10, color: AppPallete.gray),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (p != participants.last) const Divider(height: 12),
                        ],
                      ] else ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No participants recorded for this trip.', style: TextStyle(color: Colors.grey)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Voluntary Write-offs & Waivers Applied
              if (adjustments.isNotEmpty) ...[
                const Text('Voluntary Write-offs & Waivers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Card(
                  elevation: 0,
                  color: const Color(0xFFFDF4FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFF0ABFC)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: adjustments.map((adj) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.volunteer_activism_rounded, color: Color(0xFFA855F7), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Waived $currency${adj.amount.toStringAsFixed(0)} (${adj.reason})',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const StatusBadge(
                                label: 'Waived',
                                backgroundColor: Color(0xFFFAE8FF),
                                textColor: Color(0xFF86198F),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 4. Itinerary Execution Highlights
              const Text('Completed Itinerary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (itinerary.isEmpty)
                const Text('No activities recorded', style: TextStyle(color: Colors.grey))
              else
                ...itinerary.map((item) {
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.check_circle_outline_rounded, color: AppPallete.tertiary),
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat.jm().format(item.startTime)),
                    ),
                  );
                }),
              const SizedBox(height: 20),

              // 5. Actions: Duplicate as Blueprint
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Duplicate as Blueprint'),
                        content: Text('Create a new trip reusing the itinerary and packing list from "${trip.name}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              final newId = await ref.read(tripControllerProvider.notifier).duplicateTrip(
                                    sourceTripId: trip.id,
                                    targetCircleId: trip.circleId,
                                    newName: '${trip.name} (Blueprint)',
                                    newStartDate: DateTime.now().add(const Duration(days: 14)),
                                    context: context,
                                  );
                              if (newId != null && context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Duplicate'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Duplicate Trip as Blueprint for Future Travel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppPallete.primary)),
      ],
    );
  }
}
