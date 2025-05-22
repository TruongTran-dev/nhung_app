import 'dart:io';

import 'package:expensive_management/firebase_options.dart';
import 'package:expensive_management/src/app.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@pragma('vm:entry-point')
Future<void> _backgroundHandlerMessaging(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseMessaging.onBackgroundMessage(_backgroundHandlerMessaging);
  // await FirebaseMessagingServices().initializedNotification();


  // Configure dependencies injection
  await configureDependenciesInjection();

  // Set up SystemUI preferences
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: Platform.isAndroid ? [SystemUiOverlay.top, SystemUiOverlay.bottom] : [SystemUiOverlay.bottom],
  );
  runApp(MyWalletApp());
}
