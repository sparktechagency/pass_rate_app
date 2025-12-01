import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pass_rate/core/config/app_constants.dart';
import 'package:pass_rate/features/submissions/model/my_submission.dart';

import '../../../core/common/widgets/custom_toast.dart';
import '../../../core/config/app_strings.dart';
import '../../../core/config/app_url.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/get_storage.dart';
import '../../../core/utils/logger_utils.dart';

class SubmissionsController extends GetxController {
  final RxBool loader = false.obs;
  final List<MySubmissionModel> mySubmissions = <MySubmissionModel>[].obs;
  final TextEditingController searchTEController = TextEditingController();

  // Add reactive search query
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    getMySubmissions();
    super.onInit();
  }

  // Computed property for filtered submissions
  List<MySubmissionModel> get filteredSubmissions {
    if (searchQuery.value.isEmpty) {
      return mySubmissions;
    }

    return mySubmissions.where((MySubmissionModel submission) {
      final String query = searchQuery.value.toLowerCase();

      // Search in submission name/title if available
      final bool nameMatch = (submission.airline).toLowerCase().contains(query);

      // Search in assessments
      final bool assessmentMatch = submission.assessments.any(
        (String assessment) => (assessment).toLowerCase().contains(query),
      );

      // Search in submission date

      return nameMatch || assessmentMatch;
    }).toList();
  }

  void handleSearch() {
    // Update the search query with current text field value
    searchQuery.value = searchTEController.text.trim();
  }

  // Clear search
  void clearSearch() {
    searchTEController.clear();
    searchQuery.value = '';
  }

  Future<void> handleDelete({required MySubmissionModel submission}) async {
    try {
      loader.value = true;
      final NetworkResponse response = await NetworkCaller().deleteRequest(
        AppUrl.deleteSubmission(submissionId: submission.id),
      );
      LoggerUtils.debug(response.jsonResponse);
      if (response.statusCode == 200) {
        mySubmissions.remove(submission);
        ToastManager.show(
          message: AppStrings.itemDeleted.tr,
          icon: const Icon(CupertinoIcons.check_mark_circled, color: AppColors.white),
        );
      } else {
        // Handle the case where the network request fails
        _showErrorMessage(AppStrings.deletionFailed.tr);
      }
    } catch (e) {
      // Handle unexpected errors during the request or parsing
      LoggerUtils.debug("Error in getting submissions: $e");
      _showErrorMessage(AppStrings.unexpectedError.tr);
    } finally {
      loader.value = false;
    }
  }

  Future<void> getMySubmissions() async {
    try {
      loader.value = true;
      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.getMySubmission(deviceId: GetStorageModel().getString(AppConstants.deviceId)),
        // AppUrl.getMySubmission(deviceId: AppConstants.demoDeviceId),
      );

      // Check if the response is successful
      if (response.isSuccess) {
        final List<dynamic> data = response.jsonResponse?['data'] ?? <dynamic>[];

        // If data is not empty, process the submission
        if (data.isNotEmpty) {
          // Clear the previous data before adding the new list of submissions
          mySubmissions.clear();

          // Map the raw data to Airline models and add them to the RxList
          final List<MySubmissionModel> mySubmissionRaw =
              data.map((dynamic json) => MySubmissionModel.fromJson(json)).toList();
          for (final MySubmissionModel submission in mySubmissionRaw) {
            mySubmissions.add(submission);
          }
          LoggerUtils.debug(mySubmissions.length);
        } else {
          // Show a message if no data is found
          _showErrorMessage(AppStrings.noSubmissionFound.tr);
        }
      } else {
        // Handle the case where the network request fails
        _showErrorMessage(response.jsonResponse?['message']);
      }
    } catch (e) {
      // Handle unexpected errors during the request or parsing
      LoggerUtils.debug("Error in getting submissions: $e");
      _showErrorMessage(AppStrings.unexpectedError.tr);
    } finally {
      loader.value = false;
    }
  }

  // Helper method to show an error message
  void _showErrorMessage(String message) {
    ToastManager.show(
      message: message,
      icon: const Icon(Icons.info_outline, color: AppColors.red),
      backgroundColor: AppColors.white,
      textColor: AppColors.red,
      animationDuration: const Duration(milliseconds: 500),
      animationCurve: Curves.easeInSine,
      duration: const Duration(seconds: 1),
    );
  }

  /// [dispose] Lifecycle method called when the controller is destroyed.
  ///
  /// Cleans up by resetting loading states and clearing lists and more...
  @override
  void dispose() {
    super.dispose();
  }
}
