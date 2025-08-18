import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import 'app/core/constants/app_colors.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // System UI Styling
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppTheme.lightTheme.primaryColor,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Lifecycle Observer
  WidgetsBinding.instance.addObserver(AppLifecycleListener());
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,

      // // 🎨 Theming
      // theme: ThemeData(
      //   primarySwatch: Colors.indigo,
      //   scaffoldBackgroundColor: Colors.white,
      // ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,

      // 🖱️ Scroll support for multiple devices
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
        },
      ),
    ),
  );
}

class AppLifecycleListener extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('📱 App state changed: $state');
  }
}
