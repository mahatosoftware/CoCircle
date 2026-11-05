import 'package:flutter/material.dart';

import 'widgets/itinerary_section.dart';

/// The Plan tab is the trip itinerary itself. Keeping this as a small wrapper
/// lets the detail screen keep a stable tab widget while avoiding a second
/// layer of navigation inside the planner.
class TripPlanTab extends StatelessWidget {
  const TripPlanTab({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return ItinerarySection(tripId: tripId);
  }
}
