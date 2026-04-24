// lib/shared/widgets/app_scaffold.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.safeAreaBottom = true,
    this.showChangeNumberBar = false,
    this.onLeadingTap,
    this.appBarTitle,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool safeAreaBottom;
  final bool showChangeNumberBar;
  final VoidCallback? onLeadingTap;
  final String? appBarTitle;

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
        appBar: showChangeNumberBar
            ? AppAppBar(
                title: appBarTitle,
                onLeadingTap: onLeadingTap,
              )
            : appBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: SafeArea(
          bottom: safeAreaBottom,
          child: body,
        ),
      ),
    );
  }
}
