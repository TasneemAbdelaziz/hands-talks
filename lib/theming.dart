import 'package:flutter/material.dart';

class Theming{
  static Color primary = const Color(0xff10286E);
  // used in buttons
  static Color secondary = const Color(0xffd9d9d9);

  // used in filed like email ,password,text inside gray buttons..
  static Color form = const Color(0xff858C94);

  // snakBar when filled and stroke when no filled
  static Color snackBar = const Color(0xff808187);

  static Color white = const Color(0xffffffff);

  static Color searchbar = const Color(0x33767680);


  static Color black = const Color(0xff000000);

  static LinearGradient icons = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff3F65BE),
      Color(0xff10286E),
    ],
  );

  static ThemeData lightTheme=  ThemeData(
  textTheme: TextTheme(

  titleLarge: TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  color: black,
  ),
    titleMedium: TextStyle(
      fontSize: 22,
      color:primary ,
    ),

    bodySmall: TextStyle(
      fontSize: 16,
      color:form ,
    ),

  ),

  );

}