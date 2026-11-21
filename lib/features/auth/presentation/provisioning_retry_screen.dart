import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_pallete.dart';
import '../data/auth_repository_impl.dart';
import '../domain/provisioning_state.dart';
import 'provisioning_controller.dart';

class ProvisioningRetryScreen extends ConsumerStatefulWidget {
  const ProvisioningRetryScreen({super.key});

  @override
  ConsumerState<ProvisioningRetryScreen> createState() => _ProvisioningRetryScreenState();
}

class _ProvisioningRetryScreenState extends ConsumerState<ProvisioningRetryScreen> {
  bool _isRetrying = false;
  bool _showDetails = false;

  Future<void> _handleRetry() async {
    final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isRetrying = true);
    try {
      final result = await ref
          .read(provisioningStateNotifierProvider.notifier)
          .retryProvisioning(currentUser);

      if (!mounted) return;

      if (result.status == ProvisioningStatus.completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account setup completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Retry failed. Please check connection.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    setState(() => _isRetrying = true);
    try {
      ref.read(provisioningStateNotifierProvider.notifier).reset();
      await ref.read(authRepositoryProvider).signOut();
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(provisioningStateNotifierProvider);
    final errorType = state?.errorType ?? ProvisioningErrorType.application;
    final retryCount = state?.retryCount ?? 0;
    final errorMessage = state?.error ?? 'Account provisioning could not be completed.';

    IconData headerIcon;
    Color iconColor;
    String title;
    String subtitle;

    switch (errorType) {
      case ProvisioningErrorType.network:
        headerIcon = Icons.wifi_off_rounded;
        iconColor = Colors.amber.shade700;
        title = 'Connection Issue';
        subtitle =
            'We couldn\'t connect to the database to complete your account setup. Please verify your internet or Wi-Fi connection and tap Retry.';
        break;
      case ProvisioningErrorType.permission:
        headerIcon = Icons.security_rounded;
        iconColor = Colors.deepOrangeAccent;
        title = 'Permission Issue';
        subtitle =
            'We encountered an access permission issue while configuring your account. Please retry, or sign out and log back in.';
        break;
      case ProvisioningErrorType.application:
        headerIcon = Icons.sync_problem_rounded;
        iconColor = Colors.orangeAccent;
        title = 'Setup Incomplete';
        subtitle =
            'Something went wrong while initializing your account records. Your login session is preserved. Tap Retry to complete setup.';
        break;
    }

    final isInProgress = _isRetrying || state?.status == ProvisioningStatus.in_progress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Setup'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: isInProgress ? null : _handleSignOut,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  headerIcon,
                  size: 64,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              if (retryCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Retries attempted: $retryCount',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                ),
              ],
              const SizedBox(height: 24),
              // Collapsible Technical Diagnostics
              InkWell(
                onTap: () => setState(() => _showDetails = !_showDetails),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showDetails ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showDetails ? 'Hide Details' : 'View Error Details',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showDetails) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black26
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    'Error: $errorMessage\nStage: ${state?.stage ?? "unknown"}\nError Type: ${errorType.name}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
              const Spacer(flex: 2),
              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isInProgress ? null : _handleRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: isInProgress
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(
                    isInProgress ? 'Setting up account...' : 'Retry Setup',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: isInProgress ? null : _handleSignOut,
                child: const Text('Sign Out'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
