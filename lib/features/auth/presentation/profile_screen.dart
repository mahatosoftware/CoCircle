import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository_impl.dart';
import 'profile_controller.dart';
import '../l10n/app_localizations.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/copyright_footer.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user != null) {
      _nameController.text = user.displayName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateChangesProvider);
    final isUpdating = ref.watch(profileControllerProvider).isLoading;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            tooltip: AppLocalizations.of(context)!.signOut,
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return Center(child: Text(AppLocalizations.of(context)!.userNotFound));
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppPallete.primary.withValues(alpha: 0.1),
                        backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                        child: user.photoUrl == null 
                          ? Text(
                              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?', 
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppPallete.primary),
                            )
                          : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppPallete.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: l10n.displayName,
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? l10n.nameEmptyError : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: user.email,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: l10n.emailAddress,
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                      helperText: l10n.emailCannotBeChanged,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isUpdating ? null : () {
                        if (_formKey.currentState!.validate()) {
                          ref.read(profileControllerProvider.notifier).updateProfile(
                            name: _nameController.text.trim(),
                            context: context,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isUpdating 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(l10n.updateProfile, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.errorWithDetails(e.toString()))),
      ),
    );
  }
}
