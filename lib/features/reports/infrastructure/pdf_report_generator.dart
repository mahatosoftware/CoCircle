import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../domain/expense_report_config.dart';

class PdfReportGenerator {
  PdfReportGenerator._();

  // CoCircle Theme Colors in PDF format
  static final PdfColor navy = PdfColor.fromHex('#0B1F3B');
  static final PdfColor indigo = PdfColor.fromHex('#5B42F3');
  static final PdfColor teal = PdfColor.fromHex('#14BBA6');
  static final PdfColor emerald = PdfColor.fromHex('#059669');
  static final PdfColor amber = PdfColor.fromHex('#F59E0B');
  static final PdfColor coral = PdfColor.fromHex('#DC2626');
  static final PdfColor gray = PdfColor.fromHex('#64748B');
  static final PdfColor lightGray = PdfColor.fromHex('#F1F5F9');
  static final PdfColor borderGray = PdfColor.fromHex('#E2E8F0');
  static final PdfColor guestBadgeBg = PdfColor.fromHex('#FEF3C7');
  static final PdfColor guestBadgeText = PdfColor.fromHex('#92400E');

  static Future<Uint8List> generate(ExpenseReportData data) async {
    final pdf = pw.Document(
      title: '${data.tripName} - Financial Report',
      author: 'CoCircle Group Travel',
    );

    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
    final shortDateFmt = DateFormat('d MMM yyyy');
    final pMap = {for (final p in data.participants) p.id: p};
    final cur = (data.currency == '₹' || data.currency == 'INR') ? 'Rs.' : data.currency;

    String datesText = 'Flexible Dates';
    if (data.tripStartDate != null) {
      final s = shortDateFmt.format(data.tripStartDate!);
      final e = data.tripEndDate != null ? shortDateFmt.format(data.tripEndDate!) : '';
      datesText = e.isNotEmpty ? '$s - $e' : s;
    }

    // Header widget for pages
    pw.Widget buildPageHeader(pw.Context context) {
      return pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 12),
        margin: const pw.EdgeInsets.only(bottom: 16),
        decoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: borderGray, width: 1)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(
              children: [
                pw.Container(
                  width: 24,
                  height: 24,
                  decoration: pw.BoxDecoration(
                    color: indigo,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'C',
                      style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Text(
                  'CoCircle Financial Statement',
                  style: pw.TextStyle(color: navy, fontWeight: pw.FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            pw.Text(
              'Trip: ${data.tripName}',
              style: pw.TextStyle(color: gray, fontSize: 10),
            ),
          ],
        ),
      );
    }

    // Footer widget with pagination
    pw.Widget buildPageFooter(pw.Context context) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 14),
        padding: const pw.EdgeInsets.only(top: 10),
        decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: borderGray, width: 1)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated on ${dateFmt.format(data.generatedAt)} via CoCircle',
              style: pw.TextStyle(color: gray, fontSize: 9),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(color: gray, fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // Badge widget for Guest / Member
    pw.Widget buildBadge(bool isGuest) {
      if (isGuest) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: pw.BoxDecoration(
            color: guestBadgeBg,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            'Guest',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: guestBadgeText),
          ),
        );
      }
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: pw.BoxDecoration(
          color: lightGray,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          'Member',
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: gray),
        ),
      );
    }

    // ==========================================
    // MULTIPAGE DOCUMENT BODY
    // ==========================================
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: buildPageHeader,
        footer: buildPageFooter,
        build: (pw.Context context) {
          final widgets = <pw.Widget>[];

          // ------------------------------------------
          // 1. EXECUTIVE SUMMARY & COVER
          // ------------------------------------------
          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: lightGray,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: borderGray, width: 1),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            data.tripName.toUpperCase(),
                            style: pw.TextStyle(
                              color: navy,
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '${data.destination ?? "Various Locations"}  |  $datesText',
                            style: pw.TextStyle(color: gray, fontSize: 11),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: pw.BoxDecoration(
                          color: indigo,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          data.filter.reportType.shortName,
                          style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                  pw.Divider(color: borderGray, height: 1),
                  pw.SizedBox(height: 14),

                  // KPI 4-Box Grid
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Total Expenditure', style: pw.TextStyle(color: gray, fontSize: 9)),
                            pw.SizedBox(height: 3),
                            pw.Text(
                              '$cur${data.totalExpenses.toStringAsFixed(0)}',
                              style: pw.TextStyle(color: navy, fontSize: 16, fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Contributed / Paid', style: pw.TextStyle(color: gray, fontSize: 9)),
                            pw.SizedBox(height: 3),
                            pw.Text(
                              '$cur${data.totalContributed.toStringAsFixed(0)}',
                              style: pw.TextStyle(color: emerald, fontSize: 16, fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Outstanding Owed', style: pw.TextStyle(color: gray, fontSize: 9)),
                            pw.SizedBox(height: 3),
                            pw.Text(
                              '$cur${data.totalOutstanding.toStringAsFixed(0)}',
                              style: pw.TextStyle(
                                color: data.totalOutstanding > 0 ? coral : emerald,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Participants', style: pw.TextStyle(color: gray, fontSize: 9)),
                            pw.SizedBox(height: 3),
                            pw.Text(
                              '${data.participants.length} (${data.guestCount} Guests)',
                              style: pw.TextStyle(color: navy, fontSize: 14, fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );

          // If this is an Individual Participant Report, show highlighted banner
          if (data.isIndividualParticipantReport && data.selectedParticipant != null) {
            final sp = data.selectedParticipant!;
            final b = data.balances[sp.id];
            final net = b?.netAmount ?? 0.0;
            final isSettled = (b?.netPaise ?? 0) == 0;

            widgets.add(pw.SizedBox(height: 14));
            widgets.add(
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#EEF2FF'),
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: PdfColor.fromHex('#C7D2FE')),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Text(
                          'INDIVIDUAL PARTICIPANT STATEMENT: ${sp.name}',
                          style: pw.TextStyle(color: indigo, fontWeight: pw.FontWeight.bold, fontSize: 12),
                        ),
                        pw.SizedBox(width: 8),
                        buildBadge(sp.isGuest),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Paid: $cur${(b?.totalPaidAmount ?? 0).toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('Expense Share: $cur${(b?.totalShareAmount ?? 0).toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(
                          isSettled
                              ? 'Status: Settled'
                              : (net > 0 ? 'Receivable: +$cur${net.toStringAsFixed(0)}' : 'Payable: -$cur${(-net).toStringAsFixed(0)}'),
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: isSettled ? emerald : (net > 0 ? emerald : coral),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      '* Note: This is an individual statement reflecting ${sp.name}\'s participation and does not represent the full trip ledger.',
                      style: pw.TextStyle(color: gray, fontSize: 8, fontStyle: pw.FontStyle.italic),
                    ),
                  ],
                ),
              ),
            );
          }

          widgets.add(pw.SizedBox(height: 20));

          // ------------------------------------------
          // 2. PARTICIPANT FINANCIAL SUMMARY TABLE
          // ------------------------------------------
          if (data.filter.includeParticipantDetails) {
            widgets.add(
              pw.Text(
                '1. Participant Financial Summary',
                style: pw.TextStyle(color: navy, fontSize: 13, fontWeight: pw.FontWeight.bold),
              ),
            );
            widgets.add(pw.SizedBox(height: 8));

            widgets.add(
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9),
                headerDecoration: pw.BoxDecoration(color: navy),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                headers: ['Participant', 'Type', 'Amount Paid', 'Expense Share', 'Net Balance', 'Status'],
                data: data.participants.map((p) {
                  final b = data.balances[p.id];
                  final paid = b?.totalPaidAmount ?? 0.0;
                  final share = b?.totalShareAmount ?? 0.0;
                  final net = b?.netAmount ?? 0.0;
                  final isSettled = (b?.netPaise ?? 0) == 0;
                  final statusText = isSettled ? 'Settled' : (net > 0 ? 'To Receive' : 'To Pay');
                  final netFormatted = isSettled
                      ? '${cur}0'
                      : (net > 0 ? '+$cur${net.toStringAsFixed(0)}' : '-$cur${(-net).toStringAsFixed(0)}');

                  return [
                    p.name,
                    p.isGuest ? 'Guest' : 'Member',
                    '$cur${paid.toStringAsFixed(0)}',
                    '$cur${share.toStringAsFixed(0)}',
                    netFormatted,
                    statusText,
                  ];
                }).toList(),
              ),
            );
            widgets.add(pw.SizedBox(height: 20));
          }

          // ------------------------------------------
          // 3. EXPENSE TRANSACTION DETAILS
          // ------------------------------------------
          widgets.add(
            pw.Text(
              '2. Expense Transaction Ledger',
              style: pw.TextStyle(color: navy, fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
          );
          widgets.add(pw.SizedBox(height: 8));

          if (data.expenses.isEmpty) {
            widgets.add(
              pw.Text('No expenses recorded matching the current filter.', style: pw.TextStyle(color: gray, fontSize: 10)),
            );
          } else {
            widgets.add(
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9),
                headerDecoration: pw.BoxDecoration(color: indigo),
                cellStyle: const pw.TextStyle(fontSize: 8),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                headers: ['Date', 'Title', 'Category', 'Amount', 'Paid By', 'Split', 'Parts', 'Notes'],
                data: data.expenses.map((e) {
                  final payer = pMap[e.payerId]?.name ?? e.payerId;
                  return [
                    shortDateFmt.format(e.date),
                    e.title,
                    e.category.toUpperCase(),
                    '$cur${e.amount.toStringAsFixed(0)}',
                    payer,
                    e.splitType.name,
                    '${e.splitDetails.length}',
                    e.notes ?? '',
                  ];
                }).toList(),
              ),
            );
          }

          widgets.add(pw.SizedBox(height: 20));

          // ------------------------------------------
          // 4. CATEGORY BREAKDOWN
          // ------------------------------------------
          if (data.filter.includeCategoryBreakdown && data.categoryTotals.isNotEmpty) {
            widgets.add(
              pw.Text(
                '3. Category-wise Spending Breakdown',
                style: pw.TextStyle(color: navy, fontSize: 13, fontWeight: pw.FontWeight.bold),
              ),
            );
            widgets.add(pw.SizedBox(height: 8));

            widgets.add(
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9),
                headerDecoration: pw.BoxDecoration(color: teal),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                headers: ['Category', 'Expense Count', 'Total Spent', '% of Total'],
                data: data.categoryTotals.entries.map((entry) {
                  final pct = data.totalExpenses > 0 ? (entry.value / data.totalExpenses) * 100 : 0.0;
                  return [
                    entry.key.toUpperCase(),
                    '${data.categoryCounts[entry.key] ?? 0}',
                    '$cur${entry.value.toStringAsFixed(0)}',
                    '${pct.toStringAsFixed(1)}%',
                  ];
                }).toList(),
              ),
            );
            widgets.add(pw.SizedBox(height: 20));
          }

          // ------------------------------------------
          // 5. PAYMENTS & CONTRIBUTIONS
          // ------------------------------------------
          if (data.filter.includePayments && data.payments.isNotEmpty) {
            widgets.add(
              pw.Text(
                '4. Recorded Payments & Settlements',
                style: pw.TextStyle(color: navy, fontSize: 13, fontWeight: pw.FontWeight.bold),
              ),
            );
            widgets.add(pw.SizedBox(height: 8));

            widgets.add(
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9),
                headerDecoration: pw.BoxDecoration(color: emerald),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                headers: ['Date', 'From (Payer)', 'To (Recipient)', 'Amount', 'Method', 'Status', 'Ref Number'],
                data: data.payments.map((p) {
                  final fromName = pMap[p.fromMemberId]?.name ?? p.fromMemberId;
                  final toName = pMap[p.toMemberId]?.name ?? p.toMemberId;
                  return [
                    shortDateFmt.format(p.paymentDate),
                    p.recordedOnBehalfOfGuest ? '$fromName (Guest)' : fromName,
                    toName,
                    '$cur${p.amount.toStringAsFixed(0)}',
                    p.paymentMethod,
                    p.paymentStatus.toUpperCase(),
                    p.referenceNumber ?? 'N/A',
                  ];
                }).toList(),
              ),
            );
            widgets.add(pw.SizedBox(height: 20));
          }

          // ------------------------------------------
          // 6. RECOMMENDED SETTLEMENT TRANSFERS
          // ------------------------------------------
          if (data.filter.includeSettlements && data.optimizedSettlements.isNotEmpty) {
            widgets.add(
              pw.Text(
                '5. Multilateral Debt Simplification Transfers',
                style: pw.TextStyle(color: navy, fontSize: 13, fontWeight: pw.FontWeight.bold),
              ),
            );
            widgets.add(pw.SizedBox(height: 8));

            widgets.add(
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9),
                headerDecoration: pw.BoxDecoration(color: amber),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                headers: ['From (Debtor)', 'To (Creditor)', 'Amount', 'Settlement Status'],
                data: data.optimizedSettlements.map((st) {
                  final from = pMap[st.fromUid];
                  final to = pMap[st.toUid];
                  return [
                    '${from?.name ?? st.fromUid} ${from?.isGuest == true ? "(Guest)" : ""}',
                    '${to?.name ?? st.toUid} ${to?.isGuest == true ? "(Guest)" : ""}',
                    '$cur${st.amount.toStringAsFixed(0)}',
                    'Pending Final Transfer',
                  ];
                }).toList(),
              ),
            );
            widgets.add(pw.SizedBox(height: 20));
          }

          // ------------------------------------------
          // 7. ADJUSTMENTS AND WRITE-OFFS
          // ------------------------------------------
          if (data.filter.includeAdjustments && data.adjustments.isNotEmpty) {
            widgets.add(
              pw.Text(
                '6. Voluntary Adjustments & Debt Write-offs',
                style: pw.TextStyle(color: navy, fontSize: 13, fontWeight: pw.FontWeight.bold),
              ),
            );
            widgets.add(pw.SizedBox(height: 8));

            widgets.add(
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9),
                headerDecoration: pw.BoxDecoration(color: coral),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                headers: ['Date', 'Type', 'Waived By', 'Beneficiary', 'Amount', 'Reason'],
                data: data.adjustments.map((adj) {
                  final cred = pMap[adj.creditorUid]?.name ?? adj.creditorUid;
                  final deb = pMap[adj.debtorUid]?.name ?? adj.debtorUid;
                  return [
                    shortDateFmt.format(adj.createdAt),
                    'DEBT WAIVER',
                    cred,
                    deb,
                    '$cur${adj.amount.toStringAsFixed(0)}',
                    adj.reason,
                  ];
                }).toList(),
              ),
            );
            widgets.add(pw.SizedBox(height: 20));
          }

          return widgets;
        },
      ),
    );

    return pdf.save();
  }
}
