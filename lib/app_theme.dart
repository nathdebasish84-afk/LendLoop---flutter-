import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      primary: Colors.green,
      secondary: Colors.blue,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.barlowTextTheme(),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      primary: Colors.green,
      secondary: Colors.blue,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.barlowTextTheme(ThemeData.dark().textTheme),
  );
}
