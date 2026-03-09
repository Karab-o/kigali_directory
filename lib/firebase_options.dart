
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
[FirebaseOptions] 


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
    apiKey: 'AIzaSyBs55oP-IvlQ2iIYE_OhVRXTH-7-QHRAYs',
    appId: '1:704702761161:web:c75bce82d0a5153f69a518',
    messagingSenderId: '704702761161',
    projectId: 'indivassign2',
    authDomain: 'indivassign2.firebaseapp.com',
    storageBucket: 'indivassign2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAUNkgS23rTo-pi5-_6TVDqsEDrQAVfQi4',
    appId: '1:704702761161:android:00a26d0c2c2ca49769a518',
    messagingSenderId: '704702761161',
    projectId: 'indivassign2',
    storageBucket: 'indivassign2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC8Rl3P98gnVu2nil2BoFmSVvVYT00j22Q',
    appId: '1:704702761161:ios:d18f8ecb6e53121a69a518',
    messagingSenderId: '704702761161',
    projectId: 'indivassign2',
    storageBucket: 'indivassign2.firebasestorage.app',
    iosBundleId: 'com.example.individualAssignment2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC8Rl3P98gnVu2nil2BoFmSVvVYT00j22Q',
    appId: '1:704702761161:ios:d18f8ecb6e53121a69a518',
    messagingSenderId: '704702761161',
    projectId: 'indivassign2',
    storageBucket: 'indivassign2.firebasestorage.app',
    iosBundleId: 'com.example.individualAssignment2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBs55oP-IvlQ2iIYE_OhVRXTH-7-QHRAYs',
    appId: '1:704702761161:web:aeb9c0a133e17ea569a518',
    messagingSenderId: '704702761161',
    projectId: 'indivassign2',
    authDomain: 'indivassign2.firebaseapp.com',
    storageBucket: 'indivassign2.firebasestorage.app',
  );
}
