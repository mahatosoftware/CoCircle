import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'environment.dart';

part 'firebase_providers.g.dart';

@Riverpod(keepAlive: true)
FirebaseDatabase firebaseDatabase(Ref ref) {
  final customUrl = AppEnvironment.databaseUrl;
  debugPrint("firebaseDatabaseProvider: resolved databaseURL = '$customUrl'");
  
  String? resolvedUrl = (customUrl != null && customUrl.isNotEmpty) ? customUrl : null;
  try {
    final options = Firebase.app().options;
    
    // Safety Guard: Verify the dynamic URL matches the initialized project ID
    if (resolvedUrl != null && options.projectId.isNotEmpty) {
      // Extract project identifier (e.g., 'cocircle-firebase-development' or 'cocircle-firebase-prod')
      final projectId = options.projectId;
      if (!resolvedUrl.contains(projectId)) {
        debugPrint("WARNING: Resolved databaseURL '$resolvedUrl' does not match initialized projectId '$projectId'. Falling back to Firebase options.");
        resolvedUrl = null; // force fallback
      }
    }
    
    resolvedUrl ??= options.databaseURL;
  } catch (e) {
    debugPrint("firebaseDatabaseProvider: Failed to get databaseURL from Firebase options: $e");
  }
  
  debugPrint("firebaseDatabaseProvider: using databaseURL = '$resolvedUrl'");
  
  if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: resolvedUrl,
    );
  }
  
  return FirebaseDatabase.instance;
}
