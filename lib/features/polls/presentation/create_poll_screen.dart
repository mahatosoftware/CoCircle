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

  @override
  void initState() {
    super.initState();
    if (widget.poll != null) {
      _questionController.text = widget.poll!.question;
      _allowMultipleSelections = widget.poll!.allowMultipleSelections;
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
        );
        await ref.read(pollControllerProvider.notifier).updatePoll(
              poll: updatedPoll,
              context: context,
            );
        if (mounted) Navigator.pop(context);
      } else {
        await ref.read(pollControllerProvider.notifier).createPoll(
              tripId: widget.tripId,
              question: _questionController.text.trim(),
              optionTexts: options,
              allowMultipleSelections: _allowMultipleSelections,
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
        title: Text(widget.poll != null ? (l10n.editPoll ?? 'Edit Poll') : l10n.createPoll),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
              value: _allowMultipleSelections,
              onChanged: (value) {
                setState(() {
                  _allowMultipleSelections = value;
                });
              },
              contentPadding: EdgeInsets.zero,
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
                  : Text(widget.poll != null ? (l10n.saveChanges ?? 'Save Changes') : l10n.createPollButton),
            ),
          ],
        ),
      ),
    );
  }
}
