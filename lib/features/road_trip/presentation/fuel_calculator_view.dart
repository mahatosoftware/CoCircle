import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../trips/presentation/trip_participant_controller.dart';
import '../domain/vehicle_fuel_model.dart';
import 'road_trip_controller.dart';

class FuelCalculatorView extends ConsumerStatefulWidget {
  final String tripId;

  const FuelCalculatorView({super.key, required this.tripId});

  @override
  ConsumerState<FuelCalculatorView> createState() => _FuelCalculatorViewState();
}

class _FuelCalculatorViewState extends ConsumerState<FuelCalculatorView> {
  final _distanceController = TextEditingController();
  final _mileageController = TextEditingController(text: '15.0');
  final _priceController = TextEditingController(text: '105.0');
  FuelType _selectedFuelType = FuelType.petrol;

  bool _initializedFromRoute = false;

  @override
  void dispose() {
    _distanceController.dispose();
    _mileageController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeAsync = ref.watch(roadTripRouteStreamProvider(widget.tripId));
    final vehiclesAsync = ref.watch(roadTripVehiclesStreamProvider(widget.tripId));
    final participantsAsync = ref.watch(tripParticipantsProvider(widget.tripId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Auto-fill distance from route once available
    if (!_initializedFromRoute && routeAsync.asData?.value != null) {
      final dist = routeAsync.asData!.value!.totalDistanceKm;
      if (dist > 0) {
        _distanceController.text = dist.toStringAsFixed(0);
        _initializedFromRoute = true;
      }
    }

    final distance = double.tryParse(_distanceController.text) ?? 500.0;
    final mileage = double.tryParse(_mileageController.text) ?? 15.0;
    final price = double.tryParse(_priceController.text) ?? 105.0;

    final participants = participantsAsync.asData?.value ?? [];
    final participantCount = participants.isNotEmpty ? participants.length : 4;
    final vehicles = vehiclesAsync.asData?.value ?? [];

    // Calculate baseline summary or multi-vehicle summary
    final fuelSummary = TripFuelSummary.calculate(
      totalDistanceKm: distance,
      vehicles: vehicles,
      totalParticipants: participantCount,
      baselineMileage: mileage,
      baselinePrice: price,
    );

    return Scaffold(
      backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Result Summary Card
            _buildResultCard(context, fuelSummary, isDark),
            const SizedBox(height: 16),

            // 2. Baseline Calculator Parameters
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppPallete.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.calculate_rounded, color: Color(0xFFF59E0B), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Trip Fuel Estimator',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Distance
                  TextField(
                    controller: _distanceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Total Distance (km)',
                      prefixIcon: const Icon(Icons.straighten_rounded, size: 20),
                      suffixText: 'km',
                      border: const OutlineInputBorder(),
                      helperText: _initializedFromRoute ? '✓ Auto-synced from Multi-Stop Route' : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  // Mileage and Fuel Price
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _mileageController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Vehicle Mileage',
                            suffixText: 'km/L',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Fuel Price (₹)',
                            prefixText: '₹',
                            suffixText: '/L',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Fuel Type
                  DropdownButtonFormField<FuelType>(
                    isExpanded: true,
                    initialValue: _selectedFuelType,
                    decoration: const InputDecoration(
                      labelText: 'Fuel Type',
                      border: OutlineInputBorder(),
                    ),
                    items: FuelType.values
                        .map((f) => DropdownMenuItem(value: f, child: Text(f.name.toUpperCase(), overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedFuelType = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Passengers sharing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cost Sharing Travellers: $participantCount',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        'Includes Guests',
                        style: TextStyle(fontSize: 11, color: AppPallete.teal, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Multi-Vehicle Convoy Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Convoy Vehicles (Optional)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showAddVehicleDialog(context, distance),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Vehicle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            if (vehicles.isNotEmpty)
              ...vehicles.map((v) => _buildVehicleCard(context, v, isDark))
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppPallete.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: const Text(
                  'Driving in multiple cars or bikes? Tap "+ Add Vehicle" to calculate separate fuel expenses per vehicle.',
                  style: TextStyle(fontSize: 12, color: AppPallete.gray),
                ),
              ),

            const SizedBox(height: 100), // Navigation spacing
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: PrimaryButton(
          label: 'Convert Estimate to Trip Expense',
          icon: Icons.receipt_long_rounded,
          height: 48,
          onPressed: () {
            // Open CreateExpenseScreen with pre-filled amount and fuel category
            context.push('/trip/${widget.tripId}/create-expense');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Fuel estimate ₹${fuelSummary.totalEstimatedCost.toStringAsFixed(0)} ready to log as an expense!',
                ),
                backgroundColor: AppPallete.indigo,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, TripFuelSummary summary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
              : [const Color(0xFFEEF2FF), const Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPallete.indigo.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ESTIMATED FUEL EXPENSE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppPallete.indigo,
                ),
              ),
              StatusBadge.warning(label: 'Estimate'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹${summary.totalEstimatedCost.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppPallete.navy,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${summary.totalFuelUnits.toStringAsFixed(1)} Litres)',
                style: const TextStyle(fontSize: 13, color: AppPallete.gray, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Per Person Share (${summary.participantCount} travellers):',
                style: const TextStyle(fontSize: 12, color: AppPallete.gray),
              ),
              Text(
                '₹${summary.costPerPerson.toStringAsFixed(0)} / person',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, VehicleFuelModel vehicle, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_car_rounded, color: AppPallete.indigo, size: 20),
                  const SizedBox(width: 8),
                  Text(vehicle.vehicleName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                onPressed: () => ref.read(roadTripControllerProvider).deleteVehicle(widget.tripId, vehicle.id),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${vehicle.mileageKmPerUnit} km/L @ ₹${vehicle.fuelPricePerUnit}/L',
                style: const TextStyle(fontSize: 12, color: AppPallete.gray),
              ),
              Text(
                '₹${vehicle.estimatedFuelCost.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddVehicleDialog(BuildContext context, double defaultDistance) {
    final nameController = TextEditingController(text: 'Convoy Car 2');
    final mileageController = TextEditingController(text: '16.0');
    final priceController = TextEditingController(text: '105.0');
    FuelType fuelType = FuelType.petrol;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Convoy Vehicle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Vehicle Name')),
            const SizedBox(height: 8),
            TextField(
              controller: mileageController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Mileage (km/L)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Fuel Price (₹/L)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final vehicle = VehicleFuelModel(
                id: const Uuid().v4(),
                tripId: widget.tripId,
                vehicleName: nameController.text.trim(),
                fuelType: fuelType,
                mileageKmPerUnit: double.tryParse(mileageController.text) ?? 15.0,
                fuelPricePerUnit: double.tryParse(priceController.text) ?? 105.0,
                distanceAllocationKm: defaultDistance,
              );
              ref.read(roadTripControllerProvider).saveVehicle(vehicle);
              Navigator.pop(ctx);
            },
            child: const Text('Add Vehicle'),
          ),
        ],
      ),
    );
  }
}
