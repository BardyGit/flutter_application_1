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
    apiKey: 'AIzaSyDgmg67DHchF_UIgaa2FuKZVQRoYOMtV7Q',
    appId: '1:1026729856737:web:6cb3c70e67104581e671a0',
    messagingSenderId: '1026729856737',
    projectId: 'miaged-51d69',
    authDomain: 'miaged-51d69.firebaseapp.com',
    storageBucket: 'miaged-51d69.appspot.com',
    measurementId: 'G-9TJWVLBVPS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCDm3bfidMVlfM6F9NV0fCbjIm7SiTH6xo',
    appId: '1:1026729856737:android:5800a908df139e99e671a0',
    messagingSenderId: '1026729856737',
    projectId: 'miaged-51d69',
    storageBucket: 'miaged-51d69.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB3p_Jv58Lp3wSn09yNYOURFLy2WOqQwVU',
    appId: '1:1026729856737:ios:16120ef2afa8d979e671a0',
    messagingSenderId: '1026729856737',
    projectId: 'miaged-51d69',
    storageBucket: 'miaged-51d69.appspot.com',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB3p_Jv58Lp3wSn09yNYOURFLy2WOqQwVU',
    appId: '1:1026729856737:ios:d0da0e1ed199dc93e671a0',
    messagingSenderId: '1026729856737',
    projectId: 'miaged-51d69',
    storageBucket: 'miaged-51d69.appspot.com',
    iosBundleId: 'com.example.flutterApplication1.RunnerTests',
  );
}