import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../domain/trip_model.dart';
import '../domain/trip_participant_model.dart';
import 'widgets/add_participant_sheet.dart';
import 'trip_controller.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  final String circleId;
  const CreateTripScreen({super.key, required this.circleId});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  int _currentStep = 1;
  final int _totalSteps = 5;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Goa Getaway');
  final _descriptionController = TextEditingController(text: 'beach, food and fun with the gang!');
  final _locationController = TextEditingController(text: 'Goa');
  final _budgetController = TextEditingController(text: '60000');

  final List<TripParticipantModel> _initialParticipants = [];

  String _selectedCategory = 'Leisure';
  DateTime? _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime? _endDate = DateTime.now().add(const Duration(days: 11));

  final List<String> _categories = [
    'Leisure',
    'Road Trip',
    'Adventure & Trek',
    'Weekend Getaway',
    'Pilgrimage',
    'Work & Offsite',
  ];

  final List<String> _popularDestinations = [
    'Goa',
    'Coorg, Karnataka',
    'Ooty, Tamil Nadu',
    'Wayanad, Kerala',
    'Manali, Himachal Pradesh',
    'Pondicherry',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a trip name')),
        );
        return;
      }
    }
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      _createTrip();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : DateTimeRange(start: now, end: now.add(const Duration(days: 4))),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppPallete.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppPallete.navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _createTrip() {
    final budget = double.tryParse(_budgetController.text.trim()) ?? 0.0;
    ref.read(tripControllerProvider.notifier).createTrip(
          circleId: widget.circleId,
          name: _nameController.text.trim(),
          type: TripType.trip,
          startDate: _startDate,
          endDate: _endDate,
          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
          totalBudget: budget,
          category: _selectedCategory,
          initialParticipants: _initialParticipants,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(tripControllerProvider).isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : AppPallete.navy,
          ),
          onPressed: _prevStep,
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Create Trip',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: isDark ? Colors.white : AppPallete.navy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Step $_currentStep of $_totalSteps',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppPallete.gray,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented Progress Bar (5 segments)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: List.generate(_totalSteps, (index) {
                  final isDone = index + 1 <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index == _totalSteps - 1 ? 0 : 6),
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppPallete.indigo
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Form(
                  key: _formKey,
                  child: _buildCurrentStepContent(isDark),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Container(
          padding: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: Row(
            children: [
              if (_currentStep > 1) ...[
                SecondaryButton(
                  label: 'Back',
                  onPressed: _prevStep,
                  width: 90,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: PrimaryButton(
                  label: _currentStep == _totalSteps ? 'Create Trip' : 'Next ->',
                  isLoading: isLoading,
                  onPressed: _nextStep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent(bool isDark) {
    switch (_currentStep) {
      case 1:
        return _buildStep1Basics(isDark);
      case 2:
        return _buildStep2Dates(isDark);
      case 3:
        return _buildStep3Destination(isDark);
      case 4:
        return _buildStep4Budget(isDark);
      case 5:
        return _buildStep5Review(isDark);
      default:
        return _buildStep1Basics(isDark);
    }
  }

  // STEP 1: Trip Basics (Matches Wireframe 1 Screen 4 exactly)
  Widget _buildStep1Basics(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        // Travel Backpack / Bag Illustration Container
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Icon(
              Icons.backpack_rounded,
              color: AppPallete.indigo,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Trip Basics',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: isDark ? Colors.white : AppPallete.navy,
          ),
        ),
        const SizedBox(height: 24),

        // Trip Name Field
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Trip Name',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isDark ? Colors.white : AppPallete.navy,
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'e.g. Goa Getaway',
            filled: true,
            fillColor: isDark ? AppPallete.surfaceDark : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),

        // Description Field
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Description (optional)',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isDark ? Colors.white : AppPallete.navy,
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _descriptionController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'beach, food and fun with the gang!',
            filled: true,
            fillColor: isDark ? AppPallete.surfaceDark : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),

        // Trip Category Dropdown
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Trip Category',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isDark ? Colors.white : AppPallete.navy,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: _categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // STEP 2: Dates & Duration
  Widget _buildStep2Dates(bool isDark) {
    final dateFormat = DateFormat('EEE, d MMM yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF0284C7),
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Dates & Duration',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: isDark ? Colors.white : AppPallete.navy,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose when this trip takes place to keep everyone synced.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppPallete.gray),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Start Date', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    _startDate != null ? dateFormat.format(_startDate!) : 'Not set',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppPallete.primary),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('End Date', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    _endDate != null ? dateFormat.format(_endDate!) : 'Not set',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppPallete.primary),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Days', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    _startDate != null && _endDate != null
                        ? '${_endDate!.difference(_startDate!).inDays + 1} Days'
                        : 'Custom',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppPallete.navy),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SecondaryButton(
                label: 'Pick Dates',
                icon: Icons.date_range_rounded,
                onPressed: _pickDateRange,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 3: Destination & Location
  Widget _buildStep3Destination(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xFFCCFBF1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Icon(
              Icons.place_rounded,
              color: Color(0xFF0F766E),
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Where are you going?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: isDark ? Colors.white : AppPallete.navy,
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'e.g. Coorg, Karnataka',
            prefixIcon: const Icon(Icons.location_on_outlined, color: AppPallete.primary),
            filled: true,
            fillColor: isDark ? AppPallete.surfaceDark : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Popular Suggestions',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isDark ? Colors.white : AppPallete.navy,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularDestinations.map((dest) {
            final isSelected = _locationController.text == dest;
            return ChoiceChip(
              label: Text(dest),
              selected: isSelected,
              selectedColor: AppPallete.indigo.withValues(alpha: 0.15),
              onSelected: (val) {
                if (val) setState(() => _locationController.text = dest);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // STEP 4: Budget & Expenses
  Widget _buildStep4Budget(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: Color(0xFF92400E),
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Estimated Budget',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: isDark ? Colors.white : AppPallete.navy,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Set a target budget to keep track of group expenses seamlessly.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppPallete.gray),
        ),
        const SizedBox(height: 28),
        TextFormField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            hintText: '60000',
            filled: true,
            fillColor: isDark ? AppPallete.surfaceDark : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // STEP 5: Review & Confirm
  Widget _buildStep5Review(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF065F46),
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Ready to Launch!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: isDark ? Colors.white : AppPallete.navy,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Review the details before creating your trip workspace.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppPallete.gray),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              _buildReviewRow('Trip Name', _nameController.text),
              const Divider(height: 20),
              _buildReviewRow('Category', _selectedCategory),
              const Divider(height: 20),
              _buildReviewRow('Destination', _locationController.text.isNotEmpty ? _locationController.text : 'Coorg, Karnataka'),
              const Divider(height: 20),
              _buildReviewRow(
                'Dates',
                _startDate != null && _endDate != null
                    ? '${DateFormat('d MMM').format(_startDate!)} - ${DateFormat('d MMM').format(_endDate!)}'
                    : 'Flexible',
              ),
              const Divider(height: 20),
              _buildReviewRow('Target Budget', '₹${_budgetController.text}'),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Participants', style: TextStyle(fontWeight: FontWeight.w500, color: AppPallete.gray)),
                  Text(
                    '${_initialParticipants.length + 1} (${_initialParticipants.where((p) => p.isGuest).length} Guests)',
                    style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppPallete.navy),
                  ),
                ],
              ),
              if (_initialParticipants.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _initialParticipants.map((p) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: AppPallete.indigo.withValues(alpha: 0.2),
                        child: Text(
                          p.initials,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppPallete.indigo),
                        ),
                      ),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(p.name, style: const TextStyle(fontSize: 12)),
                          if (p.isGuest) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Guest', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                            ),
                          ],
                        ],
                      ),
                      deleteIcon: const Icon(Icons.close_rounded, size: 14),
                      onDeleted: () => setState(() => _initialParticipants.remove(p)),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('+ Add Guest / Circle Member'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppPallete.indigo,
                  side: const BorderSide(color: AppPallete.indigo),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () {
                  AddParticipantSheet.show(
                    context,
                    tripId: 'draft',
                    onLocalParticipantCreated: (p) {
                      setState(() => _initialParticipants.add(p));
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: AppPallete.gray)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: AppPallete.navy)),
      ],
    );
  }
}
