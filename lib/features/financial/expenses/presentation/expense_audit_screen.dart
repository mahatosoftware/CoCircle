import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../domain/audit_log_model.dart';
import 'expense_controller.dart';
import '../../../trips/presentation/trip_controller.dart';
import '../../../circles/presentation/circle_controller.dart';
import '../../../../core/theme/app_pallete.dart';
import 'package:cocircle/l10n/app_localizations.dart';

class ExpenseAuditView extends ConsumerWidget {
  final String tripId;
  const ExpenseAuditView({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditLogsAsync = ref.watch(tripAuditLogsProvider(tripId));
    final tripAsync = ref.watch(tripDetailsProvider(tripId));
    final l10n = AppLocalizations.of(context)!;

    return tripAsync.when(
      data: (trip) {
        final circleAsync = ref.watch(circleDetailsProvider(trip.circleId));
        final membersAsync = ref.watch(circleMembersProvider(trip.circleId));

        return circleAsync.when(
          data: (circle) {
            final currency = circle.currency;
            final format = NumberFormat.currency(symbol: '$currency ');

            return membersAsync.when(
              data: (members) {
                return auditLogsAsync.when(
                  data: (logs) {
                    if (logs.isEmpty) {
                      return Center(child: Text(l10n.noAuditHistory));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: logs.length,
                      separatorBuilder: (context, index) => const Divider(height: 32),
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        final activityUser = members.firstWhere(
                          (m) => m.uid == log.userId,
                          orElse: () => members.first, // Fallback
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    log.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  format.format(log.amount),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: log.action == AuditAction.delete 
                                      ? Colors.red 
                                      : AppPallete.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildActionBadge(context, log.action),
                                const SizedBox(width: 8),
                                Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.activityByUser(activityUser.displayName),
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                                const Spacer(),
                                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                  Text(
                                    DateFormat('MMM dd, yyyy HH:mm').format(log.timestamp),
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                              if (log.action == AuditAction.update && (log.changes?.isNotEmpty ?? false)) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      final memberNames = {
                                        for (final m in members) m.uid: m.displayName
                                      };
                                      context.push(
                                        '/trip/$tripId/audit-detail',
                                        extra: {
                                          'log': log,
                                          'currency': currency,
                                          'memberNames': memberNames,
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.compare_arrows, size: 18),
                                    label: Text(l10n.viewSpecificChanges),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppPallete.primary,
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text(l10n.errorWithDetails(err.toString()))),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text(l10n.loadMembersError(err.toString()))),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text(l10n.errorWithDetails(err.toString()))),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text(l10n.errorWithDetails(err.toString()))),
    );
  }

  Widget _buildActionBadge(BuildContext context, AuditAction action) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String label;
    switch (action) {
      case AuditAction.create:
        color = Colors.green;
        label = l10n.auditActionCreate;
        break;
      case AuditAction.update:
        color = Colors.blue;
        label = l10n.auditActionUpdate;
        break;
      case AuditAction.delete:
        color = Colors.red;
        label = l10n.auditActionDelete;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Removed _buildBadge and _getCategoryColor as they are no longer used.
}
