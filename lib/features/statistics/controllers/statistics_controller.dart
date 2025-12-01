import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pass_rate/core/common/widgets/custom_toast.dart';
import 'package:pass_rate/core/config/app_strings.dart';
import 'package:pass_rate/core/design/app_colors.dart';
import 'package:pass_rate/core/utils/device/device_utility.dart';
import 'package:pass_rate/core/utils/logger_utils.dart';
import 'package:pass_rate/features/statistics/model/top_airlines_submission_model.dart';
import '../../../core/config/app_url.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../model/airline_statistics_model.dart';
import '../model/top_airlines_pass_rate_model.dart';

class StatisticsController extends GetxController {
  final TextEditingController assessmentDateTEController = TextEditingController();
  final RxString backEndDateFormat = ''.obs;

  RxString statSearchAirlineName = ''.obs;
  final RxBool isLoadingPassRate = false.obs; // ===> loader
  final RxBool isLoadingSubmission = false.obs; // ===> loader
  final RxBool isLoadingSearch = false.obs; // ===> loader
  RxString filterYearOfPassRate = ''.obs;
  RxString filterYearOfSubmission = ''.obs;
  RxString filterYearOfSubmissionCount = ''.obs;
  final RxList<TopAirlineByPassRateModel> topAirlinesByPassRate = <TopAirlineByPassRateModel>[].obs;
  final RxList<TopAirlineBySubmissionModel> topAirlinesBySubmission =
      <TopAirlineBySubmissionModel>[].obs;
  Rxn<AirlineStatisticsModel> airlineStatistics = Rxn<AirlineStatisticsModel>();

  @override
  Future<void> onInit() async {
    topAirlineByPassRate();
    topAirlineBySubmissionCount();
    setCurrentDateFormat();
    super.onInit();
  }

  void setCurrentDateFormat() {
    final DateTime selectedDate = DateTime.now();
    final int selectedYear = DateTime.now().year;
    final String formattedDate = "$selectedYear-${DateFormat('MMMM').format(selectedDate)}";
    assessmentDateTEController.text = formattedDate;
    backEndDateFormat.value =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}";
  }

  ///
  /// ===================> Search Function ====================>
  ///
  ///
  Future<void> searchStatistics() async {
    try {
      isLoadingSearch.value = true;

      /// Setting the airline name if empty ===== >
      if (statSearchAirlineName.value.isEmpty) {
        ToastManager.show(
          message: AppStrings.selectAnAirline.tr,
          backgroundColor: AppColors.darkRed,
          icon: const Icon(CupertinoIcons.airplane, color: AppColors.white),
        );
        return;
      }
      DeviceUtility.hapticFeedback();
      LoggerUtils.debug(backEndDateFormat.value);
      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.statSearchByAirlineAndYear(
          airlineName: statSearchAirlineName.value,
          year: backEndDateFormat.value,
        ),
      );
      final dynamic jsonData = response.jsonResponse?['data'] ?? <dynamic>[];
      LoggerUtils.debug('here is the search data : $jsonData');

      // Convert the list of maps to a list of AirlinePassRate objects
      airlineStatistics.value = AirlineStatisticsModel.fromJson(jsonData);
      LoggerUtils.debug('here is the search data from controller: ${airlineStatistics.value}');
    } catch (e) {
      ToastManager.show(
        message: e.toString(),
        backgroundColor: AppColors.darkRed,
        textColor: AppColors.white,
      );
      LoggerUtils.error(e);
    } finally {
      isLoadingSearch.value = false;
    }
  }

  /// ===========================> Top Results part ==============================>
  ///
  /// =============> Top 5 by Pass Rate  ======>
  Future<void> topAirlineByPassRate() async {
    try {
      isLoadingPassRate.value = true;

      /// Setting the year if not selected ===== >
      if (filterYearOfPassRate.value.isEmpty) {
        filterYearOfPassRate.value = DateTime.now().year.toString();
      }
      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.topAirlinesByPassRate(year: filterYearOfPassRate.value),
      );
      final List<dynamic> jsonData = response.jsonResponse?['data'] ?? <dynamic>[];
      LoggerUtils.debug(jsonData);

      // Convert the list of maps to a list of AirlinePassRate objects
      topAirlinesByPassRate.value =
          jsonData.map((dynamic item) => TopAirlineByPassRateModel.fromJson(item)).toList();
    } catch (e) {
      ToastManager.show(
        message: e.toString(),
        backgroundColor: AppColors.darkRed,
        textColor: AppColors.white,
      );
      LoggerUtils.error(e);
    } finally {
      isLoadingPassRate.value = false;
    }
  }

  ///
  /// =============> Top 5 by Submission Count  ======>
  ///
  Future<void> topAirlineBySubmissionCount() async {
    try {
      isLoadingSubmission.value = true;

      /// Setting the year if not selected ===== >
      if (filterYearOfSubmission.value.isEmpty) {
        filterYearOfSubmission.value = DateTime.now().year.toString();
      }
      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.topAirlinesBySubmission(year: filterYearOfSubmission.value),
      );
      final List<dynamic> jsonData = response.jsonResponse?['data'] ?? <dynamic>[];
      // LoggerUtils.debug(jsonData);

      // Convert the list of maps to a list of AirlinePassRate objects
      topAirlinesBySubmission.value =
          jsonData.map((dynamic item) => TopAirlineBySubmissionModel.fromJson(item)).toList();
    } catch (e) {
      ToastManager.show(
        message: e.toString(),
        backgroundColor: AppColors.darkRed,
        textColor: AppColors.white,
      );
      LoggerUtils.error(e);
    } finally {
      isLoadingSubmission.value = false;
    }
  }

  /// [dispose] Lifecycle method called when the controller is destroyed.
  ///
  /// Cleans up by resetting loading states and clearing lists and more...
  @override
  void dispose() {
    super.dispose();
  }
}
