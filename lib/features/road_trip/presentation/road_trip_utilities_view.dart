import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/status_badge.dart';
import '../domain/road_trip_utilities_model.dart';
import 'road_trip_controller.dart';

class RoadTripUtilitiesView extends ConsumerStatefulWidget {
  final String tripId;

  const RoadTripUtilitiesView({super.key, required this.tripId});

  @override
  ConsumerState<RoadTripUtilitiesView> createState() => _RoadTripUtilitiesViewState();
}

class _RoadTripUtilitiesViewState extends ConsumerState<RoadTripUtilitiesView> {
  int _activeUtility = 0; // 0: Cash Change Calculator, 1: Vehicle Readiness Checklist

  // Cash Change Calculator Controllers
  final _billController = TextEditingController(text: '750');
  final _receivedController = TextEditingController(text: '1000');
  CashChangeResult? _changeResult;

  @override
  void initState() {
    super.initState();
    _computeChange();
  }

  @override
  void dispose() {
    _billController.dispose();
    _receivedController.dispose();
    super.dispose();
  }

  void _computeChange() {
    final bill = double.tryParse(_billController.text) ?? 0.0;
    final received = double.tryParse(_receivedController.text) ?? 0.0;
    setState(() {
      _changeResult = CashChangeResult.calculate(billAmount: bill, cashReceived: received);
    });
  }

  @override
  Widget build(BuildContext context) {
    final checklistAsync = ref.watch(roadTripChecklistStreamProvider(widget.tripId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segment switch
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppPallete.surfaceDark : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildUtilityTabChip(0, 'Cash Change Calculator', Icons.payments_rounded, isDark),
                  ),
                  Expanded(
                    child: _buildUtilityTabChip(1, 'Vehicle Inspection', Icons.fact_check_rounded, isDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_activeUtility == 0)
              _buildCashChangeCalculator(context, isDark)
            else
              checklistAsync.when(
                data: (items) => _buildVehicleChecklist(context, items, isDark),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading checklist: $e')),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilityTabChip(int index, String label, IconData icon, bool isDark) {
    final isSelected = _activeUtility == index;
    return GestureDetector(
      onTap: () => setState(() => _activeUtility = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppPallete.indigo : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? (isDark ? Colors.white : AppPallete.indigo)
                  : AppPallete.gray,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : AppPallete.navy)
                      : AppPallete.gray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashChangeCalculator(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppPallete.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.currency_rupee_rounded, color: AppPallete.teal, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('Highway Toll / Dhaba Change', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _billController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Bill Amount (₹)',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _computeChange(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _receivedController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Cash Received (₹)',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _computeChange(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_changeResult != null) ...[
          // Change summary card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFF8FAFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppPallete.indigo.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CHANGE TO RETURN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppPallete.indigo)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${_changeResult!.changeToReturn.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppPallete.navy),
                    ),
                  ],
                ),
                StatusBadge.success(label: 'Exact Change'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Denomination breakdown
          if (_changeResult!.denominationBreakdown.isNotEmpty) ...[
            const Text('Optimal Currency Denominations', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _changeResult!.denominationBreakdown.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppPallete.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppPallete.indigo.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('₹${entry.key}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppPallete.indigo, fontSize: 13)),
                      ),
                      const SizedBox(width: 8),
                      Text('× ${entry.value} notes', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildVehicleChecklist(BuildContext context, List<VehicleChecklistItem> items, bool isDark) {
    final completedCount = items.where((i) => i.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pre-Trip Vehicle Inspection', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('$completedCount of ${items.length} safety checks verified',
                      style: const TextStyle(fontSize: 11, color: AppPallete.gray)),
                ],
              ),
              StatusBadge.fromTripStatus(completedCount == items.length ? 'Confirmed' : 'Planning'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        ...items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? AppPallete.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: item.isCompleted
                    ? const Color(0xFF10B981).withValues(alpha: 0.4)
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
            ),
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              title: Text(
                item.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(item.description, style: const TextStyle(fontSize: 11, color: AppPallete.gray)),
              value: item.isCompleted,
              activeColor: const Color(0xFF10B981),
              onChanged: (val) {
                ref.read(roadTripControllerProvider).toggleChecklistItem(
                      widget.tripId,
                      item.id,
                      val ?? false,
                      'Driver',
                    );
              },
            ),
          );
        }),
      ],
    );
  }
}
