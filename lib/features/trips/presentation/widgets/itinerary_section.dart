import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/itinerary_item_model.dart';
import '../../domain/trip_model.dart';
import '../trip_controller.dart';
import '../trip_planner_controller.dart';

class ItinerarySection extends ConsumerStatefulWidget {
  final String tripId;
  const ItinerarySection({super.key, required this.tripId});

  @override
  ConsumerState<ItinerarySection> createState() => _ItinerarySectionState();
}

class _ItinerarySectionState extends ConsumerState<ItinerarySection> {
  // Map types to display icons and colors
  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'travel':
        return Icons.flight_takeoff_rounded;
      case 'lodging':
        return Icons.hotel_rounded;
      case 'dining':
        return Icons.restaurant_rounded;
      case 'sightseeing':
        return Icons.museum_rounded;
      default:
        return Icons.explore_outlined;
    }
  }

  Color _getTypeColor(BuildContext context, String type) {
    final primary = Theme.of(context).colorScheme.primary;
    switch (type) {
      case 'travel':
        return Colors.blue;
      case 'lodging':
        return Colors.orange;
      case 'dining':
        return Colors.redAccent;
      case 'sightseeing':
        return Colors.teal;
      default:
        return primary;
    }
  }

  void _showAiItineraryBottomSheet(BuildContext screenContext, TripModel trip) {
    final destinationController = TextEditingController(
      text: (trip.location != null && trip.location!.isNotEmpty)
          ? trip.location
          : trip.name,
    );
    DateTime selectedDate = trip.startDate ?? DateTime.now();
    int numberOfDays = 3;
    if (trip.startDate != null && trip.endDate != null) {
      final diff = trip.endDate!.difference(trip.startDate!).inDays + 1;
      if (diff > 0 && diff <= 14) {
        numberOfDays = diff;
      }
    }
    String selectedVibe = 'balanced';

    showModalBottomSheet(
      context: screenContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            const vibes = [
              _VibeOption('balanced', 'Balanced', Icons.tune_rounded),
              _VibeOption('adventure', 'Adventure', Icons.terrain_rounded),
              _VibeOption('relaxing', 'Relaxed', Icons.spa_rounded),
              _VibeOption('foodie', 'Foodie', Icons.restaurant_rounded),
              _VibeOption('cultural', 'Culture', Icons.museum_rounded),
            ];
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            height: 4,
                            width: 40,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primary,
                                const Color(0xFF9474D2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .18),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Plan it in a moment',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Tell us the essentials. We’ll shape the days around your pace.',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'WHERE ARE YOU GOING?',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: destinationController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: 'City or destination',
                            prefixIcon: Icon(
                              Icons.location_on_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: .45),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'WHEN & HOW LONG?',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _PlannerDetailCard(
                                icon: Icons.calendar_month_rounded,
                                label: 'START DATE',
                                value: DateFormat.MMMd().format(selectedDate),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: screenContext,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now().subtract(
                                      const Duration(days: 30),
                                    ),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 730),
                                    ),
                                  );
                                  if (picked != null) {
                                    setModalState(() => selectedDate = picked);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _PlannerDetailCard(
                                icon: Icons.nights_stay_rounded,
                                label: 'DURATION',
                                value:
                                    '$numberOfDays ${numberOfDays == 1 ? 'day' : 'days'}',
                                onTap: () => _showDurationPicker(
                                  context,
                                  numberOfDays,
                                  (value) =>
                                      setModalState(() => numberOfDays = value),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'WHAT’S THE MOOD?',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: vibes.map((vibe) {
                            final selected = selectedVibe == vibe.value;
                            return ChoiceChip(
                              avatar: Icon(
                                vibe.icon,
                                size: 17,
                                color: selected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.primary,
                              ),
                              label: Text(vibe.label),
                              selected: selected,
                              showCheckmark: false,
                              selectedColor: theme.colorScheme.primary,
                              backgroundColor: theme
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: .45),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                              ),
                              side: BorderSide(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (_) => setModalState(
                                () => selectedVibe = vibe.value,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: .55),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_outlined,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'You’ll get a flexible, day-by-day plan you can edit anytime.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.35,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: () {
                              if (destinationController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Add a destination to continue',
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.pop(bottomSheetContext);
                              ref
                                  .read(tripPlannerControllerProvider.notifier)
                                  .generateAiItinerary(
                                    tripId: widget.tripId,
                                    destination: destinationController.text
                                        .trim(),
                                    startDate: selectedDate,
                                    numberOfDays: numberOfDays,
                                    vibe: selectedVibe,
                                    context: context,
                                  );
                            },
                            icon: const Icon(Icons.auto_awesome_rounded),
                            label: const Text(
                              'Create my itinerary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDurationPicker(
    BuildContext context,
    int currentValue,
    ValueChanged<int> onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How many days?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose the pace that fits this trip.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(10, (index) {
                  final days = index + 1;
                  return ChoiceChip(
                    label: Text('$days ${days == 1 ? 'day' : 'days'}'),
                    selected: currentValue == days,
                    onSelected: (_) {
                      onChanged(days);
                      Navigator.pop(context);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itineraryAsync = ref.watch(tripItineraryProvider(widget.tripId));
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final plannerState = ref.watch(tripPlannerControllerProvider);
    final theme = Theme.of(context);

    final trip = tripAsync.value;

    return Scaffold(
      body: Stack(
        children: [
          itineraryAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 56,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No activities planned yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Let AI generate a customized day-by-day itinerary or add activities manually.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        if (trip != null) ...[
                          SizedBox(
                            width: 240,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 3,
                              ),
                              onPressed: plannerState.isLoading
                                  ? null
                                  : () => _showAiItineraryBottomSheet(
                                      context,
                                      trip,
                                    ),
                              icon: const Icon(
                                Icons.auto_awesome_rounded,
                                size: 20,
                              ),
                              label: const Text(
                                'Generate with AI',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          width: 240,
                          height: 44,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: plannerState.isLoading
                                ? null
                                : () => _showAddActivityBottomSheet(context),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add Manually'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Group items by day
              final grouped = <String, List<ItineraryItemModel>>{};
              for (final item in items) {
                final key = DateFormat('yyyy-MM-dd').format(item.startTime);
                grouped.putIfAbsent(key, () => []).add(item);
              }

              final sortedDates = grouped.keys.toList()..sort();

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  final dateStr = sortedDates[index];
                  final dayItems = grouped[dateStr]!;
                  final parsedDate = DateTime.parse(dateStr);

                  // Calculate "Day X" label if trip start date is available
                  String dayLabel = DateFormat.yMMMMd().format(parsedDate);
                  if (trip != null && trip.startDate != null) {
                    final diff =
                        parsedDate.difference(trip.startDate!).inDays + 1;
                    if (diff >= 1) {
                      dayLabel =
                          'Day $diff - ${DateFormat.E().format(parsedDate)}, ${DateFormat.MMMd().format(parsedDate)}';
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        child: Text(
                          dayLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      ...dayItems.map(
                        (item) => _buildActivityCard(context, item),
                      ),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
          ),
          if (plannerState.isLoading)
            Positioned.fill(
              child: ColoredBox(
                color: theme.colorScheme.surface.withValues(alpha: .9),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 42,
                          width: 42,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Creating your itinerary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Finding a great flow for each day…',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trip != null) ...[
            FloatingActionButton.extended(
              heroTag: 'ai_itinerary_fab',
              onPressed: plannerState.isLoading
                  ? null
                  : () => _showAiItineraryBottomSheet(context, trip),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('AI Plan'),
            ),
            const SizedBox(width: 12),
          ],
          FloatingActionButton(
            heroTag: 'add_activity_fab',
            onPressed: plannerState.isLoading
                ? null
                : () => _showAddActivityBottomSheet(context),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, ItineraryItemModel item) {
    final theme = Theme.of(context);
    final typeIcon = _getTypeIcon(item.type);
    final typeColor = _getTypeColor(context, item.type);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showAddActivityBottomSheet(context, existingItem: item),
        child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon indicator
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(typeIcon, color: typeColor, size: 24),
            ),
            const SizedBox(width: 12),
            // Title & details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        item.hasStartTime
                            ? (item.endTime != null
                                ? '${DateFormat.jm().format(item.startTime)} - ${DateFormat.jm().format(item.endTime!)}'
                                : DateFormat.jm().format(item.startTime))
                            : (item.endTime != null
                                ? 'Until ${DateFormat.jm().format(item.endTime!)}'
                                : 'Flexible'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: item.hasStartTime
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  if (item.location != null && item.location!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.8,
                        ),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (item.cost != null && item.cost! > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Est. Cost: \$${item.cost!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Edit & Delete buttons
            IconButton(
              onPressed: () => _showAddActivityBottomSheet(context, existingItem: item),
              icon: Icon(
                Icons.edit_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              tooltip: 'Edit Activity',
            ),
            IconButton(
              onPressed: () => _confirmDelete(context, item),
              icon: Icon(
                Icons.delete_outline_rounded,
                color: theme.colorScheme.error,
                size: 20,
              ),
              tooltip: 'Delete Activity',
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ItineraryItemModel item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(tripPlannerControllerProvider.notifier)
                  .deleteItineraryItem(itemId: item.id, context: context);
              Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddActivityBottomSheet(BuildContext context, {ItineraryItemModel? existingItem}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return _ActivityForm(
              tripId: widget.tripId,
              scrollController: scrollController,
              existingItem: existingItem,
            );
          },
        );
      },
    );
  }
}

class _VibeOption {
  const _VibeOption(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;
}

class _PlannerDetailCard extends StatelessWidget {
  const _PlannerDetailCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .45),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .7,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityForm extends ConsumerStatefulWidget {
  final String tripId;
  final ScrollController scrollController;
  final ItineraryItemModel? existingItem;

  const _ActivityForm({
    required this.tripId,
    required this.scrollController,
    this.existingItem,
  });

  @override
  ConsumerState<_ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends ConsumerState<_ActivityForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;
  late final TextEditingController _costController;

  late String _selectedType;
  late DateTime _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  final List<Map<String, String>> _types = [
    {'value': 'general', 'label': 'General / Other'},
    {'value': 'travel', 'label': 'Travel / Flight'},
    {'value': 'lodging', 'label': 'Lodging stay'},
    {'value': 'dining', 'label': 'Dining / Restaurant'},
    {'value': 'sightseeing', 'label': 'Sightseeing'},
    {'value': 'fuel', 'label': 'Fuel / EV Charging'},
    {'value': 'adventure', 'label': 'Adventure'},
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _locationController = TextEditingController(text: item?.location ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');
    _costController = TextEditingController(
      text: item?.cost != null && item!.cost! > 0 ? item.cost!.toStringAsFixed(0) : '',
    );
    _selectedType = item?.type ?? 'general';
    _selectedDate = item?.startTime ?? DateTime.now();
    _selectedStartTime = (item != null && item.hasStartTime)
        ? TimeOfDay.fromDateTime(item.startTime)
        : (item != null ? null : const TimeOfDay(hour: 9, minute: 0));
    _selectedEndTime = item?.endTime != null
        ? TimeOfDay.fromDateTime(item!.endTime!)
        : null;

    if (item == null) {
      // Default form date to trip start date if available
      ref.read(tripDetailsProvider(widget.tripId)).whenData((trip) {
        if (trip.startDate != null) {
          setState(() {
            _selectedDate = trip.startDate!;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final bool hasStartTime = _selectedStartTime != null;
      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedStartTime?.hour ?? 10,
        _selectedStartTime?.minute ?? 0,
      );

      final combinedEndTime = _selectedEndTime != null
          ? DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _selectedEndTime!.hour,
              _selectedEndTime!.minute,
            )
          : null;

      final cost = double.tryParse(_costController.text.trim());

      if (widget.existingItem != null) {
        final updated = widget.existingItem!.copyWith(
          title: _titleController.text.trim(),
          type: _selectedType,
          startTime: combinedDateTime,
          endTime: combinedEndTime,
          clearEndTime: combinedEndTime == null,
          hasStartTime: hasStartTime,
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          cost: cost,
        );
        ref
            .read(tripPlannerControllerProvider.notifier)
            .updateItineraryItem(item: updated, context: context);
        Navigator.pop(context);
      } else {
        ref
            .read(tripPlannerControllerProvider.notifier)
            .createItineraryItem(
              tripId: widget.tripId,
              title: _titleController.text.trim(),
              type: _selectedType,
              startTime: combinedDateTime,
              endTime: combinedEndTime,
              hasStartTime: hasStartTime,
              location: _locationController.text.trim().isEmpty
                  ? null
                  : _locationController.text.trim(),
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
              cost: cost,
              context: context,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: widget.scrollController,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Activity' : 'Add Activity',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Activity Title *',
                hintText: 'e.g. Flight to Paris, Dinner at Chez Paul',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Activity Type',
                border: OutlineInputBorder(),
              ),
              items: _types
                  .map(
                    (t) => DropdownMenuItem(
                      value: t['value'],
                      child: Text(t['label']!),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedType = v);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(DateFormat.yMMMd().format(_selectedDate), style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedStartTime ?? const TimeOfDay(hour: 9, minute: 0),
                      );
                      if (picked != null) {
                        setState(() => _selectedStartTime = picked);
                      }
                    },
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedStartTime != null
                                ? 'Start: ${_selectedStartTime!.format(context)}'
                                : 'Start: Flexible',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        if (_selectedStartTime != null)
                          GestureDetector(
                            onTap: () => setState(() => _selectedStartTime = null),
                            child: const Icon(Icons.close, size: 14),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedEndTime ??
                            (_selectedStartTime != null
                                ? TimeOfDay(
                                    hour: (_selectedStartTime!.hour + 1) % 24,
                                    minute: _selectedStartTime!.minute,
                                  )
                                : const TimeOfDay(hour: 12, minute: 0)),
                      );
                      if (picked != null) {
                        setState(() => _selectedEndTime = picked);
                      }
                    },
                    icon: const Icon(Icons.access_time_filled, size: 16),
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedEndTime != null
                                ? 'End: ${_selectedEndTime!.format(context)}'
                                : 'End: None',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        if (_selectedEndTime != null)
                          GestureDetector(
                            onTap: () => setState(() => _selectedEndTime = null),
                            child: const Icon(Icons.close, size: 14),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location / Address',
                hintText: 'e.g. Charles de Gaulle Airport, 123 Rue de Rivoli',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Estimated Cost (Optional)',
                hintText: 'e.g. 45.00',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes / Details',
                hintText:
                    'e.g. Booking confirmation #ABCD123, dress code smart casual',
                prefixIcon: Icon(Icons.notes_rounded),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? 'Save Changes' : 'Add to Itinerary',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
