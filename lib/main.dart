import 'package:expensive_management/app/app_routes.dart';
import 'package:expensive_management/business/services/firebase_options.dart';
import 'package:expensive_management/business/services/notification_service.dart';
import 'package:expensive_management/utils/shared_preferences_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

@pragma('vm:entry-point')
Future<void> _backgroundHandlerMessaging(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //TODO: recheck noti on bg
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseMessaging.onBackgroundMessage(_backgroundHandlerMessaging);
  // await FirebaseMessagingServices().initializedNotification();

  // Init SharedPreferences storage
  await SharedPreferencesStorage.init();

  runApp(MyApp());
}

bool _checkIsLoggedIn() {
  bool isLoggedOut = SharedPreferencesStorage().getLoggedOutStatus();
  bool isExpired = true;
  String passwordExpiredTime =
      SharedPreferencesStorage().getAccessTokenExpired();

  if (passwordExpiredTime.isNotEmpty) {
    try {
      if (DateTime.parse(passwordExpiredTime).isAfter(DateTime.now())) {
        isExpired = false;
      }
    } catch (_) {
      return false;
    }

    if (!isExpired) {
      if (isLoggedOut) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  } else {
    return false;
  }
}

class MyApp extends StatefulWidget {
  final navKey = GlobalKey<NavigatorState>();

  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // FirebaseMessagingServices notificationService = FirebaseMessagingServices();

  @override
  void initState() {
    super.initState();
    // notificationService.initLocalNotifications();
    // notificationService.initializedNotification();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color.fromARGB(255, 107, 154, 107),
      //#6B9A6B
      primaryColorDark: const Color(0xff4d6e4b),
      primaryColorLight: const Color(0xFFb5ccb5),
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: const Color.fromARGB(255, 26, 26, 26),
            displayColor: const Color.fromARGB(255, 26, 26, 26),
          ),
      colorScheme: ThemeData()
          .colorScheme
          .copyWith(
            primary: Colors.grey,
            secondary: const Color(0xffe6e6e6),
          )
          .copyWith(error: const Color(0xFFCA0000))
          .copyWith(background: Colors.grey[200]),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: widget.navKey,
      supportedLocales: const [Locale('en'), Locale('vi')],
      localizationsDelegates: const [
        // AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Viet Wallet App',
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(secondary: Colors.white),
      ),
      routes: AppRoutes().routes(context, isLoggedIn: _checkIsLoggedIn()),
    );
  }
}
