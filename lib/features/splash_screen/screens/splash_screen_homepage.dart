import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pass_rate/core/design/app_colors.dart';
import 'package:pass_rate/core/extensions/context_extensions.dart';
import '../../../core/design/app_images.dart';
import '../controller/first_splash_controller.dart';

class SplashScreenHomepage extends GetView<FirstSplashController> {
  const SplashScreenHomepage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Obx(() {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // Logo Image: Static in the center initially, moves left
              Positioned(
                left: 50,
                child: Opacity(
                  opacity: 1,
                  child: Transform.translate(
                    offset: Offset(-50 * controller.animationValue.value, 0),
                    child: Image.asset(AppImages.logoImage, width: 200),
                  ),
                ),
              ),

              // PassRate Text: Initially hidden, appears after the logo moves left
              Positioned(
                right: 50,
                child: Opacity(
                  opacity: ((controller.animationValue.value - 0.2) * 2).clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(-25 * (1 - controller.animationValue.value), 0),
                    child: Text(
                      'PassRate',
                      style: TextStyle(
                        fontSize: context.screenWidth < 300
                            ? 32
                            : context.screenWidth < 400
                            ? 38
                            : context.screenWidth < 600
                            ? 40
                            : context.screenWidth < 1024
                            ? 44
                            : 50,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
