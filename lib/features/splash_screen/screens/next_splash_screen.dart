import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pass_rate/core/config/app_sizes.dart';
import 'package:pass_rate/core/design/app_colors.dart';
import 'package:pass_rate/core/extensions/context_extensions.dart';
import '../../../core/design/app_images.dart';
import '../controller/second_splash_controller.dart';

class NextSplashScreen extends  GetView<SecondSplashController> {
  const NextSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the second splash controller
    final SecondSplashController controller = Get.put(SecondSplashController());

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Obx(() {
          return Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(height: context.screenHeight * 0.2),
                  Stack(
                    children: <Widget>[
                      // Background world map with opacity
                      Opacity(
                        opacity: 0.5,
                        child: Image.asset(AppImages.worldMap),
                      ),

                      // Animated text content
                      Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Opacity(
                          opacity: controller.animationValue.value,
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Know Before You Go!',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 30,
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                'Explore real airline assessments and pass rates',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Animated airplane image
              Positioned(
                bottom: 150,
                left: 400,
                child: Transform.translate(
                  offset: Offset(
                    -250 * controller.animationValue.value,
                    -50 * controller.animationValue.value,
                  ),
                  child: Image.asset(AppImages.aeroplaneImage, width: 600),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}