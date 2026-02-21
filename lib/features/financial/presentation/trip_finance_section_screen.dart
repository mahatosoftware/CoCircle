import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../expenses/presentation/expense_list.dart';
import '../expenses/presentation/expense_stats_screen.dart';
import '../expenses/presentation/expense_audit_screen.dart';
import '../settlements/presentation/settlement_list.dart';
import '../../trips/domain/trip_model.dart';
import '../../trips/presentation/trip_controller.dart';
import '../../circles/presentation/circle_controller.dart';
import 'package:cocircle/l10n/app_localizations.dart';

enum FinanceSectionType { expenses, settlements, insights, audit }

class TripFinanceSectionScreen extends ConsumerWidget {
  final String tripId;
  final FinanceSectionType type;

  const TripFinanceSectionScreen({
    super.key,
    required this.tripId,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripDetailsProvider(tripId));
    final l10n = AppLocalizations.of(context)!;

    return tripAsync.when(
      data: (trip) {
        final circleAsync = ref.watch(circleDetailsProvider(trip.circleId));
        
        return circleAsync.when(
          data: (circle) {
            String title;
            Widget body;
            
            switch (type) {
              case FinanceSectionType.expenses:
                title = l10n.expenses;
                body = ExpenseList(tripId: tripId, currency: circle.currency);
                break;
              case FinanceSectionType.settlements:
                title = l10n.settlements;
                body = SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          l10n.settlementPlanTitle(circle.currency),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SettlementList(tripId: tripId, currency: circle.currency),
                    ],
                  ),
                );
                break;
              case FinanceSectionType.insights:
                title = l10n.insights;
                body = ExpenseStatsView(tripId: tripId);
                break;
              case FinanceSectionType.audit:
                title = l10n.audit;
                body = ExpenseAuditView(tripId: tripId);
                break;
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(title),
              ),
              body: body,
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
    );
  }
}
