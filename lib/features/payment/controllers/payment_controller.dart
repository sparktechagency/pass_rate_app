import 'package:get/get.dart';
import 'package:pass_rate/core/routes/app_routes.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/utils/logger_utils.dart';

class PaymentController extends GetxController {

  final RxBool isLoading = false.obs;
  String? url;

  WebViewController webViewController = WebViewController();

  Future<void> initializeWebview() async{
    isLoading.value = true;
    try {
      if(url == null){
        Get.back();
        return;
      }
      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar.
              // LoggerUtils.info("webview progress : $progress");
            },
            onPageStarted: (String url) {
              LoggerUtils.debug("webview page started : $url");
            },
            onPageFinished: (String url) {
              LoggerUtils.debug("webview page finished : $url");
              isLoading.value = false;
            },
            onHttpError: (HttpResponseError error) {
              LoggerUtils.error("webview http error : ${error.request} rs: ${error.response}");
            },
            onWebResourceError: (WebResourceError error) {
              LoggerUtils.error("webview resource error : ${error.description} rs: ${error.errorType}");
            },
            onUrlChange: (UrlChange url){
              if(!(url.url != null && url.url!.startsWith("https://checkout.stripe.com"))){
                Get.offAllNamed(AppRoutes.homeRoute);

              }

              LoggerUtils.debug(<String, Object?>{
                "url object": url,
                "url": url.url,
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(url ?? ''));
    }
    finally{
      // isLoading.value = false;
    }
  }







  /// [onInit] Lifecycle method called when the controller is initialized.
  ///
  /// Resets loading states, clears existing data, and triggers and more..
  /// initial fetch
  ///
  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
  }

  /// [dispose] Lifecycle method called when the controller is destroyed.
  ///
  /// Cleans up by resetting loading states and clearing lists and more...
  @override
  void dispose() {
    isLoading.value = false;
    super.dispose();
  }
}
