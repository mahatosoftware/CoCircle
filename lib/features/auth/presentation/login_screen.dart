import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_pallete.dart';
import '../data/auth_repository_impl.dart';
import 'package:cocircle/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // For Sign Up
  bool _isSignUp = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final authRepo = ref.read(authRepositoryProvider);

    final res = _isSignUp 
      ? await authRepo.signUpWithEmailPassword(email: email, password: password, name: name)
      : await authRepo.signInWithEmailPassword(email: email, password: password);

    setState(() => _isLoading = false);

    res.fold(
      (l) {
        if (l.message.contains('not verified')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.message),
              action: SnackBarAction(
                label: AppLocalizations.of(context)!.resend,
                onPressed: () async {
                  final resendData = await authRepo.resendVerificationEmail(email: email, password: password);
                  if (mounted) {
                    resendData.fold(
                      (fl) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(fl.message))),
                      (fr) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.verificationEmailSent))),
                    );
                  }
                },
              ),
              duration: const Duration(seconds: 10),
            ),
          );
        } else {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.message)));
        }
      },
      (r) {
        if (_isSignUp) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.accountCreatedVerifyEmail)),
          );
          setState(() {
            _isSignUp = false;
          });
        }
      },
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.resetPasswordTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.resetPasswordDescription),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.email, border: const OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.invalidEmailError)),
                );
                return;
              }
              
              Navigator.pop(context); // Close dialog first

              final res = await ref.read(authRepositoryProvider).resetPassword(email: email);
              
              if (mounted) {
                  res.fold(
                  (l) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.message))),
                  (r) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.passwordResetEmailSent))),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.sendLink),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icon/app_icon.png', height: 120),
                  const SizedBox(height: 24),
                  Text(
                    _isSignUp ? l10n.joinCoCircle : l10n.welcomeBack,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp ? l10n.signUpDescription : l10n.signInDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  
                  if (_isSignUp) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: l10n.name, prefixIcon: const Icon(Icons.person)),
                      validator: (value) => value!.isEmpty ? l10n.enterNameError : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: l10n.email, prefixIcon: const Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty || !value.contains('@') ? l10n.enterEmailError : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: l10n.password, prefixIcon: const Icon(Icons.lock)),
                    obscureText: true,
                    validator: (value) => value!.length < 6 ? l10n.passwordLengthError : null,
                  ),
                  const SizedBox(height: 8),
                  if (!_isSignUp)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: Text(l10n.forgotPassword),
                      ),
                    ),
                  const SizedBox(height: 24),

                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPallete.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(_isSignUp ? l10n.signUp : l10n.signIn),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(children: [const Expanded(child: Divider()), Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(l10n.orSeparator)), const Expanded(child: Divider())]),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final res = await ref.read(authRepositoryProvider).signInWithGoogle();
                               res.fold(
                                (l) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.message))),
                                (r) {},
                              );
                            },
                            icon: const Icon(Icons.login), // Ideally Google Icon
                            label: Text(l10n.continueWithGoogle),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                             setState(() => _isSignUp = !_isSignUp);
                          },
                          child: Text(_isSignUp ? l10n.alreadyHaveAccount : l10n.dontHaveAccount),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
