import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/lodging_model.dart';
import '../trip_controller.dart';
import '../trip_planner_controller.dart';
import '../../../../core/utils/snackbar.dart';

class LodgingSection extends ConsumerStatefulWidget {
  final String tripId;
  const LodgingSection({super.key, required this.tripId});

  @override
  ConsumerState<LodgingSection> createState() => _LodgingSectionState();
}

class _LodgingSectionState extends ConsumerState<LodgingSection> {
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    showSnackBar(context, '$label copied to clipboard!');
  }

  Future<void> _openMap(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
    final appleMapsUrl = Uri.parse('maps://?q=$encodedAddress');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl);
    } else {
      if (mounted) {
        showSnackBar(context, 'Could not open map app');
      }
    }
  }

  Future<void> _callPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        showSnackBar(context, 'Could not launch phone dialer');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lodgingAsync = ref.watch(tripLodgingProvider(widget.tripId));
    final theme = Theme.of(context);

    return Scaffold(
      body: lodgingAsync.when(
        data: (lodgings) {
          if (lodgings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hotel_rounded,
                    size: 64,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No lodgings added yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddLodgingBottomSheet(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Lodging / Hotel'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lodgings.length,
            itemBuilder: (context, index) {
              final lodging = lodgings[index];
              return _buildLodgingCard(context, lodging, theme);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLodgingBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLodgingCard(BuildContext context, LodgingModel lodging, ThemeData theme) {
    final dateRangeStr = '${DateFormat.yMMMd().add_jm().format(lodging.checkIn)}  →  ${DateFormat.yMMMd().add_jm().format(lodging.checkOut)}';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    lodging.name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => _confirmDelete(context, lodging),
                  icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dateRangeStr,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (lodging.address != null && lodging.address!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _openMap(lodging.address!),
                      child: Text(
                        lodging.address!,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(lodging.address!, 'Address'),
                    icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
            if (lodging.confirmationNumber != null && lodging.confirmationNumber!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Confirmation: ${lodging.confirmationNumber}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                    IconButton(
                      onPressed: () => _copyToClipboard(lodging.confirmationNumber!, 'Confirmation code'),
                      icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
            if (lodging.phoneNumber != null && lodging.phoneNumber!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _callPhone(lodging.phoneNumber!),
                    child: Text(
                      lodging.phoneNumber!,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (lodging.notes != null && lodging.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 4),
              const Text(
                'Notes & Instructions',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                lodging.notes!,
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, LodgingModel lodging) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Lodging'),
        content: Text('Are you sure you want to delete "${lodging.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(tripPlannerControllerProvider.notifier).deleteLodging(
                    lodgingId: lodging.id,
                    context: context,
                  );
              Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddLodgingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return _LodgingForm(tripId: widget.tripId, scrollController: scrollController);
          },
        );
      },
    );
  }
}

class _LodgingForm extends ConsumerStatefulWidget {
  final String tripId;
  final ScrollController scrollController;
  const _LodgingForm({required this.tripId, required this.scrollController});

  @override
  ConsumerState<_LodgingForm> createState() => _LodgingFormState();
}

class _LodgingFormState extends ConsumerState<_LodgingForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _checkInDate = DateTime.now();
  TimeOfDay _checkInTime = const TimeOfDay(hour: 15, minute: 0); // Usual 3pm check-in

  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _checkOutTime = const TimeOfDay(hour: 11, minute: 0); // Usual 11am check-out

  @override
  void initState() {
    super.initState();
    ref.read(tripDetailsProvider(widget.tripId)).whenData((trip) {
      if (trip.startDate != null) {
        setState(() {
          _checkInDate = trip.startDate!;
          _checkOutDate = trip.endDate ?? trip.startDate!.add(const Duration(days: 1));
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _confirmationController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isCheckIn) async {
    final initialDate = isCheckIn ? _checkInDate : _checkOutDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate.isBefore(_checkInDate)) {
            _checkOutDate = _checkInDate.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isCheckIn) async {
    final initialTime = isCheckIn ? _checkInTime : _checkOutTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInTime = picked;
        } else {
          _checkOutTime = picked;
        }
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final checkInDateTime = DateTime(
        _checkInDate.year,
        _checkInDate.month,
        _checkInDate.day,
        _checkInTime.hour,
        _checkInTime.minute,
      );

      final checkOutDateTime = DateTime(
        _checkOutDate.year,
        _checkOutDate.month,
        _checkOutDate.day,
        _checkOutTime.hour,
        _checkOutTime.minute,
      );

      if (checkOutDateTime.isBefore(checkInDateTime)) {
        showSnackBar(context, 'Check-out cannot be before Check-in!');
        return;
      }

      ref.read(tripPlannerControllerProvider.notifier).createLodging(
            tripId: widget.tripId,
            name: _nameController.text.trim(),
            address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
            checkIn: checkInDateTime,
            checkOut: checkOutDateTime,
            confirmationNumber: _confirmationController.text.trim().isEmpty ? null : _confirmationController.text.trim(),
            phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            context: context,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: widget.scrollController,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Lodging stay',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Hotel / Airbnb Name *',
                hintText: 'e.g. Hilton Garden Inn, Paris Flat',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter lodging name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'e.g. 15 Rue de la Paix, Paris',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Check-in Date & Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(true),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat.yMMMd().format(_checkInDate)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(true),
                    icon: const Icon(Icons.access_time),
                    label: Text(_checkInTime.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Check-out Date & Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(false),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat.yMMMd().format(_checkOutDate)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(false),
                    icon: const Icon(Icons.access_time),
                    label: Text(_checkOutTime.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmationController,
              decoration: const InputDecoration(
                labelText: 'Confirmation Code',
                hintText: 'e.g. WH123XYZ',
                prefixIcon: Icon(Icons.bookmark_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Hotel Phone Number',
                hintText: 'e.g. +33 1 42 68 53 00',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Access Codes / Special Instructions',
                hintText: 'e.g. Gate code: #4920, Keybox code: 9283 on second floor',
                prefixIcon: Icon(Icons.notes_rounded),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Lodging stay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
