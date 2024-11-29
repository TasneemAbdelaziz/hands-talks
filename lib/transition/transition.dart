import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/home/homepage.dart';
import 'package:hands_talks/message/messagepage.dart';
import 'package:hands_talks/profile/ProfilePage.dart';
import 'package:hands_talks/theming.dart';
import 'package:hands_talks/translate/translatepage.dart';





class Translation extends StatefulWidget {
  static const routeName = "Transition";
  const Translation({super.key});

  @override
  State<Translation> createState() => _TranslationState();
}

class _TranslationState extends State<Translation> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[selectedIndex],
      bottomNavigationBar:CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Theming.primary,
        animationDuration: Duration(milliseconds: 300),

        onTap: (index) {
          selectedIndex = index;
          setState(() {});
        },


        items: [

          Image.asset(selectedIndex == 0 ? "assets/icons/home1.png" : "assets/icons/home.png" ),
          Image.asset(selectedIndex == 1 ? "assets/icons/translate1.png" : "assets/icons/translate.png" ),
          Image.asset(selectedIndex == 2 ? "assets/icons/message1.png" : "assets/icons/message.png" ),
          Image.asset(selectedIndex == 3 ? "assets/icons/profile1.png" : "assets/icons/profile.png" ),


        ],
      ),
    );
  }
}




List<Widget> tabs = [
  HomePage(),
  TranslatePage(),
  MessagePage(),
  ProfilePage(),
];

