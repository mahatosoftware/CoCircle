import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'widgets/trip_overview_view.dart';
import 'widgets/finance_group_view.dart';
import '../../polls/presentation/poll_list_view.dart';
import '../../tasks/presentation/task_list_view.dart';
import 'trip_controller.dart';
import 'package:cocircle/l10n/app_localizations.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final String tripId;
  final int initialTabIndex;
  const TripDetailScreen({super.key, required this.tripId, this.initialTabIndex = 0});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex >= 4 ? 0 : widget.initialTabIndex,
    );
    _tabController.addListener(() {
      setState(() {}); // Rebuild for FAB update
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: tripAsync.when(
          data: (trip) => Text(trip.name),
          loading: () => Text(l10n.loading),
          error: (_, __) => Text(l10n.error),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.overview, icon: const Icon(Icons.dashboard_outlined)),
            Tab(text: l10n.finance, icon: const Icon(Icons.payments_outlined)),
            Tab(text: l10n.polls, icon: const Icon(Icons.poll_outlined)),
            const Tab(text: 'Tasks', icon: Icon(Icons.task_alt_outlined)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              tripAsync.whenData((trip) {
                showDialog(
                  context: context,
                  builder: (context) {
                    final controller = TextEditingController(text: trip.name);
                    return AlertDialog(
                      title: Text(l10n.editTripName),
                      content: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: l10n.tripNameLabel,
                          border: const OutlineInputBorder(),
                        ),
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final newName = controller.text.trim();
                            if (newName.isNotEmpty && newName != trip.name) {
                              ref.read(tripControllerProvider.notifier).updateTripName(
                                  trip: trip,
                                  newName: newName,
                                  context: context,
                                );
                              Navigator.pop(context);
                            }
                          },
                          child: Text(l10n.save),
                        ),
                      ],
                    );
                  },
                );
              });
            },
          ),
        ],
      ),
      body: tripAsync.when(
        data: (trip) {
           return TabBarView(
             controller: _tabController,
             children: [
               TripOverviewView(trip: trip),
               FinanceGroupView(tripId: widget.tripId),
               PollListView(tripId: widget.tripId),
               TaskListView(tripId: widget.tripId),
             ],
           );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(l10n.errorWithDetails(err.toString()))),
      ),
      floatingActionButton: _tabController.index == 2
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/trip/${widget.tripId}/create-poll'),
              icon: const Icon(Icons.add),
              label: Text(l10n.createPoll),
            )
          : _tabController.index == 1
              ? FloatingActionButton.extended(
                  onPressed: () => context.push('/trip/${widget.tripId}/create-expense'),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addExpense),
                )
              : null,
    );
  }
}
