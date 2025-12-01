import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/device/device_info.dart';
import '../../../core/utils/get_storage.dart';
import '../../../core/utils/logger_utils.dart';

class FirstSplashController extends GetxController with GetSingleTickerProviderStateMixin {
  // Animation controller and animation
  late AnimationController animationController;
  late Animation<double> animation;

  // Observable animation value for reactive UI updates
  RxDouble animationValue = 0.0.obs;

  @override
  Future<void> onInit() async {
    // Initialize device ID and other startup logic
    final bool deviceIdExist = GetStorageModel().exists(AppConstants.deviceId);
    // if the device Id is already saved no need to save it again
    if (deviceIdExist == false) {
      final String? deviceId = await DeviceIdService.getDeviceId();
      GetStorageModel().saveString(AppConstants.deviceId, deviceId ?? '');
      LoggerUtils.debug(GetStorageModel().getString(AppConstants.deviceId));
    }

    super.onInit();
  }

  @override
  void onReady() {
    // Initialize animation after the widget is ready
    _initializeAnimation();
    super.onReady();
  }

  /// Initialize the first splash screen animation
  void _initializeAnimation() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    animation = CurvedAnimation(parent: animationController, curve: Curves.easeInOut);

    // Listen to animation changes and update observable
    animation.addListener(() {
      animationValue.value = animation.value;
    });

    // Listen for animation completion to navigate to next splash
    animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        Get.offAllNamed(AppRoutes.nextSplashScreen);
      }
    });

    // Start the animation
    animationController.forward();
  }

  @override
  void onClose() {
    animationController.dispose(); // ADD THIS LINE
    super.onClose();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
