import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'widgets/finance_group_view.dart';
import '../../polls/presentation/poll_list_view.dart';
import '../../tasks/presentation/task_list_view.dart';
import 'trip_controller.dart';
import 'trip_plan_tab.dart';
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
            const Tab(text: 'Plan', icon: Icon(Icons.explore_outlined)),
            Tab(text: l10n.finance, icon: const Icon(Icons.payments_outlined)),
            Tab(text: l10n.polls, icon: const Icon(Icons.poll_outlined)),
            const Tab(text: 'Tasks', icon: Icon(Icons.task_alt_outlined)),
          ],
        ),
        actions: [
          tripAsync.when(
            data: (trip) => PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
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
                } else if (value == 'toggleActive') {
                  ref.read(tripControllerProvider.notifier).toggleTripActive(
                    trip: trip,
                    context: context,
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined),
                        const SizedBox(width: 8),
                        Text(l10n.editTripName),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'toggleActive',
                    child: Row(
                      children: [
                        Icon(trip.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        const SizedBox(width: 8),
                        Text(trip.isActive ? 'Mark as Inactive' : 'Mark as Active'),
                      ],
                    ),
                  ),
                ];
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: tripAsync.when(
        data: (trip) {
           return TabBarView(
             controller: _tabController,
             children: [
               TripPlanTab(tripId: widget.tripId),
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
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton(
                onPressed: () => context.push('/trip/${widget.tripId}/create-poll'),
                child: const Icon(Icons.add),
              ),
            )
          : _tabController.index == 1
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: FloatingActionButton(
                    onPressed: () => context.push('/trip/${widget.tripId}/create-expense'),
                    child: const Icon(Icons.add),
                  ),
                )
              : null,
    );
  }
}

