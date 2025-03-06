// // import 'dart:convert';
// // import 'dart:developer';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// // import 'package:hands_talks/Firebase_Utils/send_notification_service.dart';
// // import 'package:hands_talks/main.dart';
// //
// // class MessagingConfig {
// //   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// //   FlutterLocalNotificationsPlugin();
// //
// //   static Future<void> createNotificationChannel() async {
// //     const AndroidNotificationChannel channel = AndroidNotificationChannel(
// //       'high_importance_channel',
// //       'High Importance Notifications',
// //       description: 'This channel is used for important notifications.',
// //       importance: Importance.max, // Remove the `sound` field
// //     );
// //
// //     await flutterLocalNotificationsPlugin
// //         .resolvePlatformSpecificImplementation<
// //         AndroidFlutterLocalNotificationsPlugin>()
// //         ?.createNotificationChannel(channel);
// //   }
// //
// //   static Future<void> initFirebaseMessaging() async {
// //     await createNotificationChannel();
// //
// //     FirebaseMessaging messaging = FirebaseMessaging.instance;
// //
// //     NotificationSettings settings = await messaging.requestPermission(
// //       alert: true,
// //       announcement: false,
// //       badge: true,
// //       carPlay: false,
// //       criticalAlert: false,
// //       provisional: false,
// //       sound: true,
// //     );
// //
// //     const AndroidInitializationSettings initializationSettingsAndroid =
// //     AndroidInitializationSettings('@mipmap/ic_launcher');
// //
// //     const DarwinInitializationSettings initializationSettingsIOS =
// //     DarwinInitializationSettings(
// //       requestSoundPermission: false,
// //       requestBadgePermission: false,
// //       requestAlertPermission: false,
// //     );
// //
// //     const InitializationSettings initializationSettings =
// //     InitializationSettings(
// //       android: initializationSettingsAndroid,
// //       iOS: initializationSettingsIOS,
// //     );
// //
// //     await flutterLocalNotificationsPlugin.initialize(
// //       initializationSettings,
// //       onDidReceiveNotificationResponse: (NotificationResponse payload) {
// //         log("payload1: ${payload.payload.toString()}");
// //         return;
// //       },
// //     );
// //
// //     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
// //       log('User granted permission');
// //     } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
// //       log('User granted provisional permission');
// //     } else {
// //       log('User declined or has not accepted permission');
// //     }
// //
// //     FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
// //       log("message received");
// //       try {
// //         RemoteNotification? notification = event.notification;
// //         AndroidNotification? android = event.notification?.android;
// //         log(notification!.body.toString());
// //         log(notification.title.toString());
// //
// //         var body = notification.body;
// //
// //         await flutterLocalNotificationsPlugin.show(
// //           notification.hashCode,
// //           notification.title,
// //           body,
// //           NotificationDetails(
// //             android: AndroidNotificationDetails(
// //               'high_importance_channel',
// //               'High Importance Notifications',
// //               channelDescription:
// //               'This channel is used for important notifications.',
// //               icon: '@mipmap/ic_launcher', // Remove the `sound` field
// //             ),
// //             iOS: const DarwinNotificationDetails(
// //               presentAlert: true,
// //               presentBadge: true,
// //               presentSound: true, // Enable default sound on iOS
// //             ),
// //           ),
// //         );
// //
// //         handleNotification(navigatorKey.currentContext!, event.data);
// //       } catch (err) {
// //         log(err.toString());
// //       }
// //     });
// //
// //     FirebaseMessaging.instance
// //         .getInitialMessage()
// //         .then((RemoteMessage? message) {
// //       if (message != null) {
// //         handleNotification(navigatorKey.currentContext!, message.data);
// //       }
// //     });
// //
// //     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
// //       handleNotification(navigatorKey.currentContext!, message.data);
// //     });
// //   }
// //
// //   @pragma('vm:entry-point')
// //   static Future<void> messageHandler(RemoteMessage message) async {
// //     log('background message ${message.notification!.body}');
// //   }
// // }
//
// import 'dart:convert';
// import 'dart:developer';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hands_talks/Firebase_Utils/send_notification_service.dart';
// import 'package:hands_talks/main.dart';
//
// class MessagingConfig {
//   static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   /// ✅ Create notification channel
//   static Future<void> createNotificationChannel() async {
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'high_importance_channel',
//       'High Importance Notifications',
//       description: 'This channel is used for important notifications.',
//       importance: Importance.max,
//     );
//
//     await _localNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//   }
//
//   /// ✅ Initialize Firebase Messaging
//   static Future<void> initFirebaseMessaging() async {
//     await createNotificationChannel();
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     const AndroidInitializationSettings androidInit =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//     const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
//     const InitializationSettings initSettings =
//     InitializationSettings(android: androidInit, iOS: iosInit);
//
//     await _localNotificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse payload) {
//         log("🔔 Notification Clicked: ${payload.payload}");
//       },
//     );
//
//     /// ✅ Handle Foreground Messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
//       log("📩 Message Received: ${event.notification?.title}");
//
//       RemoteNotification? notification = event.notification;
//       if (notification != null) {
//         _showLocalNotification(notification);
//         _saveNotificationToFirestore(notification);
//       }
//     });
//
//     /// ✅ Handle Terminated State
//     FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
//       if (message != null) {
//         handleNotification(navigatorKey.currentContext!, message.data);
//       }
//     });
//
//     /// ✅ Handle Background Clicks
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       handleNotification(navigatorKey.currentContext!, message.data);
//     });
//   }
//
//   /// ✅ Show Local Notification
//   static Future<void> _showLocalNotification(RemoteNotification notification) async {
//     await _localNotificationsPlugin.show(
//       notification.hashCode,
//       notification.title,
//       notification.body,
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           'high_importance_channel',
//           'High Importance Notifications',
//           channelDescription: 'Used for important notifications.',
//           icon: '@mipmap/ic_launcher',
//         ),
//         iOS: const DarwinNotificationDetails(),
//       ),
//     );
//   }
//
//   /// ✅ Save Notification to Firestore
//   static Future<void> _saveNotificationToFirestore(RemoteNotification notification) async {
//     await FirebaseFirestore.instance.collection('notifications').add({
//       'title': notification.title,
//       'body': notification.body,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/Firebase_Utils/send_notification_service.dart';
import 'package:hands_talks/main.dart';

class MessagingConfig {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Create notification channel
  static Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Initialize Firebase Messaging
  static Future<void> initFirebaseMessaging() async {
    await createNotificationChannel();
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse payload) {
        log("Notification Clicked: ${payload.payload}");
      },
    );

    ///  Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      log("Message Received: ${event.notification?.title}");

      RemoteNotification? notification = event.notification;
      if (notification != null) {
        _showLocalNotification(notification);
      }
    });

    ///  Handle Terminated State
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        handleNotification(navigatorKey.currentContext!, message.data);
      }
    });

    ///  Handle Background Clicks
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotification(navigatorKey.currentContext!, message.data);
    });
  }

  /// Show Local Notification
  static Future<void> _showLocalNotification(RemoteNotification notification) async {
    await _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Used for important notifications.',
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
