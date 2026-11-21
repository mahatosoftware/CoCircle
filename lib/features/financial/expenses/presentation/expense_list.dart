import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/expense_model.dart';
import 'expense_controller.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../trips/presentation/trip_controller.dart';
import 'package:cocircle/l10n/app_localizations.dart';
import '../../../../core/widgets/native_ad_widget.dart';

class ExpenseList extends ConsumerStatefulWidget {
  final String tripId;
  final String currency;
  const ExpenseList({super.key, required this.tripId, required this.currency});

  @override
  ConsumerState<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends ConsumerState<ExpenseList> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final expensesStream = ref.watch(tripExpensesProvider(widget.tripId));
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return expensesStream.when(
      data: (expenses) {
        final trip = tripAsync.asData?.value;
        final totalBudget = (trip != null && trip.totalBudget > 0) ? trip.totalBudget : 60000.0;
        final memberCount = (trip != null && trip.participantIds.isNotEmpty) ? trip.participantIds.length : 1;

        // Calculate total spent excluding settlement transfers
        final nonSettlementExpenses = expenses.where((e) => e.category != ExpenseCategory.settlement.name).toList();
        final totalSpent = nonSettlementExpenses.fold(0.0, (sum, e) => sum + e.amount);
        final perPersonAvg = memberCount > 0 ? (totalSpent / memberCount) : totalSpent;
        final spentPercent = totalBudget > 0 ? ((totalSpent / totalBudget) * 100).clamp(0.0, 100.0) : 0.0;

        // Filter by category
        final filteredExpenses = _selectedCategory == 'all'
            ? nonSettlementExpenses
            : nonSettlementExpenses.where((e) => e.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

        final int adInterval = 4;
        final int listCount = filteredExpenses.isEmpty
            ? 0
            : filteredExpenses.length + (filteredExpenses.length / adInterval).floor();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          itemCount: 3 + (filteredExpenses.isEmpty ? 1 : listCount),
          itemBuilder: (context, index) {
            // Item 0: Wireframe 1 Screen 9 KPI Summary Card
            if (index == 0) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppPallete.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: AppPallete.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Spent',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.currency} ${totalSpent.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: isDark ? Colors.white : AppPallete.navy,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Per Person (Avg)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.currency} ${perPersonAvg.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: isDark ? Colors.white : AppPallete.navy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Budget: ${widget.currency} ${totalBudget.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                        ),
                        Text(
                          '${spentPercent.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: spentPercent > 90 ? AppPallete.coral : AppPallete.indigo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (spentPercent / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          spentPercent > 90 ? AppPallete.coral : AppPallete.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Item 1: Smart Split Camera AI Banner
            if (index == 1) {
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 0,
                color: AppPallete.indigo.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppPallete.indigo.withValues(alpha: 0.2)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppPallete.indigo,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.document_scanner, color: Colors.white, size: 20),
                  ),
                  title: const Text(
                    'Smart Split Camera',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Auto-extract restaurant receipts & UPI bills with AI',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () => context.push('/trip/${widget.tripId}/scan-bill'),
                ),
              );
            }

            // Item 2: Category Filter Chips (Wireframe 2 Phone 5)
            if (index == 2) {
              final categories = [
                {'id': 'all', 'label': 'All'},
                {'id': 'food', 'label': 'Food'},
                {'id': 'travel', 'label': 'Travel'},
                {'id': 'stay', 'label': 'Stay'},
                {'id': 'fuel', 'label': 'Fuel'},
                {'id': 'shopping', 'label': 'Shopping'},
                {'id': 'misc', 'label': 'Other'},
              ];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = _selectedCategory == cat['id'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(
                            cat['label']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                            ),
                          ),
                          backgroundColor: isDark ? AppPallete.surfaceDark : const Color(0xFFF1F5F9),
                          selectedColor: AppPallete.indigo,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppPallete.indigo
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                          ),
                          onSelected: (val) {
                            setState(() {
                              _selectedCategory = cat['id']!;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }

            // Empty state for filtered expenses
            if (filteredExpenses.isEmpty) {
              return Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark ? AppPallete.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                ),
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
                      child: const Icon(Icons.receipt_long_outlined, size: 28, color: AppPallete.indigo),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _selectedCategory == 'all' ? l10n.noExpensesYet : 'No $_selectedCategory expenses',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Log an expense to split costs automatically across the group.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => context.push('/trip/${widget.tripId}/create-expense'),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Trip Expense', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            }

            final listIndex = index - 3;
            if (listIndex > 0 && listIndex % (adInterval + 1) == 0) {
              return const NativeAdWidget();
            }

            final expenseIndex = listIndex - (listIndex / (adInterval + 1)).floor();
            if (expenseIndex >= filteredExpenses.length) return const SizedBox.shrink();

            final expense = filteredExpenses[expenseIndex];
            final isCurrentUserPayer = expense.payerId == FirebaseAuth.instance.currentUser?.uid;
            final splitMemberCount = expense.splitDetails.isNotEmpty ? expense.splitDetails.length : memberCount;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDark ? AppPallete.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: AppPallete.cardShadow,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(expense.category).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: _getCategoryColor(expense.category),
                    size: 22,
                  ),
                ),
                title: Text(
                  expense.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    '${DateFormat('d MMM').format(expense.date)} • Paid by ${isCurrentUserPayer ? "You" : "Member"} • Split: $splitMemberCount members',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.currency} ${expense.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppPallete.navy,
                      ),
                    ),
                    if (expense.category != ExpenseCategory.settlement.name)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 20),
                        onSelected: (value) {
                          if (value == 'edit') {
                            context.push('/trip/${widget.tripId}/expense/${expense.id}/edit', extra: expense);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 18),
                                const SizedBox(width: 8),
                                Text(l10n.edit),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                onTap: () {
                  context.push('/trip/${widget.tripId}/expense/${expense.id}');
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.errorWithDetails(e.toString()))),
    );
  }

  Color _getCategoryColor(String categoryName) {
    final category = ExpenseCategory.values.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => ExpenseCategory.misc,
    );
    switch (category) {
      case ExpenseCategory.food:
        return const Color(0xFFF59E0B);
      case ExpenseCategory.travel:
        return AppPallete.indigo;
      case ExpenseCategory.stay:
        return AppPallete.teal;
      case ExpenseCategory.fuel:
        return const Color(0xFFEC4899);
      case ExpenseCategory.shopping:
        return const Color(0xFF8B5CF6);
      case ExpenseCategory.settlement:
        return const Color(0xFF10B981);
      case ExpenseCategory.misc:
        return AppPallete.gray;
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    final category = ExpenseCategory.values.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => ExpenseCategory.misc,
    );
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.travel:
        return Icons.flight_takeoff_rounded;
      case ExpenseCategory.stay:
        return Icons.hotel_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_outlined;
      case ExpenseCategory.fuel:
        return Icons.local_gas_station_rounded;
      case ExpenseCategory.misc:
        return Icons.receipt_long_rounded;
      case ExpenseCategory.settlement:
        return Icons.handshake_rounded;
    }
  }
}
