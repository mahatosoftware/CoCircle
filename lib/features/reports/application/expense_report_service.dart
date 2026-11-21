import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

import '../../auth/data/auth_repository_impl.dart';
import '../../circles/presentation/circle_controller.dart';
import '../../financial/expenses/presentation/expense_controller.dart';
import '../../financial/settlements/presentation/settlement_controller.dart';
import '../../trips/presentation/trip_controller.dart';
import '../../trips/presentation/trip_participant_controller.dart';
import '../domain/expense_report_config.dart';
import '../infrastructure/csv_report_generator.dart';
import '../infrastructure/excel_report_generator.dart';
import '../infrastructure/pdf_report_generator.dart';
import 'expense_report_data_aggregator.dart';

final expenseReportServiceProvider = Provider<ExpenseReportService>((ref) {
  return ExpenseReportService(ref);
});

class GeneratedReportResult {
  final String fileName;
  final String filePath;
  final int fileSizeBytes;
  final ExpenseReportFormat format;
  final ExpenseReportData data;
  final Uint8List rawBytes;

  const GeneratedReportResult({
    required this.fileName,
    required this.filePath,
    required this.fileSizeBytes,
    required this.format,
    required this.data,
    required this.rawBytes,
  });

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class ExpenseReportService {
  final Ref _ref;

  ExpenseReportService(this._ref);

  /// Aggregates all data and generates a structured report file
  Future<GeneratedReportResult> generateReport({
    required String tripId,
    required ExpenseReportFilter filter,
  }) async {
    // 1. Fetch trip and circular metadata
    final trip = await _ref.read(tripDetailsProvider(tripId).future);
    final circle = await _ref.read(circleDetailsProvider(trip.circleId).future);
    final currency = circle.currency;

    final currentUser = await _ref.read(authRepositoryProvider).getCurrentUser();
    final generatedBy = currentUser?.displayName ?? 'Trip Organizer';

    // 2. Fetch financial entities
    final participants = await _ref.read(tripParticipantsProvider(tripId).future);
    final expenses = await _ref.read(tripExpensesProvider(tripId).future);
    final payments = await _ref.read(tripPaymentsProvider(tripId).future);
    final adjustments = await _ref.read(tripAdjustmentsProvider(tripId).future);

    // 3. Aggregate authoritative data bundle
    final reportData = ExpenseReportDataAggregator.aggregate(
      trip: trip,
      allParticipants: participants,
      allExpenses: expenses,
      allPayments: payments,
      allAdjustments: adjustments,
      currency: currency,
      generatedBy: generatedBy,
      filter: filter,
    );

    // 4. Generate binary report based on format
    late Uint8List fileBytes;
    switch (filter.format) {
      case ExpenseReportFormat.pdf:
        fileBytes = await PdfReportGenerator.generate(reportData);
        break;
      case ExpenseReportFormat.excel:
        fileBytes = ExcelReportGenerator.generate(reportData);
        break;
      case ExpenseReportFormat.csv:
        fileBytes = CsvReportGenerator.generate(reportData);
        break;
    }

    // 5. Save to local temporary directory with clean sanitized name
    final timeStampStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final sanitizedTrip = trip.name.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final extension = filter.format.extensionName;
    final fileName = 'CoCircle_${sanitizedTrip}_Report_$timeStampStr.$extension';

    final tempDir = await getTemporaryDirectory();
    final reportsDir = Directory('${tempDir.path}/cocircle_reports');
    if (!reportsDir.existsSync()) {
      await reportsDir.create(recursive: true);
    }

    // Clean up temporary files older than 24 hours
    _cleanupOldReports(reportsDir);

    final file = File('${reportsDir.path}/$fileName');
    await file.writeAsBytes(fileBytes);

    return GeneratedReportResult(
      fileName: fileName,
      filePath: file.path,
      fileSizeBytes: fileBytes.length,
      format: filter.format,
      data: reportData,
      rawBytes: fileBytes,
    );
  }

  /// Share file through native sharing dialog (WhatsApp, Drive, Email, etc.)
  Future<void> shareReport(GeneratedReportResult report) async {
    final xFile = XFile(
      report.filePath,
      mimeType: report.format.mimeType,
      name: report.fileName,
    );

    await SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        text: 'Sharing consolidated financial report for "${report.data.tripName}".',
      ),
    );
  }

  /// Open file using native OS application
  Future<OpenResult> openReport(GeneratedReportResult report) async {
    return await OpenFilex.open(report.filePath);
  }

  void _cleanupOldReports(Directory reportsDir) {
    try {
      final now = DateTime.now();
      final entities = reportsDir.listSync();
      for (final entity in entities) {
        if (entity is File) {
          final stat = entity.statSync();
          if (now.difference(stat.modified).inHours > 24) {
            entity.deleteSync();
          }
        }
      }
    } catch (e) {
      debugPrint('Temporary report cleanup warning: $e');
    }
  }
}
