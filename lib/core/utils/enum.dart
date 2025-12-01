import 'package:pass_rate/core/config/app_strings.dart';

enum ResultStatus {
  passed(AppStrings.pass),
  failed(AppStrings.fail),
  none('');

  const ResultStatus(this.displayName);

  final String displayName;


  // Convert from string
  static ResultStatus? fromString(String value) {
    for (final ResultStatus status in ResultStatus.values) {
      if (status.displayName.toLowerCase() == value.toLowerCase()) {
        return status;
      }
    }
    return null;
  }
}

/// ResultStatus status = ResultStatus.passed;
/// status.displayName ===> ResultStatus.passed.displayName
