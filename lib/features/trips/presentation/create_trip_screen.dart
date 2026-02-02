import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../circles/domain/circle_model.dart';
import '../domain/trip_model.dart';
import 'trip_controller.dart';
import '../l10n/app_localizations.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  final String circleId;
  const CreateTripScreen({super.key, required this.circleId});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  TripType _selectedType = TripType.trip;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  void _createTrip() {
    if (_formKey.currentState!.validate()) {
      ref.read(tripControllerProvider.notifier).createTrip(
        circleId: widget.circleId,
        name: _nameController.text.trim(),
        type: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(tripControllerProvider).isLoading;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newTripEvent)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.nameLabel),
                  validator: (val) => val == null || val.isEmpty ? l10n.enterNameError : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TripType>(
                  value: _selectedType,
                  decoration: InputDecoration(labelText: l10n.typeLabel),
                  items: TripType.values.map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t.name.toUpperCase()),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: l10n.locationLabel),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(true),
                        icon: const Icon(Icons.date_range),
                        label: Text(_startDate == null ? l10n.startDateLabel : DateFormat.yMMMd().format(_startDate!)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(false),
                        icon: const Icon(Icons.date_range),
                        label: Text(_endDate == null ? l10n.endDateLabel : DateFormat.yMMMd().format(_endDate!)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _createTrip,
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
      ),
    );
  }
}
