import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pass_rate/core/config/app_sizes.dart';
import 'package:pass_rate/core/config/app_strings.dart';
import 'package:pass_rate/core/design/app_colors.dart';
import 'package:pass_rate/core/extensions/context_extensions.dart';
import 'package:pass_rate/core/extensions/widget_extensions.dart';
import 'package:pass_rate/core/routes/app_routes.dart';
import 'package:pass_rate/core/utils/logger_utils.dart';
import 'package:pass_rate/shared/widgets/app_button.dart';

import '../../../core/common/widgets/custom_toast.dart';
import '../../../core/config/app_url.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';

class SupportController extends GetxController {
  // Text controller for custom amount
  final TextEditingController customAmountController = TextEditingController();

  // Reactive variables
  final RxDouble selectedAmount = 0.0.obs;
  final RxDouble customAmount = 0.0.obs;
  final RxBool isCustomAmountSelected = false.obs;
  final RxBool isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to custom amount text field changes
    customAmountController.addListener(() {
      final String text = customAmountController.text;
      if (text.isNotEmpty) {
        final double amount = double.tryParse(text) ?? 0.0;
        customAmount.value = amount;
      } else {
        customAmount.value = 0.0;
      }
    });
  }

  /// Select a predefined amount
  void selectPredefinedAmount(double amount) {
    selectedAmount.value = amount;
    customAmount.value = 0.0;
    isCustomAmountSelected.value = false;
    customAmountController.clear();
  }

  /// Select custom amount input
  void selectCustomAmount() {
    selectedAmount.value = 0.0;
    isCustomAmountSelected.value = true;
  }

  /// Handle custom amount text field changes
  void onCustomAmountChanged(String value) {
    if (value.isNotEmpty) {
      final double amount = double.tryParse(value) ?? 0.0;
      customAmount.value = amount;
      selectedAmount.value = 0.0;
      isCustomAmountSelected.value = true;
    } else {
      customAmount.value = 0.0;
    }
  }

  /// Get total donation amount
  double getTotalAmount() {
    if (selectedAmount.value > 0) {
      return selectedAmount.value;
    } else if (customAmount.value > 0) {
      return customAmount.value;
    }
    return 0.0;
  }

  /// Check if amount is valid for donation
  bool isValidAmount() {
    final double amount = getTotalAmount();
    return amount > 0; // Minimum €1 donation
  }

  /// Process the donation
  Future<void> processDonation(BuildContext context) async {
    final double amount = getTotalAmount();

    if (!isValidAmount()) {
      _showErrorMessage('Please select or enter a valid amount (minimum €0.01)');
      return;
    }

    try {
      isProcessing.value = true;

      LoggerUtils.debug('Processing donation of €${amount.toStringAsFixed(2)}');

      // Show confirmation dialog first
      final bool confirmed = await _showConfirmationDialog(amount, context);

      if (!confirmed) {
        isProcessing.value = false;
        return;
      }

      // TODO: Implement actual payment processing here
      // This is where you would integrate with Stripe or other payment provider
      await _mockPaymentProcess(amount);

      // Show success message
      _resetForm();
    } catch (e) {
      LoggerUtils.debug('Donation processing error: $e');
      _showErrorMessage('Payment failed. Please try again.');
    } finally {
      isProcessing.value = false;
    }
  }

  /// Show confirmation dialog
  Future<bool> _showConfirmationDialog(double amount, BuildContext context) async {
    final bool? result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(AppStrings.confirmDonation.tr, style: context.txtTheme.titleMedium).centered,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(AppStrings.youAreAboutToDonate.tr),
            const SizedBox(height: 8),
            Text(
              '€${amount.toStringAsFixed(2)}',
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(AppStrings.securePaymentText.tr),
          ],
        ),
        actions: <Widget>[
          Row(
            spacing: AppSizes.md,
            children: <Widget>[
              Expanded(
                child: AppButton(
                  bgColor: AppColors.white,
                  textColor: AppColors.red,
                  labelText: AppStrings.cancel.tr,
                  onTap: () => Get.back(result: false),
                ),
              ),
              Expanded(
                child: AppButton(
                  bgColor: AppColors.primaryColor,
                  textColor: AppColors.white,
                  labelText: AppStrings.continueText.tr,
                  onTap: () => Get.back(result: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Mock payment process (replace with actual payment integration)
  Future<void> _mockPaymentProcess(double amount) async {
    final NetworkResponse response = await NetworkCaller().postRequest(
      AppUrl.makePayment,
      body: <String, dynamic>{'amount': amount},
    );
    print("response : ${response.jsonResponse}");

    if (response.statusCode == 200) {
      final String url = response.jsonResponse?['data']['url'];
      LoggerUtils.debug(url);
      Get.toNamed(AppRoutes.paymentScreen, arguments: url);
    } else {
      ToastManager.show(
        message: response.jsonResponse?['error'] ?? AppStrings.unexpectedError.tr,
        icon: const Icon(CupertinoIcons.info_circle_fill, color: AppColors.white),
        backgroundColor: AppColors.darkRed,
        textColor: AppColors.white,
      );
    }
  }

  /// Reset form after successful donation
  void _resetForm() {
    selectedAmount.value = 0.0;
    customAmount.value = 0.0;
    isCustomAmountSelected.value = false;
    customAmountController.clear();
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    ToastManager.show(
      message: message,
      icon: const Icon(CupertinoIcons.check_mark_circled, color: AppColors.white),
      textColor: AppColors.white,
    );
  }

  /// Show error message
  void _showErrorMessage(String message) {
    ToastManager.show(
      message: message,
      icon: const Icon(CupertinoIcons.info_circle_fill, color: AppColors.white),
      textColor: AppColors.white,
      backgroundColor: AppColors.red,
    );
  }

  /// Quick set custom amount (for popular amounts)
  void setCustomAmountQuick(double amount) {
    customAmountController.text = amount.toStringAsFixed(0);
    selectCustomAmount();
  }

  @override
  void onClose() {
    customAmountController.dispose();
    super.onClose();
  }
}
