import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cocircle/features/shopping_lists/presentation/shopping_list_controller.dart';

class CircleShoppingListsScreen extends ConsumerWidget {
  final String circleId;
  const CircleShoppingListsScreen({super.key, required this.circleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Lists'),
      ),
      body: ref.watch(circleShoppingListsProvider(circleId)).when(
        data: (lists) {
          if (lists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey),
                   const SizedBox(height: 16),
                   Text('No shopping lists yet', style: Theme.of(context).textTheme.titleMedium),
                   const SizedBox(height: 8),
                   ElevatedButton(
                     onPressed: () => context.push('/circle/$circleId/create-shopping-list'),
                     child: const Text('Create Shopping List'),
                   )
                ],
              ),
            );
          }
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: lists.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final list = lists[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                     context.push('/shopping-list/${list.id}', extra: list);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          list.name, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            DateFormat.yMMMd().format(list.createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/circle/$circleId/create-shopping-list');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
