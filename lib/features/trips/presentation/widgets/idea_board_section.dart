import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../auth/data/auth_repository_impl.dart';
import '../../domain/idea_model.dart';
import '../trip_controller.dart';
import '../trip_planner_controller.dart';
import '../../../circles/presentation/circle_controller.dart';

class IdeaBoardSection extends ConsumerStatefulWidget {
  final String tripId;
  const IdeaBoardSection({super.key, required this.tripId});

  @override
  ConsumerState<IdeaBoardSection> createState() => _IdeaBoardSectionState();
}

class _IdeaBoardSectionState extends ConsumerState<IdeaBoardSection> {
  @override
  Widget build(BuildContext context) {
    final ideasAsync = ref.watch(tripIdeasProvider(widget.tripId));
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final currentUserAsync = ref.watch(authStateChangesProvider);
    final currentUserId = currentUserAsync.value?.uid ?? '';
    final theme = Theme.of(context);

    return Scaffold(
      body: ideasAsync.when(
        data: (ideas) {
          final activeIdeas = ideas.where((idea) => !idea.isConverted).toList();

          if (activeIdeas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 64,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No ideas suggested yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddIdeaBottomSheet(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Suggest an Idea'),
                  ),
                ],
              ),
            );
          }

          return tripAsync.when(
            data: (trip) {
              final membersAsync = ref.watch(circleMembersProvider(trip.circleId));
              return membersAsync.when(
                data: (members) {
                  final memberMap = {for (final m in members) m.uid: m.displayName};
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activeIdeas.length,
                    itemBuilder: (context, index) {
                      final idea = activeIdeas[index];
                      final creatorName = memberMap[idea.createdBy] ?? 'Member';
                      final hasVoted = idea.votes.contains(currentUserId);

                      return _buildIdeaCard(context, idea, creatorName, hasVoted, currentUserId, theme);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIdeaBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildIdeaCard(
    BuildContext context,
    IdeaModel idea,
    String creatorName,
    bool hasVoted,
    String currentUserId,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        idea.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Suggested by $creatorName • ${DateFormat.MMMd().format(idea.createdAt)}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _confirmDelete(context, idea),
                  icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (idea.description != null && idea.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                idea.description!,
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
            if (idea.location != null && idea.location!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      idea.location!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Upvote Button
                InkWell(
                  onTap: () {
                    ref.read(tripPlannerControllerProvider.notifier).toggleVoteIdea(
                          ideaId: idea.id,
                          userId: currentUserId,
                          context: context,
                        );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasVoted ? Colors.red.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          hasVoted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: hasVoted ? Colors.red : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${idea.votes.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: hasVoted ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Promote Button
                ElevatedButton.icon(
                  onPressed: () => _showPromoteDialog(context, idea),
                  icon: const Icon(Icons.check_circle_outline, size: 14),
                  label: const Text('Add to Itinerary'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, IdeaModel idea) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Idea'),
        content: Text('Are you sure you want to delete "${idea.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(tripPlannerControllerProvider.notifier).deleteIdea(
                    ideaId: idea.id,
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

  void _showAddIdeaBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return _IdeaForm(tripId: widget.tripId, scrollController: scrollController);
          },
        );
      },
    );
  }

  void _showPromoteDialog(BuildContext context, IdeaModel idea) {
    showDialog(
      context: context,
      builder: (dialogCtx) => _PromoteIdeaDialog(idea: idea, parentContext: context),
    );
  }
}

class _IdeaForm extends ConsumerStatefulWidget {
  final String tripId;
  final ScrollController scrollController;
  const _IdeaForm({required this.tripId, required this.scrollController});

  @override
  ConsumerState<_IdeaForm> createState() => _IdeaFormState();
}

class _IdeaFormState extends ConsumerState<_IdeaForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      ref.read(tripPlannerControllerProvider.notifier).createIdea(
            tripId: widget.tripId,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
            location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
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
                  'Suggest Travel Idea',
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
                labelText: 'Place/Activity Idea *',
                hintText: 'e.g. Visit Eiffel Tower, Boat cruise at night',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your suggestion' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (Optional)',
                hintText: 'e.g. Eiffel Tower, Paris',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Why should we do this? Notes',
                hintText: 'e.g. Tickets are cheap at 6pm, view is amazing!',
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
              child: const Text('Add Suggestion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _PromoteIdeaDialog extends ConsumerStatefulWidget {
  final IdeaModel idea;
  final BuildContext parentContext;
  const _PromoteIdeaDialog({required this.idea, required this.parentContext});

  @override
  ConsumerState<_PromoteIdeaDialog> createState() => _PromoteIdeaDialogState();
}

class _PromoteIdeaDialogState extends ConsumerState<_PromoteIdeaDialog> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _selectedType = 'sightseeing';

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
    ref.read(tripDetailsProvider(widget.idea.tripId)).whenData((trip) {
      if (trip.startDate != null) {
        setState(() {
          _selectedDate = trip.startDate!;
        });
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Idea'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Schedule "${widget.idea.title}" into the itinerary timeline.'),
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
            const Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDate,
                    child: Text(DateFormat.yMMMd().format(_selectedDate)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickTime,
                    child: Text(_selectedTime.format(context)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final combinedDateTime = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _selectedTime.hour,
              _selectedTime.minute,
            );

            ref.read(tripPlannerControllerProvider.notifier).promoteIdeaToItinerary(
                  idea: widget.idea,
                  startTime: combinedDateTime,
                  type: _selectedType,
                  context: context,
                );
          },
          child: const Text('Add to Timeline'),
        ),
      ],
    );
  }
}
