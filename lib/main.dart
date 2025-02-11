import 'package:flutter/material.dart';
import 'package:hands_talks/home/homepage.dart';
import 'package:hands_talks/message/chatpage.dart';
import 'package:hands_talks/message/messagespage.dart';
import 'package:hands_talks/message/chatpage.dart';
import 'package:hands_talks/profile/ProfilePage.dart';
import 'package:hands_talks/transition/transition.dart';
import 'package:hands_talks/translate/translatepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute:Translation.routeName,
      routes: {
        Translation.routeName: (context) => const Translation(),
        HomePage.routeName: (context) => const HomePage(),
        TranslatePage.routeName: (context) => const TranslatePage(),
        MessagesPage.routeName: (context) => const MessagesPage(),
        ProfilePage.routeName: (context) => const ProfilePage(),
        ChatPage.routeName: (context) => const ChatPage()

      },
    );
  }
}
