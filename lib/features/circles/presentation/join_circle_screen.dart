import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_pallete.dart';
import 'circle_controller.dart';

class JoinCircleScreen extends ConsumerStatefulWidget {
  const JoinCircleScreen({super.key});

  @override
  ConsumerState<JoinCircleScreen> createState() => _JoinCircleScreenState();
}

class _JoinCircleScreenState extends ConsumerState<JoinCircleScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _joinCircle() {
    if (_formKey.currentState!.validate()) {
      ref.read(circleControllerProvider.notifier).joinCircleByCode(
        code: _codeController.text.trim(),
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(circleControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Join Circle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter the 7-character code shared by your admin.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Circle Code',
                  hintText: 'e.g. X7Y2Z9A',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(7),
                  UpperCaseTextFormatter(),
                ],
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter code';
                  if (val.length != 7) return 'Code must be 7 characters';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _joinCircle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Request to Join'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
