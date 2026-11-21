import 'package:flutter/material.dart';
import '../../../../core/theme/app_pallete.dart';
import 'fuel_calculator_view.dart';
import 'road_trip_utilities_view.dart';
import 'route_planner_view.dart';

class RoadTripWorkspaceTab extends StatefulWidget {
  final String tripId;
  final int initialSubTab;

  const RoadTripWorkspaceTab({
    super.key,
    required this.tripId,
    this.initialSubTab = 0,
  });

  @override
  State<RoadTripWorkspaceTab> createState() => _RoadTripWorkspaceTabState();
}

class _RoadTripWorkspaceTabState extends State<RoadTripWorkspaceTab> {
  late int _selectedSubTab;

  @override
  void initState() {
    super.initState();
    _selectedSubTab = widget.initialSubTab;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSubTabChip(0, 'Multi-Stop Route', Icons.alt_route_rounded),
                const SizedBox(width: 8),
                _buildSubTabChip(1, 'Fuel Calculator', Icons.local_gas_station_rounded),
                const SizedBox(width: 8),
                _buildSubTabChip(2, 'Checklist & Utilities', Icons.build_circle_outlined),
              ],
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _selectedSubTab,
            children: [
              RoutePlannerView(tripId: widget.tripId),
              FuelCalculatorView(tripId: widget.tripId),
              RoadTripUtilitiesView(tripId: widget.tripId),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubTabChip(int index, String label, IconData icon) {
    final isSelected = _selectedSubTab == index;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedSubTab = index);
        }
      },
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppPallete.gray,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppPallete.navy,
        ),
      ),
      selectedColor: AppPallete.indigo,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppPallete.indigo : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }
}
