import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBrQyDO1z2xNefx-cEP3RwyphGk3BuM-68',
    appId: '1:1050392308457:web:901b45a29139c236e55e78',
    messagingSenderId: '1050392308457',
    projectId: 'tankmaster-a0155',
    authDomain: 'tankmaster-a0155.firebaseapp.com',
    databaseURL: 'https://tankmaster-a0155-default-rtdb.firebaseio.com',
    storageBucket: 'tankmaster-a0155.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrQyDO1z2xNefx-cEP3RwyphGk3BuM-68',
    appId: '1:1050392308457:android:901b45a29139c236e55e78',
    messagingSenderId: '1050392308457',
    projectId: 'tankmaster-a0155',
    databaseURL: 'https://tankmaster-a0155-default-rtdb.firebaseio.com',
    storageBucket: 'tankmaster-a0155.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBrQyDO1z2xNefx-cEP3RwyphGk3BuM-68',
    appId: '1:1050392308457:ios:901b45a29139c236e55e78',
    messagingSenderId: '1050392308457',
    projectId: 'tankmaster-a0155',
    databaseURL: 'https://tankmaster-a0155-default-rtdb.firebaseio.com',
    storageBucket: 'tankmaster-a0155.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBrQyDO1z2xNefx-cEP3RwyphGk3BuM-68',
    appId: '1:1050392308457:ios:901b45a29139c236e55e78',
    messagingSenderId: '1050392308457',
    projectId: 'tankmaster-a0155',
    databaseURL: 'https://tankmaster-a0155-default-rtdb.firebaseio.com',
    storageBucket: 'tankmaster-a0155.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBrQyDO1z2xNefx-cEP3RwyphGk3BuM-68',
    appId: '1:1050392308457:web:901b45a29139c236e55e78',
    messagingSenderId: '1050392308457',
    projectId: 'tankmaster-a0155',
    databaseURL: 'https://tankmaster-a0155-default-rtdb.firebaseio.com',
    storageBucket: 'tankmaster-a0155.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyBrQyDO1z2xNefx-cEP3RwyphGk3BuM-68',
    appId: '1:1050392308457:web:901b45a29139c236e55e78',
    messagingSenderId: '1050392308457',
    projectId: 'tankmaster-a0155',
    databaseURL: 'https://tankmaster-a0155-default-rtdb.firebaseio.com',
    storageBucket: 'tankmaster-a0155.firebasestorage.app',
  );
}