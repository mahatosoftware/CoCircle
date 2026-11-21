import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_picker/country_picker.dart';
import '../data/auth_repository_impl.dart';
import 'profile_controller.dart';
import 'package:cocircle/l10n/app_localizations.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/ad_banner_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedCountry;
  String? _countryFlag;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user != null) {
      _nameController.text = user.displayName;
      setState(() {
        _selectedCountry = user.country;
        if (_selectedCountry != null) {
          final country = Country.tryParse(_selectedCountry!);
          _countryFlag = country?.flagEmoji;
        }
      });
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
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
                    decoration: InputDecoration(
                      labelText: l10n.displayName,
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? l10n.nameEmptyError : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: user.email,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: l10n.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: const OutlineInputBorder(),
                      helperText: l10n.emailCannotBeChanged,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: false,
                        onSelect: (Country country) {
                          setState(() {
                            _selectedCountry = country.name;
                            _countryFlag = country.flagEmoji;
                          });
                        },
                      );
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        prefixIcon: Icon(Icons.public),
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        children: [
                          if (_countryFlag != null) ...[
                            Text(_countryFlag!, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                          ],
                          Text(_selectedCountry ?? 'Select Country'),
                        ],
                      ),
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
                            country: _selectedCountry,
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
                  const AdBannerWidget(),
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
