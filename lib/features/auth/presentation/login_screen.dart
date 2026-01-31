import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_pallete.dart';
import '../data/auth_repository_impl.dart';

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
                label: 'Resend',
                onPressed: () async {
                  final resendData = await authRepo.resendVerificationEmail(email: email, password: password);
                  if (mounted) {
                    resendData.fold(
                      (fl) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(fl.message))),
                      (fr) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email sent! Check your inbox.'))),
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
            const SnackBar(content: Text('Account created! Please verify your email before logging in.')),
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
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to receive a password reset link.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid email')),
                );
                return;
              }
              
              Navigator.pop(context); // Close dialog first

              final res = await ref.read(authRepositoryProvider).resetPassword(email: email);
              
              if (mounted) {
                 res.fold(
                  (l) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.message))),
                  (r) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent! check your inbox.'))),
                );
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    _isSignUp ? 'Join CoCircle' : 'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp ? 'Create an account to get started' : 'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  
                  if (_isSignUp) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
                      validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty || !value.contains('@') ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                    obscureText: true,
                    validator: (value) => value!.length < 6 ? 'Password must be at least 6 chars' : null,
                  ),
                  const SizedBox(height: 8),
                  if (!_isSignUp)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: const Text('Forgot Password?'),
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
                            child: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('OR')), Expanded(child: Divider())]),
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
                            label: const Text('Continue with Google'),
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
                          child: Text(_isSignUp ? 'Already have an account? Sign In' : 'Don\'t have an account? Sign Up'),
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
