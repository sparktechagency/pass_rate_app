import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/utils/custom_loader.dart';
import '../controllers/payment_controller.dart';

class PaymentScreen extends GetView<PaymentController> {
  const PaymentScreen({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final String? url = Get.arguments as String?;
    controller.url = url;
    controller.initializeWebview();
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () {
            if(controller.isLoading.value){
              return const CustomLoading(color: AppColors.primaryColor,);
            }
            else{
              return WebViewWidget(
                controller: controller.webViewController,
              );
            }
          },
        ),
      ),
    );
  }
}
