import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'app_gradient_background.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? floatingActionButton;
  final bool useGradientBackground;
  final bool resizeToAvoidBottomInset;
  final EdgeInsetsGeometry? padding;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.floatingActionButton,
    this.useGradientBackground = true,
    this.resizeToAvoidBottomInset = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldContent = Scaffold(
      backgroundColor:
          useGradientBackground ? Colors.transparent : AppColors.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      body: SafeArea(
        child: Padding(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: body,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      floatingActionButton: floatingActionButton,
    );

    if (useGradientBackground) {
      return AppGradientBackground(child: scaffoldContent);
    }
    return scaffoldContent;
  }
}
