// themes.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dtm1/services/theme_services.dart';

const Color bluishClr = Color.fromARGB(255, 25, 118, 248);
const Color yellowClr = Color(0xFFFFB746);
const Color pinkCLr = Color(0xFFff4667);
const Color white = Colors.white;
const Color primaryClr = bluishClr;
const Color darkGreyClr = Color.fromARGB(255, 45, 43, 43);
const Color darkGreyAppbar = Color.fromARGB(255, 0, 0, 0);
Color darkHeaderClr = const Color(0xFF424242);

final themeServices = Get.find<ThemeServices>();

class Themes {
  static final light = ThemeData(
    primaryColor: primaryClr,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 30),
      titleMedium: TextStyle(fontFamily: 'Roboto', fontSize: 16),
      bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 14),
    ),
  );

  static final dark = ThemeData(
    primaryColor: darkGreyClr,
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(backgroundColor: darkGreyAppbar),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 30),
      titleMedium: TextStyle(fontFamily: 'Roboto', fontSize: 16),
      bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 14),
    ),
  );
}

TextStyle get subHeadingStyle {
  return TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Get.isDarkMode ? Colors.grey[400] : Colors.grey,
    fontFamily: 'Roboto',
  );
}

TextStyle get headingStyle {
  return TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Get.isDarkMode ? Colors.white : Colors.black,
    fontFamily: 'Roboto',
  );
}

TextStyle get titleStyle {
  return TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Get.isDarkMode ? Colors.grey[400] : Colors.grey,
    fontFamily: 'Roboto',
  );
}

TextStyle get subTitleStyle {
  return TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Get.isDarkMode ? Colors.grey[100] : Colors.grey[600],
    fontFamily: 'Roboto',
  );
}
