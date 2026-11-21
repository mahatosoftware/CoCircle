import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cocircle/core/widgets/status_badge.dart';
import 'package:cocircle/core/widgets/app_buttons.dart';
import 'package:cocircle/features/trips/presentation/create_trip_screen.dart';

void main() {
  group('Wireframe Design System & Core Components Tests', () {
    testWidgets('StatusBadge renders wireframe statuses with correct colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge.fromTripStatus('ongoing'),
                StatusBadge.fromTripStatus('planning'),
                StatusBadge.fromTripStatus('confirmed'),
                StatusBadge.fromTripStatus('upcoming'),
                StatusBadge.fromTripStatus('settling'),
                StatusBadge.fromTripStatus('closed'),
                StatusBadge.fromTripStatus('cancelled'),
                StatusBadge.fromTripStatus('draft'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Ongoing'), findsOneWidget);
      expect(find.text('Planning'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Settling'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
    });

    testWidgets('PrimaryButton and SecondaryButton render and respond to taps', (tester) async {
      bool primaryTapped = false;
      bool secondaryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PrimaryButton(
                  label: 'Confirm Plan',
                  icon: Icons.check,
                  onPressed: () => primaryTapped = true,
                ),
                SecondaryButton(
                  label: 'Cancel',
                  onPressed: () => secondaryTapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Confirm Plan'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Confirm Plan'));
      expect(primaryTapped, isTrue);

      await tester.tap(find.text('Cancel'));
      expect(secondaryTapped, isTrue);
    });

    testWidgets('CreateTripScreen displays 5-step flow with Step 1 basics', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateTripScreen(circleId: 'test-circle'),
          ),
        ),
      );

      expect(find.text('Create Trip'), findsOneWidget);
      expect(find.text('Step 1 of 5'), findsOneWidget);
      expect(find.text('Trip Basics'), findsOneWidget);
      expect(find.text('Next ->'), findsOneWidget);
      expect(find.byIcon(Icons.backpack_rounded), findsOneWidget);

      // Enter trip name to satisfy validation
      await tester.enterText(find.byType(TextFormField).first, 'Mountain Retreat');
      await tester.pumpAndSettle();

      // Advance to step 2
      await tester.tap(find.text('Next ->'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 5'), findsOneWidget);
      expect(find.text('Dates & Duration'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });
  });
}
