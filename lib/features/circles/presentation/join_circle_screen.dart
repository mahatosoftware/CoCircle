import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_pallete.dart';
import 'circle_controller.dart';
import 'qr_scanner_screen.dart';
import '../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class JoinCircleScreen extends ConsumerStatefulWidget {
  final String? initialCode;
  const JoinCircleScreen({super.key, this.initialCode});

  @override
  ConsumerState<JoinCircleScreen> createState() => _JoinCircleScreenState();
}

class _JoinCircleScreenState extends ConsumerState<JoinCircleScreen> {
  late final TextEditingController _codeController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialCode);
  }

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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.joinCircleTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.joinCircleDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                   Expanded(
                     child: TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.circleCode,
                          hintText: AppLocalizations.of(context)!.circleCodeHint,
                          border: const OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          UpperCaseTextFormatter(),
                        ],
                        validator: (val) {
                          if (val == null || val.isEmpty) return AppLocalizations.of(context)!.enterCodeError;
                          if (val.length < 7) return AppLocalizations.of(context)!.codeTooShortError;
                          return null;
                        },
                      ),
                   ),
                   const SizedBox(width: 12),
                   IconButton.filledTonal(
                     icon: const Icon(Icons.qr_code_scanner),
                     onPressed: () async {
                       final scannedCode = await context.push<String>('/scan-qr');
                       if (scannedCode != null) {
                         _codeController.text = scannedCode;
                         _joinCircle();
                       }
                     },
                   ),
                ],
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
                    : Text(AppLocalizations.of(context)!.requestToJoinButton),
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
