import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/poll_model.dart';
import 'poll_controller.dart';
import '../../../../core/theme/app_pallete.dart';
import 'package:cocircle/l10n/app_localizations.dart';

class CreatePollScreen extends ConsumerStatefulWidget {
  final String tripId;
  final PollModel? poll;
  const CreatePollScreen({super.key, required this.tripId, this.poll});

  @override
  ConsumerState<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends ConsumerState<CreatePollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _allowMultipleSelections = false;
  String _pollType = 'standard';
  bool _isAnonymous = false;
  int _deadlineHours = 0; // 0 = None

  @override
  void initState() {
    super.initState();
    if (widget.poll != null) {
      _questionController.text = widget.poll!.question;
      _allowMultipleSelections = widget.poll!.allowMultipleSelections;
      _pollType = widget.poll!.pollType;
      _isAnonymous = widget.poll!.isAnonymous;
      _optionControllers.clear();
      for (var option in widget.poll!.options) {
        _optionControllers.add(TextEditingController(text: option.text));
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  void _applyTemplate(String question, List<String> options) {
    setState(() {
      _questionController.text = question;
      for (var c in _optionControllers) {
        c.dispose();
      }
      _optionControllers.clear();
      for (var opt in options) {
        _optionControllers.add(TextEditingController(text: opt));
      }
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final options = _optionControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (options.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.optionLimitError)),
        );
        return;
      }

      if (widget.poll != null) {
        final updatedPoll = widget.poll!.copyWith(
          question: _questionController.text.trim(),
          options: options.map((text) => PollOption(text: text)).toList(),
          allowMultipleSelections: _allowMultipleSelections,
          pollType: _pollType,
          isAnonymous: _isAnonymous,
        );
        await ref.read(pollControllerProvider.notifier).updatePoll(
              poll: updatedPoll,
              context: context,
            );
        if (mounted) Navigator.pop(context);
      } else {
        DateTime? deadline;
        if (_deadlineHours > 0) {
          deadline = DateTime.now().add(Duration(hours: _deadlineHours));
        }

        await ref.read(pollControllerProvider.notifier).createPoll(
              tripId: widget.tripId,
              question: _questionController.text.trim(),
              optionTexts: options,
              allowMultipleSelections: _allowMultipleSelections,
              pollType: _pollType,
              isAnonymous: _isAnonymous,
              deadline: deadline,
              context: context,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(pollControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.poll != null ? l10n.editPoll : l10n.createPoll),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.poll == null) ...[
              const Text(
                'Quick Poll Templates',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.place_outlined, size: 16),
                      label: const Text('Destination'),
                      onPressed: () => _applyTemplate(
                        'Where should we go?',
                        ['Goa beaches', 'Coorg hills', 'Ooty valley'],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.calendar_month_outlined, size: 16),
                      label: const Text('Dates'),
                      onPressed: () => _applyTemplate(
                        'Which dates work best for everyone?',
                        ['Next Weekend', 'End of this Month', 'First week of next month'],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.hotel_outlined, size: 16),
                      label: const Text('Stay Style'),
                      onPressed: () => _applyTemplate(
                        'What type of stay do you prefer?',
                        ['Luxury Resort', 'Private Pool Villa', 'Homestay / Cottage'],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.directions_car_outlined, size: 16),
                      label: const Text('Transport'),
                      onPressed: () => _applyTemplate(
                        'How should we travel?',
                        ['Car Convoy (Road Trip)', 'Train', 'Flight'],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.restaurant_outlined, size: 16),
                      label: const Text('Dinner Plan'),
                      onPressed: () => _applyTemplate(
                        'Where should we dine tonight?',
                        ['Local Seafood Restaurant', 'Cafe & Bistro', 'Cook / BBQ at villa'],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: l10n.pollQuestion,
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? l10n.enterQuestionError : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            Text(l10n.pollOptions, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._optionControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: '${l10n.pollOptions} ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            (index < 2 && (value == null || value.isEmpty))
                                ? l10n.requiredError
                                : null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    if (_optionControllers.length > 2)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => _removeOption(index),
                      ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add),
              label: Text(l10n.addOption),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.allowMultipleSelections),
              subtitle: const Text('Allow members to pick more than one option'),
              value: _allowMultipleSelections,
              onChanged: (value) {
                setState(() {
                  _allowMultipleSelections = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Anonymous Voting'),
              subtitle: const Text('Voter names will be hidden from everyone'),
              value: _isAnonymous,
              onChanged: (value) {
                setState(() {
                  _isAnonymous = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Voting Deadline'),
              subtitle: Text(
                _deadlineHours == 0
                    ? 'No deadline (remains open)'
                    : 'Closes in $_deadlineHours hours',
              ),
              trailing: DropdownButton<int>(
                value: _deadlineHours,
                onChanged: (val) {
                  if (val != null) setState(() => _deadlineHours = val);
                },
                items: const [
                  DropdownMenuItem(value: 0, child: Text('No Deadline')),
                  DropdownMenuItem(value: 12, child: Text('12 Hours')),
                  DropdownMenuItem(value: 24, child: Text('24 Hours')),
                  DropdownMenuItem(value: 48, child: Text('2 Days')),
                  DropdownMenuItem(value: 72, child: Text('3 Days')),
                  DropdownMenuItem(value: 168, child: Text('7 Days')),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.poll != null ? l10n.saveChanges : l10n.createPollButton),
            ),
          ],
        ),
      ),
    );
  }
}
