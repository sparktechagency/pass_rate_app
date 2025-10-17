import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pass_rate/core/config/app_constants.dart';
import 'package:pass_rate/core/config/app_strings.dart';
import 'package:pass_rate/core/design/app_colors.dart';
import 'package:pass_rate/core/extensions/strings_extensions.dart';
import 'package:pass_rate/core/utils/device/device_info.dart';
import 'package:pass_rate/core/utils/logger_utils.dart';
import 'package:pass_rate/features/support/screens/support_screen.dart';
import '../../../core/common/widgets/custom_dropdown.dart';
import '../../../core/common/widgets/custom_modal.dart';
import '../../../core/common/widgets/custom_toast.dart';
import '../../../core/common/widgets/multi_select_drop_down.dart';
import '../../../core/config/app_url.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/device/device_utility.dart';
import '../../../core/utils/enum.dart';
import '../model/airline_model.dart';
import '../model/assessment_model.dart';
import '../model/submission_response.dart';

class AssessmentController extends GetxController {
  // Make it a regular TextEditingController, not Rx<TextEditingController>
  final TextEditingController assessmentDateTEController = TextEditingController();

  // Add a separate reactive string to track the date value
  RxString assessmentDate = ''.obs;
  String isoFormatString = '';

  RxBool isLottieVisible = false.obs;
  RxBool loader = false.obs;
  RxBool submitLoader = false.obs;
  RxString selectedAirlineName = ''.obs;
  RxString selectedAirlineId = ''.obs;
  RxList<Assessment> assessmentListDetails = <Assessment>[].obs;
  Rx<ResultStatus> resultStatus = Rx<ResultStatus>(ResultStatus.none);

  // Make this a proper RxBool property, not a getter
  RxBool allAssessmentsCompletedRx = RxBool(false);

  // Add observable progress values
  RxDouble completionPercentageRx = RxDouble(0.0);
  RxInt completedStepsRx = RxInt(0);

  @override
  Future<void> onInit() async {
    await getAirlineNames();
    super.onInit();

    // Add listener to text controller to update reactive string
    assessmentDateTEController.addListener(_onDateTextChanged);
  }

  void _onDateTextChanged() {
    assessmentDate.value = assessmentDateTEController.text;
    checkAndUpdateCompletion();
  }

  ///================================> For the Airline Name section ==========================>
  final RxList<DropdownItem<String>> airlineNames = <DropdownItem<String>>[].obs;
  final RxList<DropdownItem<Airline>> airlinesDetails = <DropdownItem<Airline>>[].obs;

  Future<void> getAirlineNames() async {
    try {
      loader.value = true;
      final NetworkResponse postResponse = await NetworkCaller().getRequest(AppUrl.getAirlines);

      if (postResponse.isSuccess) {
        final List<dynamic> data = postResponse.jsonResponse?['data'] ?? <dynamic>[];

        if (data.isNotEmpty) {
          airlineNames.clear();
          final List<Airline> airlines =
              data.map((dynamic json) => Airline.fromJson(json)).toList();
          for (final Airline airline in airlines) {
            airlineNames.add(
              DropdownItem<String>(value: airline.name, label: airline.name.toCapitalize),
            );
            airlinesDetails.add(
              DropdownItem<Airline>(value: airline, label: airline.name.toCapitalize),
            );
          }
        } else {
          _showErrorMessage(AppStrings.noAirlineFound.tr);
        }
      } else {
        _showErrorMessage(AppStrings.networkError.tr);
      }
    } catch (e) {
      LoggerUtils.debug("Error in getAirlineNames: $e");
      _showErrorMessage(AppStrings.unexpectedError.tr);
    } finally {
      loader.value = false;
    }
  }

  void _showErrorMessage(String message) {
    ToastManager.show(
      message: message,
      icon: const Icon(Icons.info_outline, color: Colors.red),
      backgroundColor: AppColors.white,
      textColor: Colors.red,
      animationDuration: const Duration(milliseconds: 500),
      animationCurve: Curves.easeInSine,
      duration: const Duration(seconds: 1),
    );
  }

  // Update methods that trigger completion check
  void updateSelectedAirline(Airline? airline) {
    if (airline?.name != null) {
      selectedAirlineName.value = airline!.name;
      selectedAirlineId.value = airline.id;
      checkAndUpdateCompletion();
    }
  }

  void updateAssessmentList(List<Assessment> selectedItems) {
    assessmentListDetails.value = selectedItems;
    checkAndUpdateCompletion();
  }

  void assessmentStatusButtonSelected(ResultStatus status) {
    resultStatus.value = status;
    checkAndUpdateCompletion();
  }

  // Method to handle date selection from date picker
  void onDateSelected(DateTime? selectedDate) {
    if (selectedDate != null) {
      final String formattedDate =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}";
      assessmentDateTEController.text = formattedDate;
      // The listener will automatically call checkAndUpdateCompletion()
    }
  }

  // Central method to check completion and handle lottie logic
  void checkAndUpdateCompletion() {
    // LoggerUtils.debug("=== Progress Update Debug ===");
    // LoggerUtils.debug("Airline: '${selectedAirlineName.value}' (${selectedAirlineName.value.isNotEmpty})");
    // LoggerUtils.debug("Date: '${assessmentDate.value}' (${assessmentDate.value.isNotEmpty})");
    // LoggerUtils.debug("Assessments: ${assessmentList.length} items");
    // LoggerUtils.debug("Status: ${resultStatus.value} (${resultStatus.value != ResultStatus.none})");

    final bool isCompleted = allAssessmentsCompleted;
    final double newProgress = completionPercentage;
    final int newSteps = completedSteps;

    // Update progress values
    completionPercentageRx.value = newProgress;
    completedStepsRx.value = newSteps;

    if (isCompleted && !allAssessmentsCompletedRx.value) {
      // Just became completed - show lottie
      allAssessmentsCompletedRx.value = true;
      _showLottieAnimation();
    } else if (!isCompleted && allAssessmentsCompletedRx.value) {
      // No longer completed - reset everything
      allAssessmentsCompletedRx.value = false;
      isLottieVisible.value = false;
      // LoggerUtils.debug("Assessment no longer completed - hiding lottie");
    }
  }

  void _showLottieAnimation() {
    isLottieVisible.value = true;

    // Hide lottie after 3 seconds
    Future<void>.delayed(const Duration(seconds: 3), () {
      isLottieVisible.value = false;
    });
  }

  ///================================> For the Assessment section ==========================>

  final RxList<MultiSelectItem<String>> assessmentItems = <MultiSelectItem<String>>[].obs;
  final RxList<MultiSelectItem<Assessment>> assessmentItemsDetails =
      <MultiSelectItem<Assessment>>[].obs;

  Future<void> getAssessmentList() async {
    try {
      loader.value = true;
      final NetworkResponse getResponse = await NetworkCaller().getRequest(
        AppUrl.airlineAssessment,
      );

      if (getResponse.statusCode == 200) {
        final List<dynamic> data = getResponse.jsonResponse?['data'] ?? <dynamic>[];

        if (data.isNotEmpty) {
          assessmentItems.clear();
          assessmentItemsDetails.clear();
          final List<Assessment> assessments =
              data.map((dynamic json) => Assessment.fromJson(json)).toList();
          for (final Assessment assessment in assessments) {
            assessmentItems.add(
              MultiSelectItem<String>(value: assessment.name, label: assessment.name.toCapitalize),
            );
            assessmentItemsDetails.add(
              MultiSelectItem<Assessment>(value: assessment, label: assessment.name.toCapitalize),
            );
          }
        } else {
          _showErrorMessage(AppStrings.noAirlineFound.tr);
        }
      } else {
        _showErrorMessage(AppStrings.networkError.tr);
      }
    } catch (e) {
      LoggerUtils.debug("Error in getAirlineNames: $e");
      _showErrorMessage(AppStrings.unexpectedError.tr);
    } finally {
      loader.value = false;
    }
  }

  // Check if all assessments have been completed
  bool get allAssessmentsCompleted {
    return (selectedAirlineName.value.isNotEmpty &&
        assessmentDate.value.isNotEmpty && // Use the reactive string instead
        assessmentListDetails.isNotEmpty &&
        resultStatus.value != ResultStatus.none);
  }

  // Get completion percentage (0.0 to 1.0 for progress bar)
  double get completionPercentage {
    const int totalSteps = 4;
    int completedSteps = 0;

    if (selectedAirlineName.value.isNotEmpty) {
      completedSteps++;
    }
    if (assessmentDate.value.isNotEmpty) {
      // Use the reactive string
      completedSteps++;
    }
    if (assessmentListDetails.isNotEmpty) {
      completedSteps++;
    }
    if (resultStatus.value != ResultStatus.none) {
      completedSteps++;
    }

    return completedSteps / totalSteps;
  }

  int get completionPercentageInt {
    return (completionPercentage * 100).round();
  }

  int get completedSteps {
    int completed = 0;
    if (selectedAirlineName.value.isNotEmpty) {
      completed++;
    }
    if (assessmentDate.value.isNotEmpty) {
      // Use the reactive string
      completed++;
    }
    if (assessmentListDetails.isNotEmpty) {
      completed++;
    }
    if (resultStatus.value != ResultStatus.none) {
      completed++;
    }
    return completed;
  }

  ///===================> Submission Logic ================>
  Future<void> submitAssessment() async {
    submitLoader.value = true;
    try {
      if (allAssessmentsCompleted) {
        DeviceUtility.hapticFeedback();

        /// for the list of assessment Strings
        final List<String> assessmentList = <String>[];

        for (final Assessment assessment in assessmentListDetails) {
          assessmentList.add(assessment.id);
        }

        LoggerUtils.debug(assessmentList); // here is the list of the selected assessment .
        final String deviceID = await DeviceIdService.getDeviceId() ?? '';

        final Map<String, dynamic> submissionData = <String, dynamic>{
          "deviceId": deviceID,
          // "deviceId": AppConstants.demoDeviceId,
          "airlineId": selectedAirlineId.value,
          "date": isoFormatString,
          "assessments": assessmentList,
          "status": resultStatus.value.displayName,
        };

        LoggerUtils.debug("Submission Data: \n${jsonEncode(submissionData)}");

        final NetworkResponse response = await NetworkCaller().postRequest(
          AppUrl.postSubmission,
          body: submissionData,
        );

        if (response.isSuccess) {
          isLottieVisible.value = true;

          ToastManager.show(
            message: AppStrings.responsesSubmitted.tr,
            icon: const Icon(CupertinoIcons.check_mark_circled, color: AppColors.white),
          );
          LoggerUtils.debug('Submission response : ${response.jsonResponse?['data']}');
          final SubmissionResponse submissionResponse = SubmissionResponse.fromJson(
            response.jsonResponse?['data'] ?? <String, dynamic>{},
          );
          await Get.toNamed(AppRoutes.supportPage);
          Get.offNamed(AppRoutes.confirmSubmissionPage, arguments: submissionResponse);
        } else {
          ToastManager.show(
            message: response.jsonResponse?['message'] ?? AppStrings.unexpectedError.tr,
            icon: const Icon(CupertinoIcons.info_circle_fill, color: AppColors.white),
            backgroundColor: AppColors.darkRed,
            textColor: AppColors.white,
          );
        }
      } else {
        ToastManager.show(
          message: AppStrings.pleaseMarkAllTheAssessment.tr,
          icon: const Icon(CupertinoIcons.info_circle_fill, color: AppColors.white),
          backgroundColor: AppColors.darkRed,
          textColor: AppColors.white,
        );
      }
    } catch (e, stackTrace) {
      LoggerUtils.error("Error submitting assessment: $e\n$stackTrace");
      ToastManager.show(
        message: AppStrings.unexpectedError.tr,
        icon: const Icon(CupertinoIcons.info_circle_fill, color: AppColors.white),
        backgroundColor: AppColors.darkRed,
        textColor: AppColors.white,
      );
    } finally {
      submitLoader.value = false;
    }
  }

  ///================= Resets the page ==============>
  Future<void> resetAssessments() async {
    airlineNames.clear();
    selectedAirlineName.value = '';
    assessmentListDetails.clear();
    resultStatus.value = ResultStatus.none;
    assessmentDate.value = ''; // Reset the reactive string too
    isLottieVisible.value = false;
    loader.value = false;
    submitLoader.value = false;
    allAssessmentsCompletedRx.value = false;
    completionPercentageRx.value = 0.0;
    completedStepsRx.value = 0;
    // await getAirlineNames();
  }

  @override
  void onClose() {
    assessmentDateTEController.removeListener(_onDateTextChanged);
    super.onClose();
  }
}
