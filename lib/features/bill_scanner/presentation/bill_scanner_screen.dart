import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/ai/ai_provider.dart';
import '../../../core/ai/infrastructure/gemini_ai_service.dart';
import '../../../core/theme/app_pallete.dart';
import '../../../core/utils/snackbar.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../circles/presentation/circle_controller.dart';
import '../../financial/expenses/domain/expense_model.dart';
import '../../financial/expenses/presentation/expense_controller.dart';
import '../../trips/presentation/trip_controller.dart';
import '../data/bill_scanner_service.dart';
import '../domain/bill_split_calculator.dart';
import '../domain/scanned_bill_model.dart';

final billScannerServiceProvider = Provider<BillScannerService>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return BillScannerService(
    geminiAiService: aiService is GeminiAiService ? aiService : null,
  );
});

class BillScannerScreen extends ConsumerStatefulWidget {
  final String tripId;

  const BillScannerScreen({super.key, required this.tripId});

  @override
  ConsumerState<BillScannerScreen> createState() => _BillScannerScreenState();
}

class _BillScannerScreenState extends ConsumerState<BillScannerScreen> {
  final _picker = ImagePicker();
  ScannedBill? _scannedBill;
  bool _isProcessing = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    // Default to sample restaurant bill for immediate interactive use
    _scannedBill = BillScannerService.getSampleRestaurantBill();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final photo = await _picker.pickImage(source: source, imageQuality: 85);
      if (photo == null) return;

      setState(() {
        _isProcessing = true;
        _statusMessage = 'Reading bill details with Gemini AI OCR...';
      });

      final bytes = await photo.readAsBytes();
      final scannerService = ref.read(billScannerServiceProvider);
      final bill = await scannerService.scanBillImage(imageBytes: bytes);

      if (mounted) {
        setState(() {
          _scannedBill = bill;
          _isProcessing = false;
        });
        showSnackBar(context, 'Successfully parsed: ${bill.merchantName}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        showSnackBar(context, 'Scan failed: $e');
      }
    }
  }

  void _loadSample(ScannedBill bill) {
    setState(() {
      _scannedBill = bill;
    });
    showSnackBar(context, 'Loaded sample: ${bill.merchantName}');
  }

  void _toggleMemberOnItem(ScannedBillItem item, String memberId) {
    setState(() {
      if (item.assignedMemberIds.contains(memberId)) {
        item.assignedMemberIds.remove(memberId);
      } else {
        item.assignedMemberIds.add(memberId);
      }
    });
  }

  Future<void> _saveAsExpense(BillSplitResult splitResult) async {
    if (_scannedBill == null) return;

    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      if (mounted) showSnackBar(context, 'Please log in to save expense.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Saving expense to group...';
    });

    try {
      if (!mounted) return;
      await ref.read(expenseControllerProvider.notifier).createExpense(
        tripId: widget.tripId,
        title: _scannedBill!.merchantName,
        amount: _scannedBill!.grandTotal,
        category: ExpenseCategory.food.name,
        payers: {user.uid: _scannedBill!.grandTotal},
        splitType: SplitType.exact,
        splitDetails: splitResult.memberShares,
        date: _scannedBill!.date,
        context: context,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        showSnackBar(context, 'Failed to save expense: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Split Camera'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'camera') _pickImage(ImageSource.camera);
              if (val == 'gallery') _pickImage(ImageSource.gallery);
              if (val == 'restaurant') _loadSample(BillScannerService.getSampleRestaurantBill());
              if (val == 'grocery') _loadSample(BillScannerService.getSampleGroceryBill());
              if (val == 'upi') _loadSample(BillScannerService.getSampleUpiScreenshot());
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'camera', child: Text('📷 Capture Receipt')),
              const PopupMenuItem(value: 'gallery', child: Text('🖼️ Pick from Gallery')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'restaurant', child: Text('🍽️ Sample Restaurant Bill')),
              const PopupMenuItem(value: 'grocery', child: Text('🛒 Sample Grocery Bill')),
              const PopupMenuItem(value: 'upi', child: Text('💳 Sample UPI Payment')),
            ],
          ),
        ],
      ),
      body: tripAsync.when(
        data: (trip) {
          final membersAsync = ref.watch(circleMembersProvider(trip.circleId));
          return membersAsync.when(
            data: (members) {
              final memberIds = members.map((m) => m.uid).toList();
              final memberMap = {for (var m in members) m.uid: m.displayName.isNotEmpty ? m.displayName : 'Member'};

              if (_isProcessing) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(_statusMessage, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                );
              }

              if (_scannedBill == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long, size: 70, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No bill scanned yet',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Scan Bill with Camera'),
                      ),
                    ],
                  ),
                );
              }

              final bill = _scannedBill!;
              final splitResult = BillSplitCalculator.calculate(
                bill: bill,
                allMemberIds: memberIds,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bill Banner Card
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                bill.isUpiScreenshot ? Icons.account_balance_wallet : Icons.receipt_long,
                                color: theme.colorScheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bill.merchantName,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    bill.isUpiScreenshot
                                        ? 'UPI Ref: ${bill.upiTransactionId ?? "N/A"}'
                                        : '${bill.items.length} items extracted • AI verified',
                                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${bill.grandTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Grand Total',
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Sample Switcher Chips
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.camera_alt, size: 14),
                            label: const Text('Scan Photo', style: TextStyle(fontSize: 11)),
                            onPressed: () => _pickImage(ImageSource.camera),
                          ),
                          const SizedBox(width: 8),
                          ActionChip(
                            avatar: const Icon(Icons.restaurant, size: 14),
                            label: const Text('Restaurant Bill (₹3,500)', style: TextStyle(fontSize: 11)),
                            onPressed: () => _loadSample(BillScannerService.getSampleRestaurantBill()),
                          ),
                          const SizedBox(width: 8),
                          ActionChip(
                            avatar: const Icon(Icons.shopping_cart, size: 14),
                            label: const Text('Grocery Bill (₹1,800)', style: TextStyle(fontSize: 11)),
                            onPressed: () => _loadSample(BillScannerService.getSampleGroceryBill()),
                          ),
                          const SizedBox(width: 8),
                          ActionChip(
                            avatar: const Icon(Icons.payments, size: 14),
                            label: const Text('UPI Screenshot (₹12,500)', style: TextStyle(fontSize: 11)),
                            onPressed: () => _loadSample(BillScannerService.getSampleUpiScreenshot()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section: Item-Level Splitting
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Item-Level Splitting',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Tap member to assign',
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ...bill.items.map((item) {
                      final hasCustomAssign = item.assignedMemberIds.isNotEmpty;
                      final assignedNames = hasCustomAssign
                          ? item.assignedMemberIds.map((id) => memberMap[id] ?? 'Member').join(', ')
                          : 'Everyone (${memberIds.length})';

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.quantity}x ${item.name}',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                  ),
                                  Text(
                                    '₹${item.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Shared by: $assignedNames',
                                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 8),
                              // Member selector avatars
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: members.map((member) {
                                  final isAssigned = item.assignedMemberIds.contains(member.uid) ||
                                      item.assignedMemberIds.isEmpty;

                                  return FilterChip(
                                    label: Text(
                                      member.displayName.isNotEmpty ? member.displayName : 'Member',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isAssigned ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    selected: isAssigned,
                                    visualDensity: VisualDensity.compact,
                                    selectedColor: AppPallete.primary.withValues(alpha: 0.15),
                                    checkmarkColor: AppPallete.primary,
                                    onSelected: (_) => _toggleMemberOnItem(item, member.uid),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    // Additional charges summary
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            _buildPriceRow('Items Subtotal', '₹${bill.subtotal.toStringAsFixed(2)}'),
                            if (bill.taxAmount > 0)
                              _buildPriceRow('Taxes (GST)', '₹${bill.taxAmount.toStringAsFixed(2)}'),
                            if (bill.serviceCharge > 0)
                              _buildPriceRow('Service Charge', '₹${bill.serviceCharge.toStringAsFixed(2)}'),
                            if (bill.discountAmount > 0)
                              _buildPriceRow('Discounts', '-₹${bill.discountAmount.toStringAsFixed(2)}', isDiscount: true),
                            const Divider(height: 14),
                            _buildPriceRow('Grand Total', '₹${bill.grandTotal.toStringAsFixed(2)}', isBold: true),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Live Calculated Member Shares
                    const Text(
                      'Calculated Fair Shares',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            ...splitResult.memberShares.entries.map((entry) {
                              final name = memberMap[entry.key] ?? 'Member';
                              final subtotal = splitResult.itemSubtotals[entry.key] ?? 0.0;
                              final tax = splitResult.memberTaxes[entry.key] ?? 0.0;
                              final share = entry.value;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppPallete.primary.withValues(alpha: 0.1),
                                      child: Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : 'M',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          Text(
                                            'Items: ₹${subtotal.toStringAsFixed(2)} + Tax/Fees: ₹${tax.toStringAsFixed(2)}',
                                            style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '₹${share.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      splitResult.isBalanced ? Icons.check_circle : Icons.warning,
                                      size: 16,
                                      color: splitResult.isBalanced ? Colors.green : Colors.amber,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      splitResult.isBalanced ? 'Balanced exact sum' : 'Rounding gap',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: splitResult.isBalanced ? Colors.green : Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Total: ₹${splitResult.totalCalculated.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Confirm and Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _saveAsExpense(splitResult),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text(
                          'Save as Group Expense',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading members: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading trip: $e')),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isDiscount ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}
