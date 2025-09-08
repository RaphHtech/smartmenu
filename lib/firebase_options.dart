import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCYV9DJo6tThQ0nb07AfNK7bY6Em9gxkpc',
    appId: '1:105003020632:web:c019fde610fc35723b352d',
    messagingSenderId: '105003020632',
    projectId: 'smartmenu-mvp',
    storageBucket: 'smartmenu-mvp.firebasestorage.app',
  );
}
