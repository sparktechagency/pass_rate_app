import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pass_rate/core/common/widgets/custom_svg.dart';
import 'package:pass_rate/core/config/app_sizes.dart';
import 'package:pass_rate/core/design/app_colors.dart';
import 'package:pass_rate/core/design/app_icons.dart';
import 'package:pass_rate/core/extensions/context_extensions.dart';
import 'package:pass_rate/core/routes/app_routes.dart';
import 'package:pass_rate/shared/widgets/app_button.dart';
import 'package:pass_rate/shared/widgets/custom_appbar.dart';
import '../../../core/config/app_strings.dart';
import '../../../core/utils/device/device_utility.dart';
import '../controllers/assessment_controller.dart';
import '../model/submission_response.dart';

class ConfirmSubmissionPage extends GetView<AssessmentController> {
  const ConfirmSubmissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SubmissionResponse submittedResponse = Get.arguments;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        height: 50,
        child: Row(
          spacing: 12,
          children: <Widget>[
            Expanded(
              child: AppButton(
                labelText: AppStrings.submitAnother.tr,
                onTap: () async {
                  /// simple Vibration
                  DeviceUtility.hapticFeedback();
                  await controller.resetAssessments();
                  Get.offNamed(AppRoutes.submitAssessment);
                },
              ),
            ),
            Expanded(
              child: AppButton(
                labelText: AppStrings.viewStatics.tr,
                onTap: () {
                  /// simple Vibration
                  DeviceUtility.hapticFeedback();
                  Get.toNamed(AppRoutes.statisticsScreen);
                },
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Column(
            children: <Widget>[
              CustomAppBar(label: AppStrings.submitResultTitle.tr),
              Padding(
                padding: const EdgeInsets.only(left: AppSizes.xl),
                child: CustomSvgImage(
                  assetName: AppIcons.resultIcon,
                  height: context.screenHeight * 0.20,
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              /// The text below the image =======>
              Text(
                AppStrings.resultSubmitted.tr,
                style: context.txtTheme.bodySmall?.copyWith(color: AppColors.grey),
              ),
              const SizedBox(height: AppSizes.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(submittedResponse.airlineName, style: context.txtTheme.titleMedium),
                    Text(
                      submittedResponse.selectedYear.year.toString(),
                      style: context.txtTheme.labelMedium,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(AppStrings.totalResponses.tr),
                        Text(submittedResponse.totalResponse.toInt().toString()),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(AppStrings.successRate.tr),
                        Text(submittedResponse.totalSuccessRate.toStringAsFixed(2)),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xxxL * 1.5),
            ],
          ),
        ),
      ),
    );
  }
}
