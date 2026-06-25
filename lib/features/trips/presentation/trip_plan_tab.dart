import 'package:flutter/material.dart';
import 'widgets/itinerary_section.dart';
import 'widgets/lodging_section.dart';
import 'widgets/idea_board_section.dart';
import 'widgets/packing_section.dart';

class TripPlanTab extends StatefulWidget {
  final String tripId;
  const TripPlanTab({super.key, required this.tripId});

  @override
  State<TripPlanTab> createState() => _TripPlanTabState();
}

class _TripPlanTabState extends State<TripPlanTab> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {
      'label': 'Itinerary',
      'icon': Icons.calendar_today_rounded,
    },
    {
      'label': 'Lodging',
      'icon': Icons.hotel_rounded,
    },
    {
      'label': 'Idea Board',
      'icon': Icons.lightbulb_rounded,
    },
    {
      'label': 'Packing List',
      'icon': Icons.backpack_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSubTabBar(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _buildActiveSection(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTabBar() {
    final theme = Theme.of(context);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _currentIndex == index;
          final tab = _tabs[index];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _currentIndex = index),
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 18,
                      color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveSection() {
    switch (_currentIndex) {
      case 0:
        return ItinerarySection(key: const ValueKey('ItinerarySection'), tripId: widget.tripId);
      case 1:
        return LodgingSection(key: const ValueKey('LodgingSection'), tripId: widget.tripId);
      case 2:
        return IdeaBoardSection(key: const ValueKey('IdeaBoardSection'), tripId: widget.tripId);
      case 3:
        return PackingSection(key: const ValueKey('PackingSection'), tripId: widget.tripId);
      default:
        return Container();
    }
  }
}
