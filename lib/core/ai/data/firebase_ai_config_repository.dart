import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_config_model.dart';

class FirebaseAiConfigRepository {
  final FirebaseFirestore _firestore;

  FirebaseAiConfigRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream real-time AI configuration updates from Cloud Firestore
  Stream<AiConfigModel> watchAiConfig() {
    return _firestore.collection('config').doc('ai_config').snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists || snapshot.data() == null) {
        return AiConfigModel.empty();
      }
      return AiConfigModel.fromJson(snapshot.data()!);
    });
  }

  /// Get current AI configuration once
  Future<AiConfigModel> getAiConfig() async {
    try {
      final doc = await _firestore.collection('config').doc('ai_config').get();
      if (!doc.exists || doc.data() == null) {
        return AiConfigModel.empty();
      }
      return AiConfigModel.fromJson(doc.data()!);
    } catch (_) {
      return AiConfigModel.empty();
    }
  }

  /// Update AI Config in Firebase (e.g. for Admin/Developer settings panel)
  Future<void> updateAiConfig(AiConfigModel config) async {
    await _firestore
        .collection('config')
        .doc('ai_config')
        .set(config.toJson(), SetOptions(merge: true));
  }

  /// Ensure the dev Firestore has a valid `config/ai_config` document created if missing.
  Future<void> ensureDevAiConfigSeeded() async {
    final docRef = _firestore.collection('config').doc('ai_config');
    final doc = await docRef.get();
    if (!doc.exists) {
      final defaultConfig = AiConfigModel.empty();
      await docRef.set(defaultConfig.toJson(), SetOptions(merge: true));
    }
  }
}

final firebaseAiConfigRepositoryProvider = Provider<FirebaseAiConfigRepository>(
  (ref) {
    return FirebaseAiConfigRepository();
  },
);

final aiConfigStreamProvider = StreamProvider<AiConfigModel>((ref) {
  final repository = ref.watch(firebaseAiConfigRepositoryProvider);
  return repository.watchAiConfig();
});
