//theme_controller.dart
import 'package:get/get.dart';

class ThemeController extends GetxController {
  // Reactive variable
  var isDarkMode = false.obs;

  // Method to toggle theme
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    // Optionally save to storage
  }
}
