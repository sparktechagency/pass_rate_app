import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pass_rate/core/config/app_strings.dart';
import 'package:pass_rate/core/extensions/context_extensions.dart';
import 'package:pass_rate/core/extensions/strings_extensions.dart';
import 'package:pass_rate/features/submissions/model/my_submission.dart';
import '../../../core/common/widgets/custom_modal.dart';
import '../../../core/common/widgets/custom_svg.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_icons.dart';
import '../../../core/utils/enum.dart';
import '../../../shared/widgets/app_button.dart' show AppButton;

class SubmissionTile extends StatelessWidget {
  final MySubmissionModel submittedAssessment;
  final VoidCallback onDelete;

  const SubmissionTile({super.key, required this.submittedAssessment, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    // Format the date as "yyyy - Month .."
    final String formattedDate = DateFormat('yyyy - MMMM').format(submittedAssessment.createdAt);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(submittedAssessment.airline, style: context.txtTheme.titleMedium),
              ),
              Material(
                color: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  splashColor: AppColors.greyLight,
                  onTap: () {
                    /// =================> Open the Delete Modal ===============>
                    CustomBottomSheet.show(
                      title: AppStrings.deleteTitle.tr,
                      context: context,
                      child: Column(
                        children: <Widget>[
                          Row(
                            spacing: AppSizes.md,
                            children: <Widget>[
                              Expanded(
                                child: AppButton(
                                  bgColor: AppColors.primaryColor,
                                  textColor: AppColors.white,
                                  labelText: AppStrings.yes.tr,
                                  onTap: () {
                                    onDelete();
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              Expanded(
                                child: AppButton(
                                  textColor: AppColors.primaryColor,
                                  labelText: AppStrings.no.tr,
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(CupertinoIcons.delete, color: AppColors.red),
                  ),
                ),
              ),
            ],
          ),
          Text(
            formattedDate,
            style: context.txtTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),

          const SizedBox(height: AppSizes.lg),

          // Status Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${AppStrings.status.tr}:',
                style: context.txtTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              _buildStatusChip(submittedAssessment.status),
            ],
          ),

          const SizedBox(height: AppSizes.lg),

          // Assessments List (if needed)
          Visibility(
            visible: submittedAssessment.assessments.isNotEmpty,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${AppStrings.assessment.tr}:',
                  style: context.txtTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children:
                      submittedAssessment.assessments
                          .map(
                            (String assessment) => Text(
                              "- ${assessment.toCapitalize}",
                              style: context.txtTheme.bodySmall,
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.md),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final bool isPassed = status == ResultStatus.passed.displayName;

    return IntrinsicWidth(
      child: Container(
        constraints: const BoxConstraints(minWidth: 60, maxWidth: 100),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color:
              isPassed ? AppColors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isPassed ? AppColors.green : Colors.red, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                status,
                style: TextStyle(
                  color: isPassed ? AppColors.green : AppColors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            CustomSvgImage(
              assetName: isPassed ? AppIcons.passedIcon : AppIcons.failedIcon,
              height: 12,
              width: 12,
            ),
          ],
        ),
      ),
    );
  }
}
