import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pass_rate/core/config/app_strings.dart';
import 'package:pass_rate/core/config/app_sizes.dart';
import 'package:pass_rate/core/design/app_colors.dart';
import 'package:pass_rate/core/extensions/context_extensions.dart';
import 'package:pass_rate/core/utils/device/device_utility.dart';
import 'package:pass_rate/shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/app_button.dart';
import '../controllers/support_controller.dart';

class SupportScreen extends GetView<SupportController> {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(label: AppStrings.supportPassRate),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppStrings.helpUsKeepTheAppFree.tr,
              style: context.txtTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(AppStrings.everyEuroGoesTowardSupport.tr),
            bulletinText(bodyText: AppStrings.salaryComparisons.tr),
            bulletinText(bodyText: AppStrings.realAssessmentInsights.tr),
            bulletinText(bodyText: AppStrings.futureReleaseOFPilot.tr),
            const SizedBox(height: AppSizes.sm),
            Text(AppStrings.aDedicatedPlatformWhere.tr),

            const SizedBox(height: AppSizes.lg),

            // Donation amount selection
            Text(
              AppStrings.chooseDonationAmount.tr,
              style: context.txtTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Predefined amounts
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _buildAmountContainer(10),
                _buildAmountContainer(30),
                _buildAmountContainer(50),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            // Custom amount text field
            Text(
             AppStrings.orACustomAmount.tr,
              style: context.txtTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            Obx(() => Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.isCustomAmountSelected.value
                      ? AppColors.primaryColor
                      : Colors.grey.shade300,
                  width: controller.isCustomAmountSelected.value ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                color: controller.isCustomAmountSelected.value
                    ? AppColors.primaryColor.withValues(alpha:0.05)
                    : Colors.transparent,
              ),
              child: TextField(
                controller: controller.customAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  prefixText: "€ ",
                  prefixStyle: TextStyle(
                    color: controller.isCustomAmountSelected.value
                        ? AppColors.primaryColor
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: "0.00",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppSizes.md),
                ),
                onChanged: controller.onCustomAmountChanged,
                onTap: controller.selectCustomAmount,
              ),
            )),

            const SizedBox(height: AppSizes.md),

            // Selected amount display
            Obx(() {
              final double amount = controller.getTotalAmount();
              if (amount > 0) {
                return Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                    border: Border.all(color: AppColors.green.withValues(alpha:0.3)),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.favorite, color: AppColors.green, size: 20),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          "${AppStrings.thankYouForChoosingToDonate.tr} €${amount.toStringAsFixed(2)}!",
                          style: context.txtTheme.bodyMedium?.copyWith(
                            color: AppColors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: AppSizes.lg),

            /// Proceed button ============>
            Obx(() {
              final double amount = controller.getTotalAmount();
              return AppButton(
                labelText: amount > 0
                    ? "${AppStrings.donate.tr} €${amount.toStringAsFixed(2)}"
                    : AppStrings.proceed.tr,
                bgColor: amount > 0 ? AppColors.primaryColor : AppColors.greyLight,
                textColor: AppColors.white,
                onTap: amount > 0 ? () {
                  DeviceUtility.hapticFeedback();
                  controller.processDonation(context);
                } : (){},
              );
            }),

            const SizedBox(height: AppSizes.sm),
            Text(AppStrings.moSubscriptionLock.tr, textAlign: TextAlign.start),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountContainer(int amount) {
    return Obx(() {
      final bool isSelected = controller.selectedAmount.value == amount.toDouble();

      return GestureDetector(
        onTap: () => controller.selectPredefinedAmount(amount.toDouble()),
        child: Container(
          width: Get.width * 0.25,
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.md,
            horizontal: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
            color: isSelected
                ? AppColors.primaryColor.withValues(alpha:0.05)
                : Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Selection indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor,
                    ),
                  ),
                )
                    : null,
              ),
              const SizedBox(height: AppSizes.sm),
              // Amount
              Text(
                "€$amount",
                style: Get.textTheme.headlineSmall?.copyWith(
                  color: isSelected ? AppColors.primaryColor : AppColors.greyLight,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),
        ),
      );
    });
  }



  Padding bulletinText({required String bodyText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        spacing: AppSizes.md,
        children: <Widget>[
          Container(
            height: 5,
            width: 5,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
          ),
          Expanded(child: Text(bodyText)),
        ],
      ),
    );
  }
}