import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_pallete.dart';
import 'circle_controller.dart';
import 'package:cocircle/l10n/app_localizations.dart';
class CircleDetailScreen extends ConsumerWidget {
  final String circleId;
  const CircleDetailScreen({super.key, required this.circleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circleAsync = ref.watch(circleDetailsProvider(circleId));

    return Scaffold(
      appBar: AppBar(
        title: circleAsync.when(
          data: (circle) => Text(circle.name),
          loading: () => Text(AppLocalizations.of(context)!.loading),
          error: (_, __) => Text(AppLocalizations.of(context)!.error),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), 
            onPressed: () => context.push('/circle/$circleId/settings'),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push('/circle/$circleId/trips'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(Icons.flight, color: Theme.of(context).primaryColor, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.tripsAndEvents,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push('/circle/$circleId/shopping-lists'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    child: const Icon(Icons.shopping_cart, color: Colors.teal, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Shopping Lists',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   ListTile(
                     leading: const Icon(Icons.flight),
                     title: Text(AppLocalizations.of(context)!.planATrip),
                     onTap: () {
                       Navigator.pop(ctx);
                       context.push('/circle/$circleId/create-trip');
                     },
                   ),
                   ListTile(
                     leading: const Icon(Icons.shopping_cart),
                     title: const Text('Create Shopping List'),
                     onTap: () {
                       Navigator.pop(ctx);
                       context.push('/circle/$circleId/create-shopping-list');
                     },
                   ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
