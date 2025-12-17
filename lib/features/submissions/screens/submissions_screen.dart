import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pass_rate/core/config/app_sizes.dart';
import 'package:pass_rate/core/config/app_strings.dart';
import 'package:pass_rate/core/extensions/context_extensions.dart';
import 'package:pass_rate/core/extensions/widget_extensions.dart';
import 'package:pass_rate/shared/widgets/slide_animation.dart';
import '../../../core/common/widgets/floating_support.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/utils/device/device_utility.dart';
import '../../../shared/widgets/custom_appbar.dart' show CustomAppBar;
import '../../../shared/widgets/lottie_loader.dart';
import '../controllers/submissions_controller.dart';
import '../model/my_submission.dart';
import '../widget/submission_tile.dart';

class SubmissionsScreen extends GetView<SubmissionsController> {
  const SubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(label: AppStrings.mySubmission.tr),

      /// Lower Helping Button ============>
      /// hiding donation part for ios
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          DeviceUtility.isAndroid() ? const SupportFloatingWidget() : const SizedBox.shrink(),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        child: Column(
          children: <Widget>[
            const SizedBox(height: AppSizes.md),

            /// Search field with clear button ====>
            TextFormField(
              controller: controller.searchTEController,
              decoration: InputDecoration(
                hintText: AppStrings.search.tr,
                prefixIcon: const Icon(CupertinoIcons.search, color: AppColors.primaryColor),
                suffixIcon: Obx(
                  () =>
                      controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                            icon: const Icon(CupertinoIcons.clear, color: AppColors.primaryColor),
                            onPressed: controller.clearSearch,
                          )
                          : const SizedBox.shrink(),
                ),
              ),
              onChanged: (String value) {
                // Real-time search as user types
                controller.searchQuery.value = value.trim();
              },
            ),
            const SizedBox(height: AppSizes.md),

            ///=====================> Search button ===============>
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                ),
                onPressed: controller.handleSearch,
                label: Text(AppStrings.search.tr, style: const TextStyle(color: AppColors.white)),
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            /// Submission Container with search results ====>
            Expanded(
              child: Obx(
                () => Visibility(
                  replacement: const LottieLoaderWidget().centered,
                  visible: controller.loader.value == false,
                  child: Obx(() {
                    final List<MySubmissionModel> filteredSubmissions =
                        controller.filteredSubmissions;

                    // Show "No results found" if searching and no results
                    if (controller.searchQuery.value.isNotEmpty && filteredSubmissions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              CupertinoIcons.search,
                              size: 64,
                              color: AppColors.primaryColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: AppSizes.md),
                            Text(
                              'No results found for "${controller.searchQuery.value}"',
                              style: context.txtTheme.bodyMedium?.copyWith(
                                color: AppColors.primaryColor.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredSubmissions.length,
                      itemBuilder: (BuildContext context, int index) {
                        final MySubmissionModel submission = filteredSubmissions[index];

                        return SlideAnimation(
                          delay: Duration(milliseconds: index * 100),
                          // Reduced delay for better UX
                          child: SubmissionTile(
                            submittedAssessment: submission,
                            onDelete: () {
                              controller.handleDelete(submission: submission);
                            },
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: AppSizes.md);
                      },
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
