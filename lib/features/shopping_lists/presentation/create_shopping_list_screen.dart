import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_pallete.dart';
import 'shopping_list_controller.dart';
import 'package:cocircle/l10n/app_localizations.dart';

class CreateShoppingListScreen extends ConsumerStatefulWidget {
  final String circleId;
  const CreateShoppingListScreen({super.key, required this.circleId});

  @override
  ConsumerState<CreateShoppingListScreen> createState() => _CreateShoppingListScreenState();
}

class _CreateShoppingListScreenState extends ConsumerState<CreateShoppingListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createList() {
    if (_formKey.currentState!.validate()) {
      ref.read(shoppingListControllerProvider.notifier).createShoppingList(
        circleId: widget.circleId,
        name: _nameController.text.trim(),
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(shoppingListControllerProvider).isLoading;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: const Text('New Shopping List')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.nameLabel),
                validator: (val) => val == null || val.isEmpty ? l10n.enterNameError : null,
                autofocus: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _createList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text(l10n.createButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
