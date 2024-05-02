// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDIe1TKx5_tKKD5JYISi-hUiRNPuUjqGHY',
    appId: '1:587973743901:web:ac2903fc8c0398fa2b3df4',
    messagingSenderId: '587973743901',
    projectId: 'cobuilder-48773',
    authDomain: 'cobuilder-48773.firebaseapp.com',
    storageBucket: 'cobuilder-48773.appspot.com',
    measurementId: 'G-GQ8L4RJ2FN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAlzfRumqsg5JqTEnHbS-NpVlgbSGr41wY',
    appId: '1:587973743901:android:0b8ca383fe5038bc2b3df4',
    messagingSenderId: '587973743901',
    projectId: 'cobuilder-48773',
    storageBucket: 'cobuilder-48773.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC1ICDYfZ9n2PwW0ICUfwF8EEAe6KqoP5M',
    appId: '1:587973743901:ios:be51f161a77e77092b3df4',
    messagingSenderId: '587973743901',
    projectId: 'cobuilder-48773',
    storageBucket: 'cobuilder-48773.appspot.com',
    iosBundleId: 'com.example.namerApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC1ICDYfZ9n2PwW0ICUfwF8EEAe6KqoP5M',
    appId: '1:587973743901:ios:0e96c7c248836b062b3df4',
    messagingSenderId: '587973743901',
    projectId: 'cobuilder-48773',
    storageBucket: 'cobuilder-48773.appspot.com',
    iosBundleId: 'com.example.namerApp.RunnerTests',
  );
}