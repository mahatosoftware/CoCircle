import 'package:flutter/material.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../road_trip/presentation/day_wise_itinerary_view.dart';
import 'widgets/lodging_section.dart';
import 'widgets/packing_section.dart';
import 'widgets/idea_board_section.dart';

/// The Plan tab unifies all pre-trip and in-trip planning activities:
/// - Day-wise Itinerary
/// - Stays & Lodging bookings
/// - Shared & personal Packing lists
/// - Collaborative Idea Board
class TripPlanTab extends StatefulWidget {
  final String tripId;
  final int initialSubTab;

  const TripPlanTab({
    super.key,
    required this.tripId,
    this.initialSubTab = 0,
  });

  @override
  State<TripPlanTab> createState() => _TripPlanTabState();
}

class _TripPlanTabState extends State<TripPlanTab> {
  late int _selectedSubTab;

  @override
  void initState() {
    super.initState();
    _selectedSubTab = widget.initialSubTab;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSubTabChip(0, 'Itinerary', Icons.explore_outlined),
                const SizedBox(width: 8),
                _buildSubTabChip(1, 'Stays & Lodging', Icons.hotel_outlined),
                const SizedBox(width: 8),
                _buildSubTabChip(2, 'Packing List', Icons.backpack_outlined),
                const SizedBox(width: 8),
                _buildSubTabChip(3, 'Ideas Board', Icons.lightbulb_outline),
              ],
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _selectedSubTab,
            children: [
              DayWiseItineraryView(tripId: widget.tripId),
              LodgingSection(tripId: widget.tripId),
              PackingSection(tripId: widget.tripId),
              IdeaBoardSection(tripId: widget.tripId),
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
        color: isSelected ? Colors.white : Colors.grey.shade700,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : Colors.grey.shade800,
        ),
      ),
      selectedColor: AppPallete.primary,
      backgroundColor: Colors.grey.withValues(alpha: 0.08),
      side: BorderSide(
        color: isSelected ? AppPallete.primary : Colors.grey.withValues(alpha: 0.2),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }
}
