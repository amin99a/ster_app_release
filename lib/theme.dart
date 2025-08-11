import 'package:flutter/material.dart';
import 'constants.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'SFPro',
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
    bodyMedium: TextStyle(fontSize: 14, color: darkGrey),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: primaryColor),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: lightGrey,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
);
