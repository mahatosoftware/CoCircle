import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import 'shopping_list_model.dart';

abstract class ShoppingListRepository {
  Future<Either<Failure, ShoppingListModel>> createShoppingList(ShoppingListModel shoppingList);
  Future<Either<Failure, void>> updateShoppingList(ShoppingListModel shoppingList);
  Future<Either<Failure, void>> deleteShoppingList(String listId);
  Stream<List<ShoppingListModel>> getShoppingListsStream(String circleId);

  Future<Either<Failure, ShoppingItemModel>> createShoppingItem(ShoppingItemModel item);
  Future<Either<Failure, void>> deleteShoppingItem(String itemId);
  Future<Either<Failure, void>> markItemComplete({
    required String itemId,
    required String userId,
    required DateTime completedAt,
  });
  Stream<List<ShoppingItemModel>> getShoppingItemsStream(String listId);
}
