// main.dart
import 'package:dtm1/db/db_helper.dart';
import 'package:dtm1/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dtm1/services/theme_services.dart';
// import 'package:dtm1/ui/home_page.dart';
import 'package:dtm1/ui/themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper.initDb();
  await GetStorage.init();
  Get.put(ThemeServices()); // Initialize ThemeServices

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeServices = Get.find<ThemeServices>();

      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: Themes.light,
        darkTheme: Themes.dark,
        themeMode: themeServices.theme,
        home: const HomePage(),
      );
    });
  }
}
