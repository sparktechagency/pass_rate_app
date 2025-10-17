import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pass_rate/core/config/app_constants.dart';
import 'package:pass_rate/core/design/app_colors.dart';
import 'package:pass_rate/core/utils/get_storage.dart';
import 'package:pass_rate/core/utils/logger_utils.dart';
import 'package:pass_rate/shared/widgets/app_button.dart';
import '../../../core/common/widgets/custom_modal.dart';
import '../../../core/config/app_strings.dart';
import '../../../core/config/app_url.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';

class HomeController extends GetxController {
  final RxBool loader = false.obs;
  RxString termsCondition = AppStrings.privacyPolicyTerms.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    // Call showTerms here instead of in build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
    await getPrivacyText();
      showTerms();
    });
  }

  Future<void> getPrivacyText() async {
    try {
      loader.value = true;
      final NetworkResponse getResponse = await NetworkCaller().getRequest(AppUrl.policy);

      if (getResponse.statusCode == 200) {
        final String data = getResponse.jsonResponse?['data'] ?? <dynamic>[];

        if (data.isNotEmpty) {
          termsCondition.value = data;
        }
      }
    } catch (e) {
      LoggerUtils.debug("Error in getting Privacy Policy: $e");
      termsCondition.value = AppStrings.privacyPolicyTerms;
    } finally {
      loader.value = false;
    }
  }

  void showTerms() {
    if (GetStorageModel().exists(AppConstants.showedTerms) &&
        GetStorageModel().read(AppConstants.showedTerms) == true) {
      LoggerUtils.debug('Terms already shown, skipping modal');
      return;
    } else {
      LoggerUtils.debug('Showing terms modal');

      CustomBottomSheet.show(
        context: Get.context!,
        title: AppStrings.termsAndConditions.tr,
        height: Get.height * 0.8,
        isDismissible: false,
        child: PopScope(
          canPop: false,
          child: Column(
            children: <Widget>[
              Text(termsCondition.value),
              AppButton(
                bgColor: AppColors.primaryColor,
                textColor: AppColors.white,
                labelText: AppStrings.iAgreeToTheTerms.tr,
                onTap: () async {
                  await GetStorageModel().saveBool(AppConstants.showedTerms, true);
                  Get.back(); // Close the modal
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}
