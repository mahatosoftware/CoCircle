import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/theme/app_pallete.dart';
import '../../../core/widgets/app_buttons.dart';
import '../application/expense_report_service.dart';
import '../domain/expense_report_config.dart';
import 'pdf_preview_screen.dart';

class ExpenseReportResultScreen extends ConsumerWidget {
  final GeneratedReportResult report;

  const ExpenseReportResultScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPdf = report.format == ExpenseReportFormat.pdf;
    final dateFmt = DateFormat('d MMM yyyy, h:mm a');

    return Scaffold(
      backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
      appBar: AppBar(
        title: const Text('Report Exported', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: isDark ? AppPallete.surfaceDark : Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Success Icon Container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF059669),
                    size: 46,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Financial Report Ready!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : AppPallete.navy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your trip financial report was compiled using authoritative minor-unit calculation.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppPallete.gray),
              ),
              const SizedBox(height: 24),

              // File Metadata Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppPallete.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isPdf
                                ? const Color(0xFFFEE2E2)
                                : (report.format == ExpenseReportFormat.excel
                                    ? const Color(0xFFD1FAE5)
                                    : const Color(0xFFEEF2FF)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isPdf
                                ? Icons.picture_as_pdf_rounded
                                : (report.format == ExpenseReportFormat.excel
                                    ? Icons.table_view_rounded
                                    : Icons.receipt_long_rounded),
                            color: isPdf
                                ? const Color(0xFFDC2626)
                                : (report.format == ExpenseReportFormat.excel
                                    ? const Color(0xFF059669)
                                    : AppPallete.indigo),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.fileName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : AppPallete.navy,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${report.format.displayName} · ${report.fileSizeFormatted}',
                                style: const TextStyle(fontSize: 11, color: AppPallete.gray),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 14),

                    _buildInfoRow('Trip', report.data.tripName, isDark),
                    const SizedBox(height: 10),
                    _buildInfoRow('Report Type', report.data.filter.reportType.displayName, isDark),
                    const SizedBox(height: 10),
                    _buildInfoRow('Date Range', report.data.filter.datePreset.displayName, isDark),
                    const SizedBox(height: 10),
                    _buildInfoRow('Generated', dateFmt.format(report.data.generatedAt), isDark),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'Total Reconciled',
                      '${report.data.currency}${report.data.totalExpenses.toStringAsFixed(0)}',
                      isDark,
                      valueColor: AppPallete.indigo,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPdf) ...[
                PrimaryButton(
                  label: 'Preview PDF Document',
                  icon: Icons.visibility_rounded,
                  height: 48,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfPreviewScreen(
                          title: report.data.tripName,
                          pdfBytes: report.rawBytes,
                          fileName: report.fileName,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Share',
                      icon: Icons.share_rounded,
                      height: 46,
                      onPressed: () => ref.read(expenseReportServiceProvider).shareReport(report),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SecondaryButton(
                      label: 'Open File',
                      icon: Icons.file_open_rounded,
                      height: 46,
                      onPressed: () async {
                        final res = await ref.read(expenseReportServiceProvider).openReport(report);
                        if (res.type != ResultType.done && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not open file: ${res.message}')),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Configure Another Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppPallete.gray, fontWeight: FontWeight.w500)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor ?? (isDark ? Colors.white : AppPallete.navy),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
