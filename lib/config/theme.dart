import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData theme() {
  return ThemeData(
      primaryColor: const Color(0xff1e234d),
      scaffoldBackgroundColor: Colors.white,
      backgroundColor: const Color(0xFFF4F4F4),
      colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xff2DCBC8), primary: const Color(0xff1e234d)),
      fontFamily:GoogleFonts.roboto().fontFamily,
      textTheme: const TextTheme(
        headline1: TextStyle(
          color: Color(0xff1e234d),
          fontWeight: FontWeight.bold,
          fontSize: 36,
        ),
        headline2: TextStyle(
          color: Color(0xff1e234d),
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        headline3: TextStyle(
          color: Color(0xff1e234d),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        headline4: TextStyle(
          color: Color(0xff1e234d),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        headline5: TextStyle(
          color: Color(0xFF2B2E4A),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        headline6: TextStyle(
          color: Color(0xff1e234d),
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        bodyText1: TextStyle(
          color: Color(0xff1e234d),
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        bodyText2: TextStyle(
          color: Color(0xff1e234d),
          fontWeight: FontWeight.normal,
          fontSize: 10,
        ),
      ));
}
