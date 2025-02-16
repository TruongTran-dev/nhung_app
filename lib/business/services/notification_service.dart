import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingServices {
  //initialising firebase message plugin
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //initialising local notification plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  String fcmToken = '';

  Future<void> initializedNotification() async {
    // Local Notification Initialized
    // initLocalNotifications;
    requestNotificationPermission;
    fcmToken = await getDeviceToken();

    ///for app terminated state & user click notification
    messaging.getInitialMessage().then((message) {
      if (message != null) {
        // handler notification
        debugPrint(message.toString());
        _openNotification(message.data);
      }
    });

    ///for app
    FirebaseMessaging.onMessage.listen((message) async {
      await messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
      initLocalNotifications;
      print('message: ${message.toString()}');
      showNotification(message);
    });

    ///for app in background && not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.notification != null) {
        //handel notification
        // showNotification(message);
        _openNotification(message.data);
      }
    });
  }

  //function to get device token on which we will send the notifications
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    print('deviceToken: $token');
    return token!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print('refresh');
      }
    });
  }

  ///function to initialise flutter local notification plugin to show notifications when app is active
  void initLocalNotifications() async {
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting =
        InitializationSettings(android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      // onDidReceiveNotificationResponse: (payload) {
      //   // handle interaction when app is active
      //   print('payload: ${payload.toString()}');
      // },
      // onDidReceiveBackgroundNotificationResponse: _localBackgroundHandlers,
    );
  }

  ///for request app permission to show notification
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('user granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('user granted provisional permission');
    } else {
      //appsetting.AppSettings.openNotificationSettings();
      debugPrint('user denied permission');
    }
  }

  // function to show visible notification when app is active
  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    AndroidNotificationChannel androidNotificationChannel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for importance notifications.',
      importance: Importance.high,
      showBadge: true,
      // playSound: true,
      // sound: RawResourceAndroidNotificationSound('jetsons_doorbell'),
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      androidNotificationChannel.id,
      androidNotificationChannel.name,
      channelDescription: androidNotificationChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      // playSound: true,
      ticker: 'ticker',
      // sound: androidNotificationChannel.sound,
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails, iOS: darwinNotificationDetails);

    await Future.delayed(Duration.zero, () {
      if (notification != null) {
        _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails,
          payload: json.encode(message.data),
        );
      }
    });
  }

  // Future<void> _localBackgroundHandlers(NotificationResponse data) async {
  //   try {
  //     var payloadObj = json.decode(data.payload ?? "{}") as Map? ?? {};
  //     _openNotification(payloadObj);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  void _openNotification(Map payloadObj) async {
    await Future.delayed(const Duration(milliseconds: 300));
    //handler open screen from notification hear
    // try {
    //   if (payloadObj.isNotEmpty) {
    //     switch (payloadObj["page"] as String? ?? "") {
    //       case "detail":
    //         navigatorKey.currentState?.push(MaterialPageRoute(
    //             builder: (context) => DetailView(nObj: payloadObj)));
    //         break;
    //       case "data":
    //         navigatorKey.currentState?.push(MaterialPageRoute(
    //             builder: (context) => DataView(nObj: payloadObj)));
    //         break;
    //       default:
    //     }
    //   }
    // } catch (e) {
    //   print(e);
    // }
  }
}
