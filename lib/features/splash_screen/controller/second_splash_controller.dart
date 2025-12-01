import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

class SecondSplashController extends GetxController with GetSingleTickerProviderStateMixin {
  // Animation controller and animation
  late AnimationController animationController;
  late Animation<double> animation;

  // Observable animation value for reactive UI updates
  RxDouble animationValue = 0.0.obs;

  @override
  void onReady() {
    // Initialize animation after the widget is ready
    _initializeAnimation();
    super.onReady();
  }

  /// Initialize the second splash screen animation
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

    // Listen for animation completion to navigate to home
    animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        Get.offAllNamed(AppRoutes.homeRoute);
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
