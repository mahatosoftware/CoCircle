import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../../core/theme/app_pallete.dart';
import '../data/expense_stats_provider.dart';
import '../domain/expense_model.dart';
import '../../../trips/presentation/trip_controller.dart';
import '../../../circles/presentation/circle_controller.dart';
import '../../../../core/widgets/copyright_footer.dart';

class ExpenseStatsView extends ConsumerWidget {
  final String tripId;
  const ExpenseStatsView({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryStatsAsync = ref.watch(expenseCategoryStatsProvider(tripId));
    final memberStatsAsync = ref.watch(expenseMemberStatsProvider(tripId));
    final shareStatsAsync = ref.watch(expenseMemberShareProvider(tripId));
    final totalSpendingAsync = ref.watch(tripTotalSpendingProvider(tripId));
    final tripAsync = ref.watch(tripDetailsProvider(tripId));

    return tripAsync.when(
      data: (trip) {
        final circleAsync = ref.watch(circleDetailsProvider(trip.circleId));
        final membersAsync = ref.watch(circleMembersProvider(trip.circleId));

        return circleAsync.when(
          data: (circle) {
            final currency = circle.currency;
            final format = NumberFormat.currency(symbol: '$currency ');

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(totalSpendingAsync, format),
                  const SizedBox(height: 24),
                  Text(
                    'Spending by Category',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryChart(categoryStatsAsync, format),
                  const SizedBox(height: 32),
                  Text(
                    'Spending by Member (Who Paid)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildMemberChart(memberStatsAsync, membersAsync, format),
                  const SizedBox(height: 32),
                  Text(
                    'Liability (Who Owes what)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildShareChart(shareStatsAsync, membersAsync, format),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildSummaryCard(AsyncValue<double> totalAsync, NumberFormat format) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppPallete.primary, AppPallete.trustBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Total Spending',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            totalAsync.when(
              data: (total) => Text(
                format.format(total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              loading: () => const CircularProgressIndicator(color: Colors.white),
              error: (err, _) => const Text('Error', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(AsyncValue<Map<String, double>> statsAsync, NumberFormat format) {
    return statsAsync.when(
      data: (stats) {
        if (stats.isEmpty) {
          return const Center(child: Text('No expenses recorded yet.'));
        }

        final total = stats.values.fold(0.0, (sum, val) => sum + val);

        return Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: stats.entries.map((entry) {
                    final percentage = (entry.value / total) * 100;
                    return PieChartSectionData(
                      color: _getCategoryColor(entry.key),
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: stats.entries.map((entry) {
                return _LegendItem(
                  color: _getCategoryColor(entry.key),
                  text: '${entry.key.toUpperCase()}: ${format.format(entry.value)}',
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }

  Widget _buildMemberChart(
    AsyncValue<Map<String, double>> statsAsync,
    AsyncValue<List<dynamic>> membersAsync,
    NumberFormat format,
  ) {
    return statsAsync.when(
      data: (stats) {
        if (stats.isEmpty) return const SizedBox.shrink();

        final total = stats.values.fold(0.0, (sum, val) => sum + val);

        return membersAsync.when(
          data: (members) {
            return Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: stats.entries.toList().asMap().entries.map((chartEntry) {
                        final entry = chartEntry.value;
                        final index = chartEntry.key;
                        final percentage = (entry.value / total) * 100;
                        return PieChartSectionData(
                          color: Colors.primaries[index % Colors.primaries.length],
                          value: entry.value,
                          title: '${percentage.toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: stats.entries.toList().asMap().entries.map((chartEntry) {
                    final entry = chartEntry.value;
                    final index = chartEntry.key;
                    final member = members.firstWhereOrNull((m) => m.uid == entry.key);
                    final name = member?.displayName ?? entry.key.substring(0, 5);
                    return _LegendItem(
                      color: Colors.primaries[index % Colors.primaries.length],
                      text: '$name: ${format.format(entry.value)}',
                    );
                  }).toList(),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error: $err'),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildShareChart(
    AsyncValue<Map<String, double>> statsAsync,
    AsyncValue<List<dynamic>> membersAsync,
    NumberFormat format,
  ) {
    return statsAsync.when(
      data: (stats) {
        if (stats.isEmpty) return const SizedBox.shrink();

        final total = stats.values.fold(0.0, (sum, val) => sum + val);

        return membersAsync.when(
          data: (members) {
            return Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: stats.entries.toList().asMap().entries.map((chartEntry) {
                        final entry = chartEntry.value;
                        final index = chartEntry.key;
                        final percentage = (entry.value / total) * 100;
                        return PieChartSectionData(
                          color: Colors.primaries[(index + 5) % Colors.primaries.length], // Offset color for distinction
                          value: entry.value,
                          title: '${percentage.toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: stats.entries.toList().asMap().entries.map((chartEntry) {
                    final entry = chartEntry.value;
                    final index = chartEntry.key;
                    final member = members.firstWhereOrNull((m) => m.uid == entry.key);
                    final name = member?.displayName ?? entry.key.substring(0, 5);
                    return _LegendItem(
                      color: Colors.primaries[(index + 5) % Colors.primaries.length],
                      text: '$name: ${format.format(entry.value)}',
                    );
                  }).toList(),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error: $err'),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => const SizedBox.shrink(),
    );
  }


  Color _getCategoryColor(String categoryName) {
    final category = ExpenseCategory.values.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => ExpenseCategory.misc,
    );
    switch (category) {
      case ExpenseCategory.food: return Colors.orange;
      case ExpenseCategory.travel: return Colors.blue;
      case ExpenseCategory.stay: return Colors.purple;
      case ExpenseCategory.shopping: return Colors.pink;
      case ExpenseCategory.fuel: return Colors.red;
      case ExpenseCategory.misc: return Colors.grey;
      case ExpenseCategory.settlement: return Colors.teal;
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
