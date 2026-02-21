import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  // Test IDs from Google
  static String get bannerAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    }
    // Replace with real IDs for production
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Placeholder
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Placeholder
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get nativeAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/2247696110';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/3986624511';
      }
    }
    // Replace with real IDs for production
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/2247696110'; // Placeholder
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3986624511'; // Placeholder
    }
    throw UnsupportedError('Unsupported platform');
  }
}
