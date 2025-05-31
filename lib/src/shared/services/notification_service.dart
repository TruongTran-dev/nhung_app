import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:expensive_management/firebase_options.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // This function is called when the app is in the background and a notification is tapped
  final data = json.decode(notificationResponse.payload!) as Map<String, dynamic>;
  debugPrint('Notification tapped in background: $data');
  NotificationService().onNotificationTap?.call(data);
}

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Android notification channel
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    showBadge: true,
  );

  String? _token;
  String? get token => _token;

  // Notification handlers
  Function(Map<String, dynamic>)? onNotificationTap;

  /// Initialize the notification service
  Future<void> initialize({
    Function(bool)? onPermissionGranted,
  }) async {
    await requestNotificationPermissions(onPermissionGranted);
    await _initializeLocalNotifications();
    _token = await _getDeviceToken();
    _registerTokenRefresh();
    await _setupFirebaseMessaging();
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  /// Configure Firebase Messaging
  Future<void> _setupFirebaseMessaging() async {
    // Set foreground notification presentation options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle notification when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification when app is in background or terminated and user taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification clicked from background: ${message.data}');
      _handleNotificationData(message.data);
    });

    // Check if app was opened from a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App started from notification: ${initialMessage.data}');
      _handleNotificationData(initialMessage.data);
    }
  }

  /// Handle incoming foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received a message while in the foreground!');
    if (message.notification != null) {
      _handleDataPayload(message.data);
      RemoteNotification? notification = message.notification;
      // AndroidNotification? android = notification?.android;
      AppleNotification? apple = notification?.apple;
      print('Apple Notification: '
          '${apple?.imageUrl}, '
          '${apple?.badge}, ${apple?.subtitle}, ${apple?.subtitleLocArgs}'
          '${apple?.subtitleLocKey} ${apple?.sound}');
      if (notification != null) {
        AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
          "remote_message",
          "remote_message",
          channelDescription: "Remote message description",
          importance: Importance.high,
        );
        DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.timeSensitive,
        );
        if (apple?.imageUrl != null && apple!.imageUrl!.isNotEmpty) {
          final String bigPicturePath = await _downloadAndSaveFile(apple.imageUrl!, "bigPicture.jpg");
          darwinNotificationDetails = DarwinNotificationDetails(
            interruptionLevel: InterruptionLevel.timeSensitive,
            attachments: [
              DarwinNotificationAttachment(
                bigPicturePath,
                hideThumbnail: false,
              )
            ],
          );
        }
        showLocalNotification(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body, // Use the body from the notification object
          androidNotificationDetails: androidNotificationDetails,
          darwinNotificationDetails: darwinNotificationDetails,
          payload: json.encode(message.data),
        );
      }
    }
  }

  void showLocalNotification({
    required int id,
    String? title,
    String? body,
    AndroidNotificationDetails? androidNotificationDetails,
    DarwinNotificationDetails? darwinNotificationDetails,
    String payload = "",
  }) {
    _localNotifications.show(
      id,
      title, // Use the title from the notification object
      body, // Use the body from the notification object
      NotificationDetails(android: androidNotificationDetails, iOS: darwinNotificationDetails),
      payload: payload,
    );
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String filePath = '${dir.path}/$fileName';
    final resonse = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(resonse.bodyBytes);
    return filePath;
  }

  void _handleDataPayload(Map<String, dynamic> data) {
    // Process the data payload
    print('Data payload: $data');
    // Add your custom logic here to handle the data payload
  }

  /// Handle notification tap
  void _handleNotificationTap(NotificationResponse response) {
    try {
      if (response.payload != null) {
        final data = json.decode(response.payload!) as Map<String, dynamic>;
        _handleNotificationData(data);
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  /// Process notification data
  void _handleNotificationData(Map<String, dynamic> data) {
    onNotificationTap?.call(data);
  }

  /// Get the device token
  Future<String?> _getDeviceToken() async {
    // For iOS, first check if we have an APNS token
    if (Platform.isIOS) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null) {
        debugPrint('APNS token not available yet. FCM token request will be deferred.');
        return null;
      }
    }
    _token = await _messaging.getToken();
    debugPrint('Device token: $_token');
    return _token;
  }

  /// Register for token refreshes
  void _registerTokenRefresh() {
    _messaging.onTokenRefresh.listen((String token) {
      _token = token;
      debugPrint('FCM token refreshed: $token');
      // You can add a callback here to send the token to your server
    });
  }

  /// Get the current token or request a new one
  Future<String?> getToken() async {
    return _token ?? await _getDeviceToken();
  }

  Future<void> requestNotificationPermissions(
    Function(bool)? onPermissionGranted,
  ) async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );
    bool? isGrantedNotificationPermission = false;
    if (Platform.isIOS) {
      final iOSImplement =
          _localNotifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      isGrantedNotificationPermission = await iOSImplement?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      isGrantedNotificationPermission = await androidImplementation?.requestNotificationsPermission();
    }
    // onPermissionGranted?.call(isGrantedNotificationPermission ?? false);
    // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
    GlobalExtensions.tryCatch(() async {
      if (Platform.isIOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null) {
          onPermissionGranted?.call(isGrantedNotificationPermission ?? false);
        }
      } else {
        onPermissionGranted?.call(isGrantedNotificationPermission ?? false);
      }
    }, onError: (e) {
      log("Error get APNS token: $e");
    });
  }
}
