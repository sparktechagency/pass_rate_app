import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pass_rate/core/config/app_sizes.dart';
import 'package:pass_rate/core/extensions/context_extensions.dart';
import 'package:pass_rate/core/routes/app_routes.dart';
import '../../../core/common/widgets/floating_support.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_icons.dart';
import '../../../core/design/app_images.dart';
import '../../../core/config/app_strings.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_tile.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController _ = controller;
    return Scaffold(
      /// Lower Helping Button ============>
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const SupportFloatingWidget(),

      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            /// HomePage top logo =====>
            homeTopWidget(context),
            const SizedBox(height: 32),

            /// HomePage body  =====>
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                spacing: 16,
                children: <Widget>[
                  HomeTile(
                    labelText: AppStrings.submitAssessment,
                    svgPath: AppIcons.submitIcon,
                    onTap: () {
                      Get.toNamed(AppRoutes.submitAssessment);
                    },
                  ),
                  HomeTile(
                    labelText: AppStrings.statistics,
                    svgPath: AppIcons.statisticsIcon,
                    onTap: () {
                      Get.toNamed(AppRoutes.statisticsScreen);
                    },
                  ),
                  HomeTile(
                    labelText: AppStrings.yourSubmissions,
                    svgPath: AppIcons.submissionIcon,
                    onTap: () {
                      Get.toNamed(AppRoutes.submissionPage);
                    },
                  ),
                  if (context.screenHeight < 600)
                    const SizedBox(height: AppSizes.xxxL + AppSizes.xxl)
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container homeTopWidget(BuildContext context) {
    return Container(
      width: context.width,
      height: 220,
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),

        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Image.asset(AppImages.logoWithTextImage, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
