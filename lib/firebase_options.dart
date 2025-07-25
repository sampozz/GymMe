// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBKRtiW91yMGEzyKIIPqbV4PuQLygE0N3w',
    appId: '1:686682370976:web:ffcac58dbb1aaa2ff3eac5',
    messagingSenderId: '686682370976',
    projectId: 'dima-app-ea636',
    authDomain: 'dima-app-ea636.firebaseapp.com',
    storageBucket: 'dima-app-ea636.firebasestorage.app',
    measurementId: 'G-P09EWTKR1M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQ4gfd2YAxLMgL9AaJ9qbKFcsiQ3Jg4ZY',
    appId: '1:686682370976:android:80a8916e6650cdf4f3eac5',
    messagingSenderId: '686682370976',
    projectId: 'dima-app-ea636',
    storageBucket: 'dima-app-ea636.firebasestorage.app',
  );
}