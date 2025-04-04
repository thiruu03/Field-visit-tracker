import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  pageTransitionsTheme: PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    },
  ),
  fontFamily: 'mont',
  colorScheme: ColorScheme.light(
    primary: Color.fromRGBO(18, 41, 50, 1),
    onPrimary: Color.fromRGBO(44, 81, 76, 1),
    secondary: Color.fromRGBO(103, 114, 121, 1),
    onSecondary: Color.fromRGBO(149, 129, 141, 1),
    tertiary: Color.fromRGBO(227, 192, 211, 1),
  ),
);
