import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_picker/currency_picker.dart';
import '../../../../core/theme/app_pallete.dart';
import 'circle_controller.dart';
import 'package:cocircle/l10n/app_localizations.dart';

class CreateCircleScreen extends ConsumerStatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  ConsumerState<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends ConsumerState<CreateCircleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCurrency = 'USD';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createCircle() {
    if (_formKey.currentState!.validate()) {
      ref.read(circleControllerProvider.notifier).createCircle(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        currency: _selectedCurrency,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(circleControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.createCircleTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.circleName),
                validator: (val) => val == null || val.isEmpty ? AppLocalizations.of(context)!.enterCircleNameError : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(text: _selectedCurrency),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.currency,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                onTap: () {
                  showCurrencyPicker(
                    context: context,
                    showFlag: true,
                    showCurrencyName: true,
                    showCurrencyCode: true,
                    onSelect: (Currency currency) {
                      setState(() {
                        _selectedCurrency = currency.code;
                      });
                    },
                  );
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _createCircle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text(AppLocalizations.of(context)!.createCircleButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
