import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pass_rate/core/extensions/context_extensions.dart';
import '../../config/app_sizes.dart';
import '../../config/app_strings.dart';
import '../../design/app_colors.dart';
import '../../design/app_icons.dart';
import '../../routes/app_routes.dart';
import 'custom_svg.dart';

class SupportFloatingWidget extends StatelessWidget {
  const SupportFloatingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      child: Material(
        elevation: 3,
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),

        // Add borderRadius here
        child: InkWell(
          splashColor: AppColors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          onTap: () {
            Get.toNamed(AppRoutes.supportPage);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
            width: context.screenWidth * .5,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.green),
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12,
              children: <Widget>[
                CustomSvgImage(assetName: AppIcons.helpIcon, color: AppColors.green, height: 32),
                Text(
                  AppStrings.helpUsGrow.tr,
                  style: context.txtTheme.headlineMedium?.copyWith(color: AppColors.green),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
