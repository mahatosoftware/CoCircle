import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/snackbar.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../data/shopping_list_repository_impl.dart';
import '../domain/shopping_list_model.dart';
import '../domain/shopping_list_repository.dart';
import 'package:go_router/go_router.dart';

final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  return ShoppingListRepositoryImpl(FirebaseFirestore.instance);
});

class ShoppingListController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> createShoppingList({
    required String circleId,
    required String name,
    required BuildContext context,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;

    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      if(context.mounted) showSnackBar(context, 'User not logged in');
      return;
    }

    state = const AsyncLoading();
    final listId = const Uuid().v4();
    final list = ShoppingListModel(
      id: listId,
      circleId: circleId,
      name: trimmedName,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    final result = await ref.read(shoppingListRepositoryProvider).createShoppingList(list);
    result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        if(context.mounted) showSnackBar(context, failure.message);
      },
      (_) {
        state = const AsyncData(null);
        if(context.mounted) {
          showSnackBar(context, 'Shopping list created');
          context.pop();
        }
      },
    );
  }

  Future<void> updateShoppingList({
    required ShoppingListModel list,
    required BuildContext context,
  }) async {
    final result = await ref.read(shoppingListRepositoryProvider).updateShoppingList(list);
    result.fold(
      (failure) {
        if(context.mounted) showSnackBar(context, failure.message);
      },
      (_) {
        if(context.mounted) showSnackBar(context, 'Shopping list updated');
      },
    );
  }

  Future<void> deleteList({
    required String listId,
    required BuildContext context,
  }) async {
    final result = await ref.read(shoppingListRepositoryProvider).deleteShoppingList(listId);
    result.fold(
      (failure) {
        if(context.mounted) showSnackBar(context, failure.message);
      },
      (_) {
        if(context.mounted) showSnackBar(context, 'Shopping list deleted');
      },
    );
  }
}

final shoppingListControllerProvider = NotifierProvider<ShoppingListController, AsyncValue<void>>(ShoppingListController.new);

class ShoppingItemController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> createItem({
    required String listId,
    required String title,
    required double quantity,
    required String unit,
    required BuildContext context,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return;

    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      if(context.mounted) showSnackBar(context, 'User not logged in');
      return;
    }

    state = const AsyncLoading();
    final item = ShoppingItemModel(
      id: const Uuid().v4(),
      listId: listId,
      title: trimmedTitle,
      quantity: quantity,
      unit: unit,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    final result = await ref.read(shoppingListRepositoryProvider).createShoppingItem(item);
    result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        if(context.mounted) showSnackBar(context, failure.message);
      },
      (_) {
        state = const AsyncData(null);
        if(context.mounted) showSnackBar(context, 'Item added');
      },
    );
  }

  Future<void> deleteItem({
    required String itemId,
    required BuildContext context,
  }) async {
    final result = await ref.read(shoppingListRepositoryProvider).deleteShoppingItem(itemId);
    result.fold(
      (failure) {
        if(context.mounted) showSnackBar(context, failure.message);
      },
      (_) {
        if(context.mounted) showSnackBar(context, 'Item deleted');
      },
    );
  }

  Future<void> markItemComplete({
    required ShoppingItemModel item,
    required BuildContext context,
  }) async {
    if (item.isCompleted) return;

    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      if(context.mounted) showSnackBar(context, 'User not logged in');
      return;
    }

    final result = await ref.read(shoppingListRepositoryProvider).markItemComplete(
          itemId: item.id,
          userId: user.uid,
          completedAt: DateTime.now(),
        );

    result.fold(
      (failure) {
        if(context.mounted) showSnackBar(context, failure.message);
      },
      (_) {
        if(context.mounted) showSnackBar(context, 'Item completed');
      },
    );
  }
}

final shoppingItemControllerProvider = NotifierProvider<ShoppingItemController, AsyncValue<void>>(ShoppingItemController.new);

final circleShoppingListsProvider = StreamProvider.family<List<ShoppingListModel>, String>((ref, circleId) {
  return ref.watch(shoppingListRepositoryProvider).getShoppingListsStream(circleId);
});

final shoppingListItemsProvider = StreamProvider.family<List<ShoppingItemModel>, String>((ref, listId) {
  return ref.watch(shoppingListRepositoryProvider).getShoppingItemsStream(listId).map((items) {
    final sorted = List<ShoppingItemModel>.from(items)
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        if (!a.isCompleted && !b.isCompleted) {
          return b.createdAt.compareTo(a.createdAt);
        }
        final aTime = a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
    return sorted;
  });
});
