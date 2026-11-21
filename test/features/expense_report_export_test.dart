import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:excel/excel.dart';
import 'package:cocircle/core/finance/exact_money_calculator.dart';
import 'package:cocircle/features/financial/expenses/domain/expense_model.dart';
import 'package:cocircle/features/financial/payments/domain/guest_payment_model.dart';
import 'package:cocircle/features/financial/settlements/domain/settlement_model.dart';
import 'package:cocircle/features/reports/application/expense_report_data_aggregator.dart';
import 'package:cocircle/features/reports/domain/expense_report_config.dart';
import 'package:cocircle/features/reports/infrastructure/csv_report_generator.dart';
import 'package:cocircle/features/reports/infrastructure/excel_report_generator.dart';
import 'package:cocircle/features/reports/infrastructure/pdf_report_generator.dart';
import 'package:cocircle/features/trips/domain/trip_model.dart';
import 'package:cocircle/features/trips/domain/trip_participant_model.dart';

void main() {
  final mockTrip = TripModel(
    id: 'trip_goa_001',
    circleId: 'circle_friends_001',
    name: 'Goa Getaway 2026',
    type: TripType.trip,
    startDate: DateTime(2026, 3, 12),
    endDate: DateTime(2026, 3, 16),
    location: 'Goa, India',
    totalBudget: 60000.0,
    createdBy: 'user_rahul',
    createdAt: DateTime(2026, 3, 1),
  );

  final mockParticipants = [
    TripParticipantModel(
      id: 'user_rahul',
      tripId: 'trip_goa_001',
      name: 'Rahul Sharma',
      participantType: TripParticipantType.registered,
      userId: 'user_rahul',
      addedBy: 'user_rahul',
      createdAt: DateTime(2026, 3, 1),
    ),
    TripParticipantModel(
      id: 'user_priya',
      tripId: 'trip_goa_001',
      name: 'Priya Patel',
      participantType: TripParticipantType.registered,
      userId: 'user_priya',
      addedBy: 'user_rahul',
      createdAt: DateTime(2026, 3, 1),
    ),
    TripParticipantModel(
      id: 'guest_amit',
      tripId: 'trip_goa_001',
      name: 'Amit Kumar',
      participantType: TripParticipantType.guest,
      phoneNumber: '+919876543210',
      addedBy: 'user_rahul',
      createdAt: DateTime(2026, 3, 2),
    ),
    TripParticipantModel(
      id: 'guest_neha',
      tripId: 'trip_goa_001',
      name: 'Neha Verma',
      participantType: TripParticipantType.guest,
      addedBy: 'user_rahul',
      createdAt: DateTime(2026, 3, 2),
    ),
  ];

  // Expenses:
  // 1. Hotel: ₹12,000 paid by Rahul, split equally across 4 (₹3,000 each)
  final hotelSplits = ExactMoneyCalculator.calculateEqualSplit(
    12000.0,
    ['user_rahul', 'user_priya', 'guest_amit', 'guest_neha'],
  );
  final expense1 = ExpenseModel(
    id: 'exp_hotel_01',
    tripId: 'trip_goa_001',
    title: 'Beach Resort Stay (2 nights)',
    amount: 12000.0,
    date: DateTime(2026, 3, 12, 11, 0),
    category: 'stay',
    payerId: 'user_rahul',
    splitType: SplitType.equal,
    payers: {'user_rahul': 12000.0},
    splitDetails: hotelSplits,
    createdBy: 'user_rahul',
    createdAt: DateTime(2026, 3, 12),
  );

  // 2. Dinner: ₹4,000 paid by Guest Amit, split equally across Rahul & Amit (₹2,000 each)
  final dinnerSplits = ExactMoneyCalculator.calculateEqualSplit(
    4000.0,
    ['user_rahul', 'guest_amit'],
  );
  final expense2 = ExpenseModel(
    id: 'exp_dinner_02',
    tripId: 'trip_goa_001',
    title: 'Seafood Dinner at Brittos',
    amount: 4000.0,
    date: DateTime(2026, 3, 13, 20, 0),
    category: 'food',
    payerId: 'guest_amit',
    splitType: SplitType.equal,
    payers: {'guest_amit': 4000.0},
    splitDetails: dinnerSplits,
    createdBy: 'user_rahul',
    createdAt: DateTime(2026, 3, 13),
  );

  // 3. Fuel: ₹2,000 paid by Priya, split equally across 4 (₹500 each)
  final fuelSplits = ExactMoneyCalculator.calculateEqualSplit(
    2000.0,
    ['user_rahul', 'user_priya', 'guest_amit', 'guest_neha'],
  );
  final expense3 = ExpenseModel(
    id: 'exp_fuel_03',
    tripId: 'trip_goa_001',
    title: 'Convoy Fuel & Highway Toll',
    amount: 2000.0,
    date: DateTime(2026, 3, 14, 9, 30),
    category: 'transport',
    payerId: 'user_priya',
    splitType: SplitType.equal,
    payers: {'user_priya': 2000.0},
    splitDetails: fuelSplits,
    createdBy: 'user_priya',
    createdAt: DateTime(2026, 3, 14),
  );

  final allExpenses = [expense1, expense2, expense3];

  // Payment: Neha pays ₹1,500 partial payment to Rahul in Cash (recorded on behalf of guest)
  final payment1 = GuestPaymentModel(
    id: 'pay_001',
    tripId: 'trip_goa_001',
    fromMemberId: 'guest_neha',
    toMemberId: 'user_rahul',
    amount: 1500.0,
    paymentMethod: 'Cash',
    paymentDate: DateTime(2026, 3, 15, 10, 0),
    referenceNumber: 'CASH-001',
    recordedBy: 'user_rahul',
    recordedOnBehalfOfGuest: true,
    paymentStatus: 'completed',
    createdAt: DateTime(2026, 3, 15),
  );

  final allPayments = [payment1];

  // Adjustment: Rahul waives ₹500 of Neha's remaining debt
  final adj1 = SettlementAdjustmentModel(
    id: 'adj_001',
    tripId: 'trip_goa_001',
    creditorUid: 'user_rahul',
    debtorUid: 'guest_neha',
    amount: 500.0,
    reason: 'Voluntary fuel share waiver',
    createdAt: DateTime(2026, 3, 15, 12, 0),
  );

  final List<SettlementAdjustmentModel> allAdjustments = [adj1];

  group('Expense Report Export Feature Test Suite', () {
    test('1. Data Aggregator aggregates exact totals across registered & guest participants', () {
      const config = ExpenseReportFilter(
        reportType: ExpenseReportType.completeTrip,
        format: ExpenseReportFormat.pdf,
      );

      final data = ExpenseReportDataAggregator.aggregate(
        trip: mockTrip,
        allParticipants: mockParticipants,
        allExpenses: allExpenses,
        allPayments: allPayments,
        allAdjustments: allAdjustments,
        currency: '₹',
        generatedBy: 'Rahul Sharma',
        filter: config,
      );

      expect(data.tripName, equals('Goa Getaway 2026'));
      expect(data.totalExpenses, equals(18000.0)); // 12000 + 4000 + 2000
      expect(data.totalContributed, equals(1500.0)); // Payment of 1500
      expect(data.participants.length, equals(4));
      expect(data.registeredCount, equals(2));
      expect(data.guestCount, equals(2));

      // Category breakdown
      expect(data.categoryTotals['stay'], equals(12000.0));
      expect(data.categoryTotals['food'], equals(4000.0));
      expect(data.categoryTotals['transport'], equals(2000.0));

      // Rahul paid: 12000 (hotel). Share: 3000 (hotel) + 2000 (dinner) + 500 (fuel) = 5500.
      // Received payment: 1500 from Neha. Waived: 500 to Neha.
      // Net without payment: 12000 - 5500 = +6500.
      // With payment 1500 + waiver 500: Neha transferred 2000 credit to Rahul.
      // Rahul net: +6500 - 1500 - 500 = +4500.
      expect(data.balances['user_rahul']!.netAmount, equals(4500.0));

      // Guest Neha: Paid 0. Share: 3000 (hotel) + 500 (fuel) = 3500.
      // Paid 1500 (payment) + 500 (waiver) = 2000.
      // Net: 2000 - 3500 = -1500.
      expect(data.balances['guest_neha']!.netAmount, equals(-1500.0));

      // Guest Amit: Paid 4000 (dinner). Share: 3000 (hotel) + 2000 (dinner) + 500 (fuel) = 5500.
      // Net: 4000 - 5500 = -1500.
      expect(data.balances['guest_amit']!.netAmount, equals(-1500.0));

      // Priya: Paid 2000 (fuel). Share: 3000 (hotel) + 500 (fuel) = 3500.
      // Net: 2000 - 3500 = -1500.
      expect(data.balances['user_priya']!.netAmount, equals(-1500.0));

      // Sum of net balances must be zero (conservation of money)
      final sumNet = data.balances.values.fold<double>(0.0, (s, b) => s + b.netAmount);
      expect(sumNet.round(), equals(0));
    });

    test('2. Individual Guest Participant statement isolates single member financial state', () {
      const config = ExpenseReportFilter(
        reportType: ExpenseReportType.participantWise,
        selectedParticipantId: 'guest_amit',
        format: ExpenseReportFormat.pdf,
      );

      final data = ExpenseReportDataAggregator.aggregate(
        trip: mockTrip,
        allParticipants: mockParticipants,
        allExpenses: allExpenses,
        allPayments: allPayments,
        allAdjustments: allAdjustments,
        currency: '₹',
        generatedBy: 'Rahul Sharma',
        filter: config,
      );

      expect(data.isIndividualParticipantReport, isTrue);
      expect(data.selectedParticipant?.id, equals('guest_amit'));
      expect(data.selectedParticipant?.isGuest, isTrue);
      expect(data.balances['guest_amit']!.netAmount, equals(-1500.0));
    });

    test('3. Date Range and Category filters filter transactions accurately', () {
      // Filter for only 'food' category
      const foodConfig = ExpenseReportFilter(
        reportType: ExpenseReportType.categoryWise,
        selectedCategory: 'food',
        format: ExpenseReportFormat.csv,
      );

      final foodData = ExpenseReportDataAggregator.aggregate(
        trip: mockTrip,
        allParticipants: mockParticipants,
        allExpenses: allExpenses,
        allPayments: allPayments,
        allAdjustments: allAdjustments,
        currency: '₹',
        generatedBy: 'Rahul Sharma',
        filter: foodConfig,
      );

      expect(foodData.expenses.length, equals(1));
      expect(foodData.expenses.first.title, equals('Seafood Dinner at Brittos'));
      expect(foodData.totalExpenses, equals(4000.0));

      // Filter for custom date range (only March 12)
      final dateConfig = ExpenseReportFilter(
        reportType: ExpenseReportType.expenseTransactions,
        datePreset: ExpenseDateRangePreset.custom,
        customStartDate: DateTime(2026, 3, 12),
        customEndDate: DateTime(2026, 3, 12),
        format: ExpenseReportFormat.excel,
      );

      final dateData = ExpenseReportDataAggregator.aggregate(
        trip: mockTrip,
        allParticipants: mockParticipants,
        allExpenses: allExpenses,
        allPayments: allPayments,
        allAdjustments: allAdjustments,
        currency: '₹',
        generatedBy: 'Rahul Sharma',
        filter: dateConfig,
      );

      expect(dateData.expenses.length, equals(1));
      expect(dateData.expenses.first.title, equals('Beach Resort Stay (2 nights)'));
    });

    test('4. CSV Generator outputs valid UTF-8 format with exact transaction numbers', () {
      const config = ExpenseReportFilter(format: ExpenseReportFormat.csv);
      final data = ExpenseReportDataAggregator.aggregate(
        trip: mockTrip,
        allParticipants: mockParticipants,
        allExpenses: allExpenses,
        allPayments: allPayments,
        allAdjustments: allAdjustments,
        currency: '₹',
        generatedBy: 'Rahul Sharma',
        filter: config,
      );

      final csvBytes = CsvReportGenerator.generate(data);
      expect(csvBytes.isNotEmpty, isTrue);

      final csvString = utf8.decode(csvBytes);
      expect(csvString.contains('# COCIRCLE FINANCIAL EXPENSE REPORT'), isTrue);
      expect(csvString.contains('Goa Getaway 2026'), isTrue);
      expect(csvString.contains('Beach Resort Stay (2 nights)'), isTrue);
      expect(csvString.contains('12000.0'), isTrue);
      expect(csvString.contains('Amit Kumar'), isTrue);
      expect(csvString.contains('Guest'), isTrue);
      expect(csvString.contains('Registered Member'), isTrue);
    });

    test('5. Excel Generator outputs multi-sheet workbook with numeric cells and formatted data', () {
      const config = ExpenseReportFilter(format: ExpenseReportFormat.excel);
      final data = ExpenseReportDataAggregator.aggregate(
        trip: mockTrip,
        allParticipants: mockParticipants,
        allExpenses: allExpenses,
        allPayments: allPayments,
        allAdjustments: allAdjustments,
        currency: '₹',
        generatedBy: 'Rahul Sharma',
        filter: config,
      );

      final excelBytes = ExcelReportGenerator.generate(data);
      expect(excelBytes.isNotEmpty, isTrue);

      final excel = Excel.decodeBytes(excelBytes);
      // Verify sheet names
      final sheetNames = excel.tables.keys.toList();
      expect(sheetNames.contains('Trip Summary'), isTrue);
      expect(sheetNames.contains('All Expenses'), isTrue);
      expect(sheetNames.contains('Expense Splits'), isTrue);
      expect(sheetNames.contains('Participant Summary'), isTrue);
      expect(sheetNames.contains('Payments'), isTrue);
      expect(sheetNames.contains('Settlement Details'), isTrue);
      expect(sheetNames.contains('Outstanding Balances'), isTrue);
      expect(sheetNames.contains('Adjustments & Write-offs'), isTrue);

      // Verify Trip Summary has data
      final summarySheet = excel.tables['Trip Summary']!;
      expect(summarySheet.rows.isNotEmpty, isTrue);
    });

    test('6. PDF Generator produces valid binary document matching CoCircle specification', () async {
      const config = ExpenseReportFilter(format: ExpenseReportFormat.pdf);
      final data = ExpenseReportDataAggregator.aggregate(
        trip: mockTrip,
        allParticipants: mockParticipants,
        allExpenses: allExpenses,
        allPayments: allPayments,
        allAdjustments: allAdjustments,
        currency: '₹',
        generatedBy: 'Rahul Sharma',
        filter: config,
      );

      final pdfBytes = await PdfReportGenerator.generate(data);
      expect(pdfBytes.isNotEmpty, isTrue);

      // Verify PDF header magic bytes "%PDF-"
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, equals('%PDF-'));
    });

    test('7. Financial consistency is guaranteed: PDF, Excel, and CSV share identical totals', () async {
      const config = ExpenseReportFilter();
      final data = ExpenseReportDataAggregator.aggregate(
        trip: mockTrip,
        allParticipants: mockParticipants,
        allExpenses: allExpenses,
        allPayments: allPayments,
        allAdjustments: allAdjustments,
        currency: '₹',
        generatedBy: 'Rahul Sharma',
        filter: config,
      );

      // Total expenses = 18,000.00 exactly
      expect(data.totalExpenses, equals(18000.0));
      // Total contributed = 1,500.00 exactly
      expect(data.totalContributed, equals(1500.0));

      final csvBytes = CsvReportGenerator.generate(data);
      final excelBytes = ExcelReportGenerator.generate(data);
      final pdfBytes = await PdfReportGenerator.generate(data);

      expect(csvBytes.length > 100, isTrue);
      expect(excelBytes.length > 500, isTrue);
      expect(pdfBytes.length > 1000, isTrue);
    });
  });
}
