import 'package:cocircle/features/viral_joining/data/guest_invite_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GuestInviteService Message Generation Tests', () {
    test('generateViralInviteMessage creates full writeup with link, code and emojis', () {
      final msg = GuestInviteService.generateViralInviteMessage(
        circleName: 'Goa Squad',
        code: 'GOA2026',
      );

      expect(msg, contains('🎉 You\'re invited to join "Goa Squad" on CoCircle!'));
      expect(msg, contains('🌟 Preview our itinerary, vote on hotel & activity polls, and track expenses together:'));
      expect(msg, contains('https://cocircle.mahato.in/join/GOA2026'));
      expect(msg, contains('(Or join in the CoCircle app using code: GOA2026)'));
    });

    test('generateViralInviteMessage includes trip details when provided', () {
      final msg = GuestInviteService.generateViralInviteMessage(
        circleName: 'Goa Squad',
        code: 'GOA2026',
        tripName: 'Beach & Sun',
        location: 'Goa, India',
        datesString: 'Dec 20 - Dec 25',
      );

      expect(msg, contains('✈️ Trip: Beach & Sun'));
      expect(msg, contains('📍 Destination: Goa, India'));
      expect(msg, contains('🗓️ Dates: Dec 20 - Dec 25'));
      expect(msg, contains('https://cocircle.mahato.in/join/GOA2026'));
    });
  });
}
