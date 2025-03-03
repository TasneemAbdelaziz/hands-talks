import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNoitifaction();
  await NotificationService.instance.showNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

class NotificationService{

  NotificationService._();
  static final NotificationService instance = NotificationService._();
bool isFlutterLocalNotificationsInitialized = false;
  FirebaseMessaging Fmessaging = FirebaseMessaging.instance;
  final localNotification = FlutterLocalNotificationsPlugin();

Future<void> initialize() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await requestPermission();
  await _setupMessageHandlers();
  final token = await Fmessaging.getToken();
  print('FCM Token: $token');
}
  Future<void> requestPermission() async{
  NotificationSettings settings = await Fmessaging.requestPermission(
  alert: true,
  announcement: false,
  badge: true,
  carPlay: false,
  criticalAlert: false,
  provisional: false,
  sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
}

Future<void> setupFlutterNoitifaction()async{
    if(isFlutterLocalNotificationsInitialized){
      return;
    }

    const channel =  AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );


    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await localNotification
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid=AndroidInitializationSettings('@mipmap/ic_launcher');
    // ios step
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestProvisionalPermission: false,
    );

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    localNotification.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print("Notification clicked: ${response.payload}");
      },
    );

    isFlutterLocalNotificationsInitialized = true;





}


Future<void> showNotification(RemoteMessage message)async{
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if(notification != null && android !=null){
     await localNotification.show(notification.hashCode, notification.title, notification.body, NotificationDetails(
       android: AndroidNotificationDetails(
         'high_importance_channel', // id
         'High Importance Notifications', // title
         channelDescription:
         'This channel is used for important notifications.', // description
         importance: Importance.high,
         priority: Priority.high,
         icon: '@mipmap/ic_launcher',
       ),
       iOS: const DarwinNotificationDetails(
         presentAlert: true,
         presentBadge: true,
         presentSound: true,
       ),
     ),
     payload: message.data.toString(),
     );
    }

}

Future<void> _setupMessageHandlers() async {
  FirebaseMessaging.onMessage.listen((message) {
    showNotification(message);
  });


  FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

  final initialMessage = await Fmessaging.getInitialMessage();
  if (initialMessage != null) {
    _handleBackgroundMessage(initialMessage);
  }

}
void _handleBackgroundMessage(RemoteMessage message) {
  if (message.data['type'] == 'chat') {
    // open chat screen
  }
}

}