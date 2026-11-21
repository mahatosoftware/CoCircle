import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../circles/presentation/circle_controller.dart';
import '../../financial/expenses/presentation/expense_controller.dart';
import '../../trips/presentation/trip_controller.dart';
import '../data/budget_forecast_service.dart';
import '../domain/budget_forecast_model.dart';

class MoneyPredictorView extends ConsumerStatefulWidget {
  final String tripId;
  final String currency;

  const MoneyPredictorView({
    super.key,
    required this.tripId,
    required this.currency,
  });

  @override
  ConsumerState<MoneyPredictorView> createState() => _MoneyPredictorViewState();
}

class _MoneyPredictorViewState extends ConsumerState<MoneyPredictorView> {
  // What-if simulator state
  int _memberDelta = 0;
  double _priceChangePercent = 0.0;
  int _durationDeltaDays = 0;

  void _showAddCommitmentDialog(BuildContext context) {
    final titleController = TextEditingController();
    final costController = TextEditingController();
    String category = 'accommodation';
    bool isBooked = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Upcoming Commitment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title / Description',
                        hintText: 'e.g. Resort balance payment',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: costController,
                      decoration: InputDecoration(
                        labelText: 'Estimated Amount (${widget.currency})',
                        hintText: '15000',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(value: 'accommodation', child: Text('🏨 Accommodation')),
                        DropdownMenuItem(value: 'transport', child: Text('🚕 Transport & Flights')),
                        DropdownMenuItem(value: 'food', child: Text('🍽️ Food & Dining')),
                        DropdownMenuItem(value: 'activities', child: Text('🏄 Activities')),
                        DropdownMenuItem(value: 'misc', child: Text('📦 Miscellaneous')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Already Booked?'),
                      subtitle: const Text('Mark if advance is confirmed'),
                      value: isBooked,
                      onChanged: (val) => setDialogState(() => isBooked = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final cost = double.tryParse(costController.text.trim()) ?? 0.0;
                    if (title.isEmpty || cost <= 0) return;

                    final user = await ref.read(authRepositoryProvider).getCurrentUser();
                    if (user == null) return;

                    final commitment = BudgetCommitment(
                      id: const Uuid().v4(),
                      tripId: widget.tripId,
                      title: title,
                      category: category,
                      estimatedCost: cost,
                      isBooked: isBooked,
                      createdBy: user.uid,
                      createdAt: DateTime.now(),
                    );

                    await ref
                        .read(budgetForecastServiceProvider)
                        .addCommitment(commitment);

                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSetBudgetDialog(BuildContext context, double currentBudget) {
    final controller = TextEditingController(text: currentBudget.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Set Total Group Budget'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Target Budget (${widget.currency})',
              hintText: '80000',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final budget = double.tryParse(controller.text.trim()) ?? 0.0;
                if (budget > 0) {
                  await ref
                      .read(budgetForecastServiceProvider)
                      .updateTargetBudget(widget.tripId, budget);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final expensesAsync = ref.watch(tripExpensesProvider(widget.tripId));
    final commitmentsAsync = ref.watch(tripCommitmentsProvider(widget.tripId));
    final theme = Theme.of(context);

    return tripAsync.when(
      data: (trip) {
        final membersAsync = ref.watch(circleMembersProvider(trip.circleId));
        return membersAsync.when(
          data: (members) {
            final expenses = expensesAsync.value ?? [];
            final commitments = commitmentsAsync.value ?? [];

            final forecastService = ref.read(budgetForecastServiceProvider);
            final forecast = forecastService.calculateForecast(
              targetBudget: 0.0, // Calculated dynamically or from trip target
              expenses: expenses,
              commitments: commitments,
              memberCount: members.length,
            );

            final simulation = forecastService.runWhatIfSimulation(
              currentProjectedSpend: forecast.projectedFinalSpend,
              currentMembers: members.length,
              memberDelta: _memberDelta,
              priceChangePercent: _priceChangePercent,
              durationDeltaDays: _durationDeltaDays,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Dashboard Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: forecast.isOverBudget
                            ? Colors.red.withValues(alpha: 0.4)
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Group Money Predictor',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    'Forecasted final spend: ${widget.currency} ${forecast.projectedFinalSpend.toStringAsFixed(0)}',
                                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                tooltip: 'Edit Target Budget',
                                onPressed: () => _showSetBudgetDialog(context, forecast.totalBudget),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 4 Financial Metrics
                          Row(
                            children: [
                              _buildMetricItem(
                                'Total Budget',
                                '${widget.currency} ${forecast.totalBudget.toStringAsFixed(0)}',
                                Colors.indigo,
                              ),
                              _buildMetricItem(
                                'Spent so far',
                                '${widget.currency} ${forecast.actualSpent.toStringAsFixed(0)}',
                                Colors.blue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildMetricItem(
                                'Committed',
                                '${widget.currency} ${forecast.committedTotal.toStringAsFixed(0)}',
                                Colors.orange,
                              ),
                              _buildMetricItem(
                                'Available',
                                '${widget.currency} ${forecast.availableBudget.toStringAsFixed(0)}',
                                forecast.availableBudget >= 0 ? Colors.green : Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Segmented Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 10,
                              child: Row(
                                children: [
                                  if (forecast.spentPercentage > 0)
                                    Flexible(
                                      flex: forecast.spentPercentage.toInt().clamp(1, 100),
                                      child: Container(color: Colors.blue),
                                    ),
                                  if (forecast.committedPercentage > 0)
                                    Flexible(
                                      flex: forecast.committedPercentage.toInt().clamp(1, 100),
                                      child: Container(color: Colors.orange),
                                    ),
                                  Flexible(
                                    flex: (100 - forecast.spentPercentage - forecast.committedPercentage)
                                        .toInt()
                                        .clamp(0, 100),
                                    child: Container(
                                      color: forecast.isOverBudget
                                          ? Colors.red
                                          : Colors.grey.withValues(alpha: 0.2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Spent: ${forecast.spentPercentage.toStringAsFixed(0)}% • Committed: ${forecast.committedPercentage.toStringAsFixed(0)}%',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              Text(
                                forecast.isOverBudget
                                    ? '⚠️ Over by ${widget.currency} ${forecast.overrunAmount.toStringAsFixed(0)}'
                                    : '✓ Within Budget',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: forecast.isOverBudget ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Anomalies / Alerts Card
                  if (forecast.anomalies.isNotEmpty) ...[
                    Card(
                      elevation: 0,
                      color: Colors.amber.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Budget Intelligence Alerts',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...forecast.anomalies.map((a) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text('• $a', style: const TextStyle(fontSize: 12)),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // What-If Scenario Simulator Section
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.teal.withValues(alpha: 0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.tune, color: Colors.teal, size: 20),
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'What-If Scenario Simulator',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    'Simulate cancellations, inflation & extra days',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Slider 1: Members Change
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Member Cancellations / Additions:', style: TextStyle(fontSize: 12)),
                              Text(
                                _memberDelta == 0
                                    ? 'No change (${members.length})'
                                    : '${_memberDelta > 0 ? "+" : ""}$_memberDelta members',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                          Slider(
                            value: _memberDelta.toDouble(),
                            min: -3,
                            max: 3,
                            divisions: 6,
                            activeColor: Colors.teal,
                            onChanged: (val) => setState(() => _memberDelta = val.round()),
                          ),

                          // Slider 2: Price Inflation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Price Fluctuation / Inflation:', style: TextStyle(fontSize: 12)),
                              Text(
                                '${_priceChangePercent > 0 ? "+" : ""}${_priceChangePercent.toStringAsFixed(0)}%',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                          Slider(
                            value: _priceChangePercent,
                            min: -20,
                            max: 30,
                            divisions: 10,
                            activeColor: Colors.teal,
                            onChanged: (val) => setState(() => _priceChangePercent = val),
                          ),

                          // Slider 3: Duration Change
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Trip Duration Days:', style: TextStyle(fontSize: 12)),
                              Text(
                                '${_durationDeltaDays > 0 ? "+" : ""}$_durationDeltaDays days',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                          Slider(
                            value: _durationDeltaDays.toDouble(),
                            min: -2,
                            max: 3,
                            divisions: 5,
                            activeColor: Colors.teal,
                            onChanged: (val) => setState(() => _durationDeltaDays = val.round()),
                          ),

                          const SizedBox(height: 8),

                          // Simulation Result Box
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Simulated Per Person:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    Text(
                                      '${widget.currency} ${simulation.simulatedPerPerson.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Simulated Group Total:', style: TextStyle(fontSize: 12)),
                                    Text(
                                      '${widget.currency} ${simulation.simulatedTotal.toStringAsFixed(0)} (${simulation.deltaPerPerson >= 0 ? "+" : ""}${widget.currency} ${simulation.deltaPerPerson.toStringAsFixed(0)}/person)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: simulation.deltaPerPerson > 0 ? Colors.red : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 12),
                                Text(
                                  '💡 ${simulation.insight}',
                                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Upcoming Commitments Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Upcoming Commitments',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddCommitmentDialog(context),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Commitment'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (commitments.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'No upcoming commitments added yet.\nAdd booked hotels, cabs, or pending payments to forecast final spend.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    )
                  else
                    ...commitments.map((c) {
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: c.isBooked
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            child: Icon(
                              c.isBooked ? Icons.check_circle_outline : Icons.schedule,
                              color: c.isBooked ? Colors.green : Colors.orange,
                              size: 20,
                            ),
                          ),
                          title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text(
                            '${c.category.toUpperCase()} • ${c.isBooked ? "Booked" : "Estimate"}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.currency} ${c.estimatedCost.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                                onPressed: () {
                                  ref
                                      .read(budgetForecastServiceProvider)
                                      .deleteCommitment(widget.tripId, c.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}
