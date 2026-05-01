// lib/shared/widgets/app_scaffold.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import 'app_app_bar.dart';

/// Thin wrapper around [Scaffold] that enforces the app's default background
/// colour and status-bar appearance on every screen.
///
/// Set [showChangeNumberBar] to `true` to display the built-in "Change Number"
/// app bar. Pair with [onLeadingTap] to handle the action.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.bottomNavigationBarBackgroundColor,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.onLeadingTap,
    this.appBarTitle,
    this.showAppBar = false,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color? bottomNavigationBarBackgroundColor;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final VoidCallback? onLeadingTap;
  final String? appBarTitle;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor ?? AppColors.background(context),
        appBar: showAppBar
            ? AppAppBar(
                title: appBarTitle,
                onLeadingTap: onLeadingTap,
              )
            : appBar,
        bottomNavigationBar: bottomNavigationBar == null
            ? null
            : DecoratedBox(
                decoration: BoxDecoration(
                  color: bottomNavigationBarBackgroundColor ??
                      AppColors.bottomBarSurface(context),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.borderDefault(context),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.04),
                      blurRadius: 16.r,
                      offset: Offset(0, -4.h),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    child: bottomNavigationBar,
                  ),
                ),
              ),
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: showAppBar ? body : SafeArea(child: body),
      ),
    );
  }
}
