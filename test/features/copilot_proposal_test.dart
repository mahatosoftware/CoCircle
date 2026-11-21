import 'package:flutter_test/flutter_test.dart';
import 'package:cocircle/features/copilot/domain/copilot_models.dart';

void main() {
  group('CopilotProposal Tests', () {
    test('Serializes and deserializes structured plan proposals accurately', () {
      final proposal = CopilotProposal(
        type: CopilotProposalType.tripPlan,
        title: 'Goa 3-Day Beach & Heritage Plan',
        description: 'Complete 3-day itinerary with budget allocation and hotel poll',
        totalEstimatedBudget: 48000.0,
        perPersonBudget: 8000.0,
        itinerary: [
          const ProposedItineraryItem(
            title: 'Check-in & Sunset at Anjuna Beach',
            type: 'lodging',
            dayOffset: 0,
            startHour: 15,
            startMinute: 0,
            location: 'Anjuna, North Goa',
            notes: 'Relax after flight',
            estimatedCost: 0.0,
          ),
          const ProposedItineraryItem(
            title: 'Dinner at Fisherman\'s Wharf',
            type: 'dining',
            dayOffset: 0,
            startHour: 20,
            startMinute: 0,
            location: 'Panaji',
            notes: 'Goan cuisine and seafood',
            estimatedCost: 3500.0,
          ),
        ],
        budgetItems: [
          const ProposedBudgetItem(category: 'Accommodation', amount: 15000.0, note: 'Resort 2 nights'),
          const ProposedBudgetItem(category: 'Transport', amount: 12000.0, note: 'Flights & cabs'),
          const ProposedBudgetItem(category: 'Food', amount: 10000.0, note: 'Dinners & drinks'),
          const ProposedBudgetItem(category: 'Activities', amount: 6000.0, note: 'Water sports'),
          const ProposedBudgetItem(category: 'Misc', amount: 5000.0, note: 'Buffer'),
        ],
        polls: [
          const ProposedPoll(
            question: 'Which hotel should we book?',
            options: ['Beach Resort (₹3,000/night)', 'Boutique Hotel (₹2,200/night)', 'Private Villa (₹4,000/night)'],
            allowMultiple: false,
          ),
        ],
        tasks: [
          const ProposedTask(title: 'Book Goa flights', assignedRole: 'Admin'),
          const ProposedTask(title: 'Reserve private cab for 3 days', assignedRole: 'All'),
        ],
      );

      final json = proposal.toJson();
      final parsed = CopilotProposal.fromJson(json);

      expect(parsed.title, equals(proposal.title));
      expect(parsed.totalEstimatedBudget, equals(48000.0));
      expect(parsed.perPersonBudget, equals(8000.0));
      expect(parsed.itinerary.length, equals(2));
      expect(parsed.budgetItems.length, equals(5));
      expect(parsed.polls.length, equals(1));
      expect(parsed.tasks.length, equals(2));
      expect(parsed.hasContent, isTrue);
    });
  });
}
