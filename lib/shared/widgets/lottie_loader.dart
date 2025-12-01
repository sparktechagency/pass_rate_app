import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pass_rate/core/extensions/context_extensions.dart';

import '../../core/config/app_asset_path.dart';
import '../../core/design/app_colors.dart';

class LottieLoaderWidget extends StatelessWidget {
  const LottieLoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  Lottie.asset(
      ////========= Lottie color changed in a way  =====>
      delegates: LottieDelegates(
        values: <ValueDelegate<dynamic>>[
          ValueDelegate.color(const <String>[
            '**',
          ], value: AppColors.primaryColor),
        ],
      ),
      AppAssetPath.aeroplaneLoader,
      height: context.screenHeight * 0.25,
      backgroundLoading: true,
    );
  }
}