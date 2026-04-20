// lib/shared/widgets/app_scaffold.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

/// Thin wrapper around [Scaffold] that enforces the app's default background
/// colour and status-bar appearance on every screen.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.safeAreaBottom = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool safeAreaBottom;

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
        appBar: appBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: SafeArea(
          bottom: safeAreaBottom,
          child: body,
        ),
      ),
    );
  }
}
