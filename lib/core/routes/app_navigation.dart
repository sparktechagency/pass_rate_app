import 'package:get/get.dart';
import 'package:pass_rate/core/routes/app_routes.dart';
import 'package:pass_rate/features/assessment/bindings/assessment_binding.dart';
import 'package:pass_rate/features/assessment/screens/confirm_screen.dart';
import 'package:pass_rate/features/home/bindings/home_binding.dart';
import 'package:pass_rate/features/payment/bindings/payment_binding.dart';
import 'package:pass_rate/features/payment/screens/payment_screen.dart';
import 'package:pass_rate/features/splash_screen/binding/splash_binding.dart';
import 'package:pass_rate/features/splash_screen/screens/next_splash_screen.dart';
import 'package:pass_rate/features/statistics/bindings/statistics_binding.dart';
import 'package:pass_rate/features/statistics/screens/statistics_screen.dart';
import 'package:pass_rate/features/submissions/bindings/submissions_binding.dart';
import 'package:pass_rate/features/submissions/screens/submissions_screen.dart';
import 'package:pass_rate/features/support/bindings/support_binding.dart';
import 'package:pass_rate/features/support/screens/support_screen.dart';
import '../../features/assessment/screens/submit_assessment_screen.dart';
import '../../features/home/screens/home_page.dart';
import '../../features/splash_screen/screens/splash_screen_homepage.dart';

class AppNavigation {
  AppNavigation._();

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    /// Add the pages like this ================>
    GetPage<dynamic>(
      name: AppRoutes.initialRoute,
      page: () => const HomePage(),
      transition: Transition.zoom,
      binding: HomeBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.homeRoute,
      page: () => const HomePage(),
      transition: Transition.zoom,
      binding: HomeBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.submissionPage,
      transition: Transition.rightToLeft,
      page: () => const SubmissionsScreen(),
      binding: SubmissionsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.supportPage,
      transition: Transition.downToUp,
      page: () => const SupportScreen(),
      binding: SupportBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.submitAssessment,
      transition: Transition.upToDown,
      page: () => const SubmitAssessmentScreen(),
      binding: AssessmentBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.confirmSubmissionPage,
      page: () => const ConfirmSubmissionPage(),
      binding: AssessmentBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.statisticsScreen,
      transition: Transition.leftToRight,
      page: () => const StatisticsScreen(),
      binding: StatisticsBinding(),
    ),

    GetPage<dynamic>(
      name: AppRoutes.firstSplashScreen,
      page: () => const SplashScreenHomepage(),
      binding: SplashScreenBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.nextSplashScreen,
      page: () => const NextSplashScreen(),
      transition: Transition.noTransition,
      binding: SplashScreenBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.paymentScreen,
      page: () => const PaymentScreen(),
      transition: Transition.noTransition,
      binding: PaymentBinding(),
    ),
  ];
}
