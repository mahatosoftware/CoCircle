import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_pallete.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../trips/presentation/trip_controller.dart';
import '../../trips/presentation/trip_participant_controller.dart';
import '../../financial/expenses/presentation/expense_controller.dart';
import '../application/expense_report_service.dart';
import '../domain/expense_report_config.dart';
import 'expense_report_result_screen.dart';

class ExpenseReportConfigScreen extends ConsumerStatefulWidget {
  final String tripId;
  final String? initialParticipantId;

  const ExpenseReportConfigScreen({
    super.key,
    required this.tripId,
    this.initialParticipantId,
  });

  @override
  ConsumerState<ExpenseReportConfigScreen> createState() => _ExpenseReportConfigScreenState();
}

class _ExpenseReportConfigScreenState extends ConsumerState<ExpenseReportConfigScreen> {
  late ExpenseReportFilter _filter;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _filter = ExpenseReportFilter(
      reportType: widget.initialParticipantId != null
          ? ExpenseReportType.participantWise
          : ExpenseReportType.completeTrip,
      selectedParticipantId: widget.initialParticipantId,
    );
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _filter.customStartDate != null && _filter.customEndDate != null
          ? DateTimeRange(start: _filter.customStartDate!, end: _filter.customEndDate!)
          : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppPallete.indigo,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppPallete.navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _filter = _filter.copyWith(
          datePreset: ExpenseDateRangePreset.custom,
          customStartDate: picked.start,
          customEndDate: picked.end,
        );
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);
    try {
      final report = await ref.read(expenseReportServiceProvider).generateReport(
            tripId: widget.tripId,
            filter: _filter,
          );

      if (mounted) {
        setState(() => _isGenerating = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExpenseReportResultScreen(report: report),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final participantsAsync = ref.watch(tripParticipantsProvider(widget.tripId));
    final expensesAsync = ref.watch(tripExpensesProvider(widget.tripId));

    final participants = participantsAsync.value ?? [];
    final expenses = expensesAsync.value ?? [];

    return Scaffold(
      backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
      appBar: AppBar(
        title: const Text('Export Expense Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: isDark ? AppPallete.surfaceDark : Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Export Format Selection
              _buildSectionHeader('1. Export Format', isDark),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildFormatCard(
                    format: ExpenseReportFormat.pdf,
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'PDF Document',
                    subtitle: 'Printable & Shareable',
                    iconColor: const Color(0xFFDC2626),
                    iconBg: const Color(0xFFFEE2E2),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _buildFormatCard(
                    format: ExpenseReportFormat.excel,
                    icon: Icons.table_view_rounded,
                    label: 'Excel (.xlsx)',
                    subtitle: 'Multi-Sheet Data',
                    iconColor: const Color(0xFF059669),
                    iconBg: const Color(0xFFD1FAE5),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _buildFormatCard(
                    format: ExpenseReportFormat.csv,
                    icon: Icons.receipt_long_rounded,
                    label: 'CSV Data',
                    subtitle: 'Raw Spreadsheet',
                    iconColor: AppPallete.indigo,
                    iconBg: const Color(0xFFEEF2FF),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Report Type Selection
              _buildSectionHeader('2. Report Scope', isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppPallete.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ExpenseReportType>(
                    value: _filter.reportType,
                    isExpanded: true,
                    items: ExpenseReportType.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t.displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _filter = _filter.copyWith(reportType: val));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Date Range Presets
              _buildSectionHeader('3. Date Range', isDark),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ExpenseDateRangePreset.values.map((preset) {
                  final isSelected = _filter.datePreset == preset;
                  return ChoiceChip(
                    label: Text(preset.displayName),
                    selected: isSelected,
                    selectedColor: AppPallete.indigo,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppPallete.navy),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        if (preset == ExpenseDateRangePreset.custom) {
                          _pickCustomDateRange();
                        } else {
                          setState(() => _filter = _filter.copyWith(datePreset: preset));
                        }
                      }
                    },
                  );
                }).toList(),
              ),
              if (_filter.datePreset == ExpenseDateRangePreset.custom &&
                  _filter.customStartDate != null &&
                  _filter.customEndDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Selected: ${DateFormat('d MMM yyyy').format(_filter.customStartDate!)} - ${DateFormat('d MMM yyyy').format(_filter.customEndDate!)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppPallete.indigo),
                ),
              ],
              const SizedBox(height: 24),

              // 4. Participant Selection (Registered & Guests)
              _buildSectionHeader('4. Participant Filter', isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppPallete.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _filter.selectedParticipantId,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Participants (Group Report)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                      ...participants.map((p) {
                        return DropdownMenuItem<String?>(
                          value: p.id,
                          child: Row(
                            children: [
                              Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                      }),
                    ],
                    onChanged: (val) {
                      setState(() {
                        if (val == null) {
                          _filter = _filter.copyWith(clearParticipant: true);
                        } else {
                          _filter = _filter.copyWith(selectedParticipantId: val);
                        }
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 5. Category Filter
              _buildSectionHeader('5. Category Filter', isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppPallete.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _filter.selectedCategory,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Expense Categories', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                      DropdownMenuItem(value: 'food', child: Text('Food & Drinks')),
                      DropdownMenuItem(value: 'stay', child: Text('Accommodation & Stay')),
                      DropdownMenuItem(value: 'transport', child: Text('Transport & Flights')),
                      DropdownMenuItem(value: 'fuel', child: Text('Fuel & Tolls')),
                      DropdownMenuItem(value: 'activities', child: Text('Sightseeing & Activities')),
                      DropdownMenuItem(value: 'shopping', child: Text('Shopping')),
                      DropdownMenuItem(value: 'tickets', child: Text('Entry Tickets')),
                      DropdownMenuItem(value: 'general', child: Text('Miscellaneous')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        if (val == null) {
                          _filter = _filter.copyWith(clearCategory: true);
                        } else {
                          _filter = _filter.copyWith(selectedCategory: val);
                        }
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 6. Report Options & Inclusions
              _buildSectionHeader('6. Optional Sections to Include', isDark),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppPallete.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildToggleTile(
                      'Participant Summary',
                      'Detailed breakdown of amounts paid, share, and net balances',
                      _filter.includeParticipantDetails,
                      (val) => setState(() => _filter = _filter.copyWith(includeParticipantDetails: val)),
                      isDark,
                    ),
                    const Divider(height: 1),
                    _buildToggleTile(
                      'Category Breakdown',
                      'Percentage distribution across spending categories',
                      _filter.includeCategoryBreakdown,
                      (val) => setState(() => _filter = _filter.copyWith(includeCategoryBreakdown: val)),
                      isDark,
                    ),
                    const Divider(height: 1),
                    _buildToggleTile(
                      'Payment History',
                      'Recorded cash, UPI, and bank transfer settlements',
                      _filter.includePayments,
                      (val) => setState(() => _filter = _filter.copyWith(includePayments: val)),
                      isDark,
                    ),
                    const Divider(height: 1),
                    _buildToggleTile(
                      'Settlement Transfers',
                      'Recommended multilateral debt simplification transfers',
                      _filter.includeSettlements,
                      (val) => setState(() => _filter = _filter.copyWith(includeSettlements: val)),
                      isDark,
                    ),
                    const Divider(height: 1),
                    _buildToggleTile(
                      'Write-offs & Waivers',
                      'Voluntary debt forgiveness and settlement adjustments',
                      _filter.includeAdjustments,
                      (val) => setState(() => _filter = _filter.copyWith(includeAdjustments: val)),
                      isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 7. Live Scope Preview Card
              _buildSectionHeader('Live Report Scope Preview', isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppPallete.indigo, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${tripAsync.value?.name ?? "Trip"} · ${_filter.format.extensionName.toUpperCase()}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppPallete.navy),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${expenses.length} expenses · ${participants.length} participants (${participants.where((p) => p.isGuest).length} guests) · Authoritative exact calculation',
                            style: const TextStyle(fontSize: 11, color: AppPallete.gray),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
          child: PrimaryButton(
            label: 'Generate & Export Report',
            icon: Icons.download_rounded,
            height: 48,
            isLoading: _isGenerating,
            onPressed: _generateReport,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
        color: isDark ? Colors.white : AppPallete.navy,
      ),
    );
  }

  Widget _buildFormatCard({
    required ExpenseReportFormat format,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color iconColor,
    required Color iconBg,
    required bool isDark,
  }) {
    final isSelected = _filter.format == format;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = _filter.copyWith(format: format)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppPallete.indigo
                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppPallete.navy,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 9, color: AppPallete.gray),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    bool isDark,
  ) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppPallete.gray)),
      value: value,
      activeThumbColor: AppPallete.indigo,
      onChanged: onChanged,
    );
  }
}
