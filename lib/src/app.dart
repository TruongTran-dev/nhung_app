import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/l10n/app_localizations/app_localizations.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:expensive_management/src/shared/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:expensive_management/app/app_colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyWalletApp extends StatefulWidget {
  final navKey = GlobalKey<NavigatorState>();

  MyWalletApp({super.key});

  @override
  State<MyWalletApp> createState() => _MyWalletAppState();
}

class _MyWalletAppState extends State<MyWalletApp> {
  // FirebaseMessagingServices notificationService = FirebaseMessagingServices();

  @override
  void initState() {
    super.initState();
    serviceLocator<NotificationService>().initialize(onPermissionGranted: (isGranted) {
      if (isGranted) {
        // Handle permission granted
        debugPrint('Notification permission granted');
      } else {
        // Handle permission denied
        debugPrint('Notification permission denied');
      }
    });
    // notificationService.initLocalNotifications();
    // notificationService.initializedNotification();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      primaryColorDark: const Color(0xff4d6e4b),
      primaryColorLight: const Color(0xFFb5ccb5),
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: const Color.fromARGB(255, 26, 26, 26),
            displayColor: const Color.fromARGB(255, 26, 26, 26),
          ),
      colorScheme: ThemeData().colorScheme.copyWith(
            primary: Colors.grey,
            secondary: const Color(0xffe6e6e6),
            error: const Color(0xFFCA0000),
            surface: Colors.grey[200],
          ),
    );
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: Locale('vi'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'My Wallet App',
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(secondary: Colors.white),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
