import 'package:get/get.dart';

/// Splash binding - minimal since SplashView is now a StatefulWidget
/// that handles its own navigation logic.
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // No controller needed - SplashView handles navigation directly
    // Deep link info is stored in SplashController static fields
  }
}
