import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import 'injection.dart';
import 'presentation/core/app_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  configureInjection(Environment.prod);
  runApp(AppWidget());
}

/**
 * IMPORTANTE: DOCUMENTACION VARIADA:
 * https://firebase.google.com/docs/auth/android/google-signin?authuser=0&hl=es#kotlin+ktx
 * https://developers.google.com/android/guides/client-auth
 * https://api.flutter.dev/flutter/dart-core/Error/safeToString.html
 * https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithEmailAndPassword.html
 * https://stackoverflow.com/questions/63492211/no-firebase-app-default-has-been-created-call-firebase-initializeapp-in
 * 
 * Error de Flutter: No se puede llamar al método 'addPostFrameCallback' en 'SchedulerBinding?' porque es potencialmente nulo:
 * https://stackoverflow.com/questions/72232062/flutter-error-method-addpostframecallback-cannot-be-called-on-schedulerbindi
 */
