import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cocircle/features/auth/data/auth_repository_impl.dart';
import 'package:cocircle/features/auth/domain/user_model.dart';
import '../../../../core/theme/app_pallete.dart';
import 'package:cocircle/features/circles/presentation/circle_controller.dart';
import 'package:cocircle/features/trips/presentation/trip_controller.dart';
import '../domain/expense_model.dart';
import 'expense_controller.dart';
import 'package:cocircle/l10n/app_localizations.dart';
import '../../../../core/widgets/copyright_footer.dart';

class CreateExpenseScreen extends ConsumerStatefulWidget {
  final String tripId;
  final ExpenseModel? expense;
  const CreateExpenseScreen({super.key, required this.tripId, this.expense});

  @override
  ConsumerState<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends ConsumerState<CreateExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  Map<String, double> _payerAmounts = {};
  Map<String, TextEditingController> _payerControllers = {};
  
  SplitType _selectedSplitType = SplitType.equal;
  Map<String, double> _splitValues = {};
  Map<String, TextEditingController> _splitControllers = {};
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _selectedCategory = ExpenseCategory.values.firstWhere(
        (c) => c.name == widget.expense!.category,
        orElse: () => ExpenseCategory.food,
      );
      _selectedDate = widget.expense!.date;
      _payerAmounts = Map.from(widget.expense!.payers);
      for (var entry in _payerAmounts.entries) {
        _payerControllers[entry.key] = TextEditingController(text: entry.value.toString());
      }
      _selectedSplitType = widget.expense!.splitType;
      _splitValues = Map.from(widget.expense!.splitDetails);
      for (var entry in _splitValues.entries) {
        _splitControllers[entry.key] = TextEditingController(text: entry.value.toString());
      }
    } else {
      // Default primary payer is current user
      ref.read(authRepositoryProvider).getCurrentUser().then((user) {
        if (user != null && mounted) {
          setState(() {
            _payerAmounts[user.uid] = 0.0;
            _payerControllers[user.uid] = TextEditingController(text: '');
            _updatePayerDefaults();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    for (var controller in _payerControllers.values) {
      controller.dispose();
    }
    for (var controller in _splitControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      if (user == null) return;

      final amount = double.parse(_amountController.text);
      
      // Update _payerAmounts from controllers
      _payerControllers.forEach((uid, controller) {
        if (_payerAmounts.containsKey(uid)) {
          _payerAmounts[uid] = double.tryParse(controller.text) ?? 0.0;
        }
      });

      // Update _splitValues from controllers
      _splitControllers.forEach((uid, controller) {
        if (_splitValues.containsKey(uid)) {
          _splitValues[uid] = double.tryParse(controller.text) ?? 0.0;
        }
      });

      // Validation: Total payer amounts must equal total amount
      final totalPaid = _payerAmounts.values.fold(0.0, (sum, val) => sum + val);
      if ((totalPaid - amount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.totalPaidError(totalPaid, amount))),
        );
        return;
      }

      // Validation: Split amounts if not equal
      if (_selectedSplitType != SplitType.equal) {
        final totalSplit = _splitValues.values.fold(0.0, (sum, val) => sum + val);
        if (_selectedSplitType == SplitType.exact && (totalSplit - amount).abs() > 0.01) {
          _showError(AppLocalizations.of(context)!.totalSplitError(totalSplit, amount));
          return;
        }
        if (_selectedSplitType == SplitType.percentage && (totalSplit - 100).abs() > 0.01) {
          _showError(AppLocalizations.of(context)!.percentageSumError(totalSplit));
          return;
        }
      }

      if (widget.expense != null) {
        // Edit mode
        ref.read(expenseControllerProvider.notifier).updateExpense(
          expenseId: widget.expense!.id,
          tripId: widget.tripId,
          title: _titleController.text.trim(),
          amount: amount,
          date: _selectedDate,
          category: _selectedCategory.name,
          payers: _payerAmounts,
          splitDetails: _splitValues,
          splitType: _selectedSplitType,
          notes: widget.expense!.notes,
          context: context,
        );
      } else {
        // Create mode
        ref.read(expenseControllerProvider.notifier).createExpense(
          tripId: widget.tripId,
          title: _titleController.text.trim(),
          amount: amount,
          date: _selectedDate,
          category: _selectedCategory.name,
          payers: _payerAmounts,
          splitDetails: _splitValues,
          splitType: _selectedSplitType, 
          context: context,
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _triggerAutoSave();
    }
  }

  void _triggerAutoSave() {
    if (widget.expense == null) return; // Only auto-save in edit mode

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    // Collect current values
    final payers = Map<String, double>.from(_payerAmounts);
    _payerControllers.forEach((uid, controller) {
      if (payers.containsKey(uid)) {
        payers[uid] = double.tryParse(controller.text) ?? 0.0;
      }
    });

    final splitDetails = Map<String, double>.from(_splitValues);
    _splitControllers.forEach((uid, controller) {
      if (splitDetails.containsKey(uid)) {
        splitDetails[uid] = double.tryParse(controller.text) ?? 0.0;
      }
    });

    final expense = widget.expense!.copyWith(
      title: _titleController.text.trim(),
      amount: amount,
      category: _selectedCategory.name,
      payers: payers,
      splitDetails: splitDetails,
      splitType: _selectedSplitType,
    );

    ref.read(expenseControllerProvider.notifier).autoSaveExpense(expense);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(expenseControllerProvider).isLoading;
    // Fetch trip to get circleId, then fetch circle to get currency
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.expense != null ? l10n.editExpense : l10n.addExpense)),
      body: tripAsync.when(
        data: (trip) {
          final circleAsync = ref.watch(circleDetailsProvider(trip.circleId));
          return circleAsync.when(
            data: (circle) => _buildForm(context, isLoading, circle.currency),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.loadCircleError(e.toString()))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.loadTripError(e.toString()))),
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isLoading, String currency) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: l10n.expenseTitleLabel),
                  validator: (val) => val == null || val.isEmpty ? l10n.enterTitleError : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    prefixText: '$currency ', 
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  validator: (val) {
                    if (val == null || val.isEmpty) return l10n.enterAmountError;
                    if (double.tryParse(val) == null) return l10n.invalidAmountError;
                    return null;
                  },
                  onChanged: (_) {
                    setState(() {});
                    _updatePayerDefaults();
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ExpenseCategory>(
                  value: _selectedCategory,
                  decoration: InputDecoration(labelText: l10n.category),
                  items: ExpenseCategory.values
                      .where((c) => c != ExpenseCategory.settlement)
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Row(
                              children: [
                                Icon(_getCategoryIcon(c), size: 18, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(c.name.toUpperCase()),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.date,
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat.yMMMd().format(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildPayerSection(context, currency),
                const SizedBox(height: 24),
                _buildSplitSection(context, currency),
                const SizedBox(height: 32),
                 SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : Text(widget.expense != null ? l10n.updateExpenseButton : l10n.saveExpenseButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildPayerSection(BuildContext context, String currency) {
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final l10n = AppLocalizations.of(context)!;
    return tripAsync.when(
      data: (trip) {
        final membersAsync = ref.watch(circleMembersProvider(trip.circleId));
        return membersAsync.when(
          data: (members) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(l10n.paidBy, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              _buildPayerSelector(context, members),
              const SizedBox(height: 16),
              ..._buildPayerInputs(context, currency, members),
            ],
          ),
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text(l10n.loadMembersError(e.toString())),
        );
      },
      loading: () => const LinearProgressIndicator(),
       error: (e, _) => Text(l10n.errorWithDetails(e.toString())),
    );
  }

  Widget _buildPayerSelector(BuildContext context, List<UserModel> members) {
    final selectedCount = _payerAmounts.length;
    final label = selectedCount == 0 
        ? AppLocalizations.of(context)!.selectPayers 
        : AppLocalizations.of(context)!.payersSelectedCount(selectedCount);
    
    return InkWell(
      onTap: () => _showPayerDialog(members),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.payment, color: AppPallete.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showPayerDialog(List<UserModel> members) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.selectPayers),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: members.map((member) {
                    final isSelected = _payerAmounts.containsKey(member.uid);
                    return CheckboxListTile(
                      title: Text(member.displayName),
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _payerAmounts[member.uid] = 0.0;
                            _payerControllers[member.uid] = TextEditingController();
                          } else {
                            if (_payerAmounts.length > 1) { // At least one payer
                              _payerAmounts.remove(member.uid);
                              _payerControllers[member.uid]?.dispose();
                              _payerControllers.remove(member.uid);
                            }
                          }
                          _updatePayerDefaults();
                        });
                        setDialogState(() {}); // Refresh dialog UI
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.expense != null) _triggerAutoSave();
                  },
                  child: Text(l10n.done),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _buildPayerInputs(BuildContext context, String currency, List<UserModel> members) {
     final activePayers = members.where((m) => _payerAmounts.containsKey(m.uid)).toList();
     return activePayers.map((member) {
       return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(member.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _payerControllers[member.uid],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.amountPaid,
                    prefixText: '$currency ',
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    final l10n = AppLocalizations.of(context)!;
                    if (val == null || val.isEmpty) return l10n.requiredError;
                    if (double.tryParse(val) == null) return l10n.invalidError;
                    return null;
                  },
                ),
              ),
            ],
          ),
        );
     }).toList();
  }

  Widget _buildSplitSection(BuildContext context, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<SplitType>(
            segments: SplitType.values.map((s) => ButtonSegment<SplitType>(
              value: s,
              label: Text(_getSplitTitle(s, context)),
            )).toList(),
            selected: {_selectedSplitType},
            onSelectionChanged: (Set<SplitType> newSelection) {
              setState(() {
                _selectedSplitType = newSelection.first;
                // Clear inputs when type changes to avoid confusion (Amount vs % vs Share)
                for (var controller in _splitControllers.values) {
                  controller.clear();
                }
              });
              if (widget.expense != null) _triggerAutoSave();
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.splitBetween, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildParticipantSelector(context),
        const SizedBox(height: 16),
        _buildSplitInputs(context, currency),
      ],
    );
  }

  Widget _buildParticipantSelector(BuildContext context) {
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    return tripAsync.when(
      data: (trip) {
        final membersAsync = ref.watch(circleMembersProvider(trip.circleId));
        return membersAsync.when(
          data: (members) {
            final selectedCount = _splitValues.length;
            final label = selectedCount == 0 
                ? AppLocalizations.of(context)!.selectParticipants 
                : AppLocalizations.of(context)!.participantsSelectedCount(selectedCount);
            
            return InkWell(
              onTap: () => _showParticipantDialog(members),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: AppPallete.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text(AppLocalizations.of(context)!.loadMembersError(e.toString())),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(AppLocalizations.of(context)!.errorWithDetails(e.toString())),
    );
  }

  void _showParticipantDialog(List<UserModel> members) {
     showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.selectParticipants),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: members.map((member) {
                    final isSelected = _splitValues.containsKey(member.uid);
                    return CheckboxListTile(
                      title: Text(member.displayName),
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _splitValues[member.uid] = 0.0;
                            _splitControllers[member.uid] = TextEditingController();
                          } else {
                            _splitValues.remove(member.uid);
                            _splitControllers[member.uid]?.dispose();
                            _splitControllers.remove(member.uid);
                          }
                        });
                        setDialogState(() {}); // Refresh dialog UI
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.expense != null) _triggerAutoSave();
                  },
                  child: Text(AppLocalizations.of(context)!.done),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSplitInputs(BuildContext context, String currency) {
    if (_splitValues.isEmpty) {
      return Text(AppLocalizations.of(context)!.noParticipantsSelected, 
          style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    if (_selectedSplitType == SplitType.equal) {
       final totalAmount = double.tryParse(_amountController.text) ?? 0.0;
       final share = _splitValues.isEmpty ? 0.0 : totalAmount / _splitValues.length;
       
       return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(AppLocalizations.of(context)!.dividedEquallyDescription, 
                style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
           const SizedBox(height: 8),
           ..._splitValues.keys.map((uid) {
             final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
             final circleId = tripAsync.value?.circleId;
             if (circleId == null) return const SizedBox.shrink();
             
             final membersAsync = ref.watch(circleMembersProvider(circleId));
             return membersAsync.when(
               data: (members) {
                 final member = members.firstWhere((m) => m.uid == uid);
                 return Padding(
                   padding: const EdgeInsets.symmetric(vertical: 4),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(member.displayName),
                       Text('$currency ${share.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                     ],
                   ),
                 );
               },
               loading: () => const SizedBox.shrink(),
               error: (_, __) => const SizedBox.shrink(),
             );
           }),
         ],
       );
    }

    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    return tripAsync.when(
      data: (trip) {
        final membersAsync = ref.watch(circleMembersProvider(trip.circleId));
        return membersAsync.when(
          data: (members) {
            final activeParticipants = members.where((m) => _splitValues.containsKey(m.uid)).toList();
            final totalAmount = double.tryParse(_amountController.text) ?? 0.0;
            
            double totalRatio = 0;
            if (_selectedSplitType == SplitType.ratio) {
              for (var uid in _splitValues.keys) {
                totalRatio += double.tryParse(_splitControllers[uid]?.text ?? '0') ?? 0.0;
              }
            }

            return Column(
              children: activeParticipants.map((member) {
                final inputValue = double.tryParse(_splitControllers[member.uid]?.text ?? '0') ?? 0.0;
                double computedAmount = 0;
                
                if (_selectedSplitType == SplitType.percentage) {
                  computedAmount = (inputValue / 100) * totalAmount;
                } else if (_selectedSplitType == SplitType.ratio) {
                  computedAmount = totalRatio > 0 ? (inputValue / totalRatio) * totalAmount : 0;
                }

                return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(member.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _splitControllers[member.uid],
                            decoration: InputDecoration(
                              labelText: _getSplitLabel(_selectedSplitType, context),
                              prefixText: _selectedSplitType == SplitType.exact ? '$currency ' : null,
                              suffixText: _selectedSplitType == SplitType.percentage ? '%' : null,
                              helperText: (_selectedSplitType == SplitType.percentage || _selectedSplitType == SplitType.ratio) 
                                  ? AppLocalizations.of(context)!.amountLabelWithCurrency(currency, computedAmount.toStringAsFixed(2))
                                  : null,
                              isDense: true,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => setState(() {}),
                            validator: (val) {
                              if (val == null || val.isEmpty) return AppLocalizations.of(context)!.requiredError;
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  );
              }).toList(),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Text(AppLocalizations.of(context)!.errorWithDetails(e.toString())),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text(AppLocalizations.of(context)!.errorWithDetails(e.toString())),
    );
  }

  String _getSplitLabel(SplitType type, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case SplitType.exact: return l10n.amount;
      case SplitType.percentage: return l10n.percent;
      case SplitType.ratio: return l10n.share;
      case SplitType.equal: return '';
    }
  }

  String _getSplitTitle(SplitType type, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case SplitType.exact: return l10n.splitTypeExact;
      case SplitType.percentage: return l10n.splitTypePercentage;
      case SplitType.ratio: return l10n.splitTypeRatio;
      case SplitType.equal: return l10n.splitTypeEqual;
    }
  }

  void _updatePayerDefaults() {
    if (_payerAmounts.length == 1) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final uid = _payerAmounts.keys.first;
      _payerAmounts[uid] = amount;
      // If amount is 0, we can leave it empty or set to 0. Let's set it if not empty.
      if (amount > 0) {
        _payerControllers[uid]?.text = amount.toStringAsFixed(2);
      }
    }
  }

  void _distributeEqually(double totalAmount) {
    if (_payerAmounts.isEmpty) return;
    final share = totalAmount / _payerAmounts.length;
    setState(() {
      for (var uid in _payerAmounts.keys) {
        _payerAmounts[uid] = share;
        _payerControllers[uid]?.text = share.toStringAsFixed(2);
      }
    });
    if (widget.expense != null) _triggerAutoSave();
  }
  
  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food: return Icons.restaurant;
      case ExpenseCategory.travel: return Icons.flight;
      case ExpenseCategory.stay: return Icons.hotel;
      case ExpenseCategory.shopping: return Icons.shopping_bag;
      case ExpenseCategory.fuel: return Icons.local_gas_station;
      case ExpenseCategory.misc: return Icons.receipt;
      case ExpenseCategory.settlement: return Icons.handshake;
    }
  }
}
