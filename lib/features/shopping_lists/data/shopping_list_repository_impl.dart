import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../domain/shopping_list_model.dart';
import '../domain/shopping_list_repository.dart';

class ShoppingListRepositoryImpl implements ShoppingListRepository {
  final FirebaseFirestore _firestore;

  ShoppingListRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, ShoppingListModel>> createShoppingList(ShoppingListModel shoppingList) async {
    try {
      await _firestore.collection('shopping_lists').doc(shoppingList.id).set(shoppingList.toJson());
      return right(shoppingList);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateShoppingList(ShoppingListModel shoppingList) async {
    try {
      await _firestore.collection('shopping_lists').doc(shoppingList.id).update(shoppingList.toJson());
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteShoppingList(String listId) async {
    try {
      final batch = _firestore.batch();
      
      final listRef = _firestore.collection('shopping_lists').doc(listId);
      batch.delete(listRef);

      final itemsSnapshot = await _firestore.collection('shopping_items').where('listId', isEqualTo: listId).get();
      for (final doc in itemsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<ShoppingListModel>> getShoppingListsStream(String circleId) {
    return _firestore
        .collection('shopping_lists')
        .where('circleId', isEqualTo: circleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ShoppingListModel.fromJson(doc.data())).toList());
  }

  @override
  Future<Either<Failure, ShoppingItemModel>> createShoppingItem(ShoppingItemModel item) async {
    try {
      await _firestore.collection('shopping_items').doc(item.id).set(item.toJson());
      return right(item);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteShoppingItem(String itemId) async {
    try {
      await _firestore.collection('shopping_items').doc(itemId).delete();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markItemComplete({
    required String itemId,
    required String userId,
    required DateTime completedAt,
  }) async {
    try {
      await _firestore.collection('shopping_items').doc(itemId).update({
        'isCompleted': true,
        'completedBy': userId,
        'completedAt': Timestamp.fromDate(completedAt),
      });
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<ShoppingItemModel>> getShoppingItemsStream(String listId) {
    return _firestore
        .collection('shopping_items')
        .where('listId', isEqualTo: listId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ShoppingItemModel.fromJson(doc.data())).toList());
  }
}
