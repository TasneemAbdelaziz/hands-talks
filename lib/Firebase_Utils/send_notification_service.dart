import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hands_talks/Model/myUser.dart';
import 'package:hands_talks/message/chatpage.dart';
import 'package:hands_talks/message/messages_page.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

Future<String> getAccessToken() async {
  final jsonString = await rootBundle.loadString(
    'assets/notification_key/'
  );

  final accountCredentials =
  auth.ServiceAccountCredentials.fromJson(jsonString);

  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  final client = await auth.clientViaServiceAccount(accountCredentials, scopes);

  return client.credentials.accessToken.data;
}

Future<void> sendNotification({
  required MyUser user,
  required String token,
  required String title,
  required String body,
  required Map<String, String> data,
}) async {
  final String accessToken = await getAccessToken();
  final String fcmUrl =
      'https://fcm.googleapis.com/v1/projects/hands-talks-e581c/messages:send';

  final response = await http.post(
    Uri.parse(fcmUrl),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode(<String, dynamic>{
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': data, // Add custom data here

        'android': {
          'notification': {
            // Remove the "sound" field to use the default sound
            'click_action': 'FLUTTER_NOTIFICATION_CLICK', // Required for tapping to trigger response
            'channel_id': 'high_importance_channel'
          },
        },
        'apns': {
          'payload': {
            'aps': {
              // Remove the "sound" field to use the default sound
              'content-available': 1,
            },
          },
        },
      },
    }),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully');
  } else {
    print('Failed to send notification: ${response.body}');
  }
}


void handleNotification(BuildContext context, Map<String, dynamic> data) {
  print("Notification Clicked: $data");

  if (!data.containsKey("route") || !data.containsKey("user")) {
    print("Missing notification data.");
    return;
  }

  String route = data['route'].toString();
  MyUser user;

  try {
    user = data['user'] is String
        ? MyUser.fromJson(jsonDecode(data['user']))
        : MyUser.fromJson(data['user']);
  } catch (e) {
    print("Error parsing user data: $e");
    return;
  }

  if (route == ChatPage.routeName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(user: user)),
    );
  }
}
// //
// //
// //
// // //
// // // void handleNotification(BuildContext context, Map<String, dynamic> data) {
// // //   print("🔔 Notification Clicked: $data");
// // //
// // //   String route = data['route'];
// // //   String id = data['id'];
// // //   MyUser user = MyUser.fromJson(jsonDecode(data['user']));
// // //
// // //   if (route == ChatPage.routeName) {
// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(
// // //           builder: (context) => ChatPage(
// // //               user: user,
// // //               ),
// // //     ));
// // //   }
// // // }
// //
// // void handleNotification(BuildContext context, Map<String, dynamic> data) {
// //   print("🔔 Notification Clicked: $data");
// //
// //   if (!data.containsKey("route") || !data.containsKey("user")) {
// //     print("❌ Missing required notification data. Cannot navigate.");
// //     return;
// //   }
// //
// //   String route = data['route'].toString();
// //   String id = data['id'].toString();
// //
// //   dynamic userData = data['user']; // Can be a String or a Map
// //   MyUser? user;
// //
// //   try {
// //     user = userData is String
// //         ? MyUser.fromJson(jsonDecode(userData))  // Decode only if it's a string
// //         : MyUser.fromJson(userData);             // Use directly if it's already a Map
// //   } catch (e) {
// //     print("❌ Error parsing user data: $e");
// //     return;
// //   }
// //
// //   if (route == ChatPage.routeName && user != null) {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => ChatPage(user: user!),
// //       ),
// //     );
// //   }
// // }
//
// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:hands_talks/Model/myUser.dart';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:hands_talks/Model/myUser.dart';
// import 'package:hands_talks/message/chatpage.dart';
//
// /// ✅ Get Firebase Access Token
// Future<String> getAccessToken() async {
//   final jsonString = await rootBundle.loadString(
//       'assets/notification_key/hands-talks-e581c-1b262605c3c1.json');
//
//   final accountCredentials =
//   auth.ServiceAccountCredentials.fromJson(jsonString);
//
//   final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
//   final client = await auth.clientViaServiceAccount(accountCredentials, scopes);
//
//   return client.credentials.accessToken.data;
// }
//
// /// ✅ Send Notification via Firebase API
// Future<void> sendNotification({
//   required MyUser user,
//   required String token,
//   required String title,
//   required String body,
//   required Map<String, String> data,
// }) async {
//   final String accessToken = await getAccessToken();
//   final String fcmUrl =
//       'https://fcm.googleapis.com/v1/projects/hands-talks-e581c/messages:send';
//
//   final requestBody = jsonEncode({
//     'message': {
//       'token': token,
//       'notification': {'title': title, 'body': body},
//       'data': data,
//       'android': {'notification': {'click_action': 'FLUTTER_NOTIFICATION_CLICK'}},
//       'apns': {'payload': {'aps': {'content-available': 1}}},
//     },
//   });
//
//   final response = await http.post(
//     Uri.parse(fcmUrl),
//     headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
//     body: requestBody,
//   );
//
//   if (response.statusCode == 200) {
//     print('✅ Notification sent successfully');
//   } else {
//     print('❌ Failed to send notification: ${response.body}');
//   }
// }
//
//
// void handleNotification(BuildContext context, Map<String, dynamic> data) {
//   print("🔔 Notification Clicked: $data");
//
//   if (!data.containsKey("route") || !data.containsKey("user")) {
//     print("❌ Missing notification data.");
//     return;
//   }
//
//   String route = data['route'].toString();
//   MyUser user;
//
//   try {
//     user = data['user'] is String
//         ? MyUser.fromJson(jsonDecode(data['user']))
//         : MyUser.fromJson(data['user']);
//   } catch (e) {
//     print("❌ Error parsing user data: $e");
//     return;
//   }
//
//   if (route == ChatPage.routeName) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => ChatPage(user: user)),
//     );
//   }
// }
// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:hands_talks/Model/myUser.dart';
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:hands_talks/Model/myUser.dart';
// import 'package:hands_talks/message/chatpage.dart';
//
// /// ✅ Get Firebase Access Token
// Future<String> getAccessToken() async {
//   final jsonString = await rootBundle.loadString(
//       'assets/notification_key/hands-talks-e581c-1b262605c3c1.json');
//
//   final accountCredentials =
//   auth.ServiceAccountCredentials.fromJson(jsonString);
//
//   final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
//   final client = await auth.clientViaServiceAccount(accountCredentials, scopes);
//
//   return client.credentials.accessToken.data;
// }
//
// /// ✅ Send Notification via Firebase API
// Future<void> sendNotification({
//   required MyUser user,
//   required String token,
//   required String title,
//   required String body,
//   required Map<String, String> data,
// }) async {
//   final String accessToken = await getAccessToken();
//   final String fcmUrl =
//       'https://fcm.googleapis.com/v1/projects/hands-talks-e581c/messages:send';
//
//   final requestBody = jsonEncode({
//     'message': {
//       'token': token,
//       'notification': {'title': title, 'body': body},
//       'data': data,
//       'android': {'notification': {'click_action': 'FLUTTER_NOTIFICATION_CLICK'}},
//       'apns': {'payload': {'aps': {'content-available': 1}}},
//     },
//   });
//
//   final response = await http.post(
//     Uri.parse(fcmUrl),
//     headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
//     body: requestBody,
//   );
//
//   if (response.statusCode == 200) {
//     print('✅ Notification sent successfully');
//   } else {
//     print('❌ Failed to send notification: ${response.body}');
//   }
// }