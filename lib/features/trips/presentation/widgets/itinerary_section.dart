import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/itinerary_item_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final itineraryAsync = ref.watch(tripItineraryProvider(widget.tripId));
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));

    return Scaffold(
      body: itineraryAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_rounded,
                    size: 64,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No activities planned yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddActivityBottomSheet(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Activity'),
                  ),
                ],
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
            padding: const EdgeInsets.all(16),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final dateStr = sortedDates[index];
              final dayItems = grouped[dateStr]!;
              final parsedDate = DateTime.parse(dateStr);

              // Calculate "Day X" label if trip start date is available
              String dayLabel = DateFormat.yMMMMd().format(parsedDate);
              tripAsync.whenData((trip) {
                if (trip.startDate != null) {
                  final diff = parsedDate.difference(trip.startDate!).inDays + 1;
                  if (diff >= 1) {
                    dayLabel = 'Day $diff - ${DateFormat.E().format(parsedDate)}, ${DateFormat.MMMd().format(parsedDate)}';
                  }
                }
              });

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Text(
                      dayLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ...dayItems.map((item) => _buildActivityCard(context, item)),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddActivityBottomSheet(context),
        child: const Icon(Icons.add),
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
              child: Icon(
                typeIcon,
                color: typeColor,
                size: 24,
              ),
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
                        DateFormat.jm().format(item.startTime),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (item.location != null && item.location!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location!,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (item.cost != null && item.cost! > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            // Delete button
            IconButton(
              onPressed: () => _confirmDelete(context, item),
              icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 20),
            ),
          ],
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
              ref.read(tripPlannerControllerProvider.notifier).deleteItineraryItem(
                    itemId: item.id,
                    context: context,
                  );
              Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddActivityBottomSheet(BuildContext context) {
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
            return _ActivityForm(tripId: widget.tripId, scrollController: scrollController);
          },
        );
      },
    );
  }
}

class _ActivityForm extends ConsumerStatefulWidget {
  final String tripId;
  final ScrollController scrollController;
  const _ActivityForm({required this.tripId, required this.scrollController});

  @override
  ConsumerState<_ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends ConsumerState<_ActivityForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _costController = TextEditingController();

  String _selectedType = 'general';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  final List<Map<String, String>> _types = [
    {'value': 'general', 'label': 'General / Other'},
    {'value': 'travel', 'label': 'Travel / Flight'},
    {'value': 'lodging', 'label': 'Lodging stay'},
    {'value': 'dining', 'label': 'Dining / Restaurant'},
    {'value': 'sightseeing', 'label': 'Sightseeing'},
  ];

  @override
  void initState() {
    super.initState();
    // Default form date to trip start date if available
    ref.read(tripDetailsProvider(widget.tripId)).whenData((trip) {
      if (trip.startDate != null) {
        setState(() {
          _selectedDate = trip.startDate!;
        });
      }
    });
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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final cost = double.tryParse(_costController.text.trim());

      ref.read(tripPlannerControllerProvider.notifier).createItineraryItem(
            tripId: widget.tripId,
            title: _titleController.text.trim(),
            type: _selectedType,
            startTime: combinedDateTime,
            location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            cost: cost,
            context: context,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Add Activity',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Activity Type',
                border: OutlineInputBorder(),
              ),
              items: _types
                  .map((t) => DropdownMenuItem(
                        value: t['value'],
                        child: Text(t['label']!),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat.yMMMd().format(_selectedDate)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime.format(context)),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes / Details',
                hintText: 'e.g. Booking confirmation #ABCD123, dress code smart casual',
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add to Itinerary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
