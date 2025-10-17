import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pass_rate/core/common/widgets/custom_svg.dart';
import 'package:pass_rate/core/config/app_strings.dart';
import 'package:pass_rate/core/config/app_sizes.dart';
import 'package:pass_rate/core/design/app_icons.dart';
import 'package:pass_rate/core/extensions/context_extensions.dart';
import 'package:pass_rate/core/extensions/strings_extensions.dart';
import 'package:pass_rate/core/extensions/widget_extensions.dart';
import 'package:pass_rate/core/utils/custom_loader.dart';
import 'package:pass_rate/features/assessment/controllers/assessment_controller.dart';
import 'package:pass_rate/shared/widgets/custom_appbar.dart';
import 'package:pass_rate/shared/widgets/slide_animation.dart';
import '../../../core/common/widgets/custom_dropdown.dart';
import '../../../core/common/widgets/date_picker_field.dart';
import '../../../core/common/widgets/floating_support.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/utils/logger_utils.dart';
import '../../../shared/widgets/lottie_loader.dart';
import '../controllers/statistics_controller.dart';
import '../model/top_airlines_pass_rate_model.dart';
import '../model/top_airlines_submission_model.dart';

class StatisticsScreen extends GetView<StatisticsController> {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// ========== to get the airline names =====>
    final AssessmentController assessmentController = Get.put(AssessmentController());
    return Scaffold(
      appBar: CustomAppBar(label: AppStrings.statisticsOverview.tr),

      /// Lower Helping Button ============>
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const SupportFloatingWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppStrings.checkPassRatesAssessmentContent.tr,
              style: context.txtTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.lg),
            CustomDropdown<String>(
              label: AppStrings.airlineName.tr,
              isRequired: true,
              items: assessmentController.airlineNames,
              hint: AppStrings.chooseAirlineName.tr,
              dropdownMaxHeight: 250,
              onChanged: (String? value) async {
                LoggerUtils.debug('Selected searchable country: $value');
                if (value != null) {
                  controller.statSearchAirlineName.value = value;
                  await controller.searchStatistics();
                }
              },
              validator: (String? value) {
                if (value == null) {
                  return 'Please select a type';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.lg),

            /// Select Year and Month ================ >
            ReusableDatePickerField(
              labelText: AppStrings.selectYearAndMonth.tr,
              hintText: AppStrings.chooseAssessmentYear.tr,
              controller: controller.assessmentDateTEController,
              onDateSelected: (DateTime selectedDate) {
                controller.backEndDateFormat.value =
                    "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}";
              },
            ),
            const SizedBox(height: AppSizes.lg),

            /// ========> The Search button ==============>
            Obx(
              () => Visibility(
                visible: controller.isLoadingSearch.value == false,
                replacement: const CustomLoading(),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                    ),
                    onPressed: () async {
                      await controller.searchStatistics();
                    },
                    icon: const Icon(CupertinoIcons.search, color: AppColors.white),
                    label: Text(
                      AppStrings.search.tr,
                      style: const TextStyle(color: AppColors.white),
                    ),
                    // icon: const Icon(Icons.search,size: 32,color: AppColors.white,),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.md),

            /// ==============> Search Result container =======>
            Obx(
              () =>
                  controller.airlineStatistics.value != null
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(AppStrings.searchResult.tr, style: context.txtTheme.titleMedium),
                          const SizedBox(height: AppSizes.md),
                          SlideAnimation(
                            key: ValueKey<int>(DateTime.now().millisecondsSinceEpoch),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md,
                                vertical: AppSizes.md,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primaryColor),
                                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    controller.airlineStatistics.value?.airlineName ??
                                        controller.statSearchAirlineName.value,
                                    // The airline name
                                    style: context.txtTheme.titleMedium,
                                  ),
                                  Text(
                                    // the date
                                    controller.assessmentDateTEController.text,
                                    style: context.txtTheme.labelMedium,
                                  ),

                                  const SizedBox(height: AppSizes.lg),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(AppStrings.totalResponses.tr),
                                      Text(
                                        (controller.airlineStatistics.value?.totalSubmissions ?? 0)
                                            .toString(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSizes.sm),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(AppStrings.successRate.tr),
                                      Text(
                                        controller.airlineStatistics.value?.successRate == -1
                                            ? 'N/A'
                                            : '${controller.airlineStatistics.value!.successRate.toStringAsFixed(2)}%',
                                        style: context.txtTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSizes.sm),
                                  const Divider(),
                                  Text(
                                    AppStrings.assessmentContent.tr,
                                    style: context.txtTheme.titleMedium,
                                  ),
                                  const SizedBox(height: AppSizes.sm),
                                  ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Text(
                                        (controller.airlineStatistics.value?.assessments[index] ??
                                                AppStrings.assessmentContent)
                                            .toCapitalize,
                                      );
                                    },
                                    itemCount:
                                        controller.airlineStatistics.value?.assessments.length ?? 0,
                                  ),

                                  const SizedBox(height: AppSizes.md),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                      : const SizedBox.shrink(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /// ================> Top Airlines by Pass Rate ================>
                const SizedBox(height: AppSizes.md),
                Text(AppStrings.topResults.tr, style: context.txtTheme.titleMedium),
                const SizedBox(height: AppSizes.md),
                Obx(
                  () => Visibility(
                    visible: controller.isLoadingPassRate.value == false,
                    replacement: const LottieLoaderWidget().centered,
                    child: statisticsContainer(
                      selectedYear: int.tryParse(controller.filterYearOfPassRate.value),
                      context: context,
                      title: AppStrings.topAirlinesByPassRate.tr,
                      list: controller.topAirlinesByPassRate,
                      onYearSelected: (int int) async {
                        controller.filterYearOfPassRate.value = int.toString();
                        await controller.topAirlineByPassRate();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.md),

                /// ================> Top Airlines by Submission Count ================>
                Obx(
                  () => Visibility(
                    visible: controller.isLoadingSubmission.value == false,
                    replacement: const LottieLoaderWidget().centered,
                    child: statisticsContainer(
                      selectedYear: int.tryParse(controller.filterYearOfSubmission.value),
                      context: context,
                      title: AppStrings.topAirlineSubmission.tr,
                      list: controller.topAirlinesBySubmission,
                      onYearSelected: (int int) async {
                        controller.filterYearOfSubmission.value = int.toString();
                        await controller.topAirlineBySubmissionCount();
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.xxxL * 2),
          ],
        ),
      ),
    );
  }

  Container statisticsContainer({
    required BuildContext context,
    required String title,
    required List<dynamic> list,
    required Function(int) onYearSelected,
    int? selectedYear,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(title, style: context.txtTheme.headlineMedium),
              Material(
                child: InkWell(
                  splashColor: AppColors.blue.withValues(alpha: 0.5),
                  onTap: () {
                    _showYearFilterDialog(context, onYearSelected, selectedYear);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    child: Row(
                      spacing: 3,
                      children: <Widget>[
                        Text(
                          selectedYear?.toString() ?? AppStrings.year,
                          style: context.txtTheme.labelSmall,
                        ),
                        const Icon(CupertinoIcons.chevron_down, size: 10, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Transform.translate(
                offset: const Offset(0, 5),
                child: Container(
                  height: 5,
                  width: 50,
                  decoration: const BoxDecoration(color: AppColors.primaryColor),
                ),
              ),
              const SizedBox(width: 2),
              const Expanded(child: Divider(thickness: 0.5)),
              CustomSvgImage(assetName: AppIcons.dividerIcon, width: 20, height: 10),
            ],
          ),
          Visibility(
            visible: list.isNotEmpty,
            replacement: Text(AppStrings.noDataForTheSelectedYear.tr),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                final dynamic item = list[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      if (item is TopAirlineByPassRateModel) ...<Widget>[
                        Text(item.airlineName),
                        Text("${item.successRate.toStringAsFixed(1).toString()}%"),
                      ] else if (item is TopAirlineBySubmissionModel) ...<Widget>[
                        Text(item.name),
                        Text(item.submissionCount.toInt().toString()),
                      ],
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to show year filter dialog
  void _showYearFilterDialog(
    BuildContext context,
    Function(int) onYearSelected,
    int? currentSelectedYear,
  ) {
    // Generate list of years (last 10 years + current year)
    final int currentYear = DateTime.now().year;
    final List<int> years = List.generate(10, (int index) => currentYear - index);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
            border: Border.all(color: AppColors.primaryColor, width: 2),
          ),
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(AppStrings.selectYear.tr, style: context.txtTheme.headlineMedium),
              const SizedBox(height: AppSizes.md),

              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: years.length,
                  itemBuilder: (BuildContext context, int index) {
                    final int year = years[index];
                    return ListTile(
                      title: Text(year.toString()),
                      trailing:
                          currentSelectedYear == year
                              ? const Icon(CupertinoIcons.check_mark, color: AppColors.primaryColor)
                              : null,
                      onTap: () {
                        Get.back();
                        onYearSelected(year);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        AppStrings.cancel.tr,
                        style: context.txtTheme.headlineMedium?.copyWith(color: AppColors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
