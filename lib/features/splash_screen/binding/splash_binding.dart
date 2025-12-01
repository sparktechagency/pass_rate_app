import 'package:get/get.dart';
import 'package:pass_rate/features/splash_screen/controller/second_splash_controller.dart';
import '../controller/first_splash_controller.dart';

class SplashScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FirstSplashController>(() => FirstSplashController());
    Get.lazyPut<SecondSplashController>(() => SecondSplashController());
  }
}
