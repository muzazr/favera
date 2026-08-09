import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  final String routeName;
  final String routePath;
  final String? description;
  final List<String>? targetSubRoutes;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.routeName,
    required this.routePath,
    this.description,
    this.targetSubRoutes,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return AppScaffold(
      appBar: AppBar(
        title: Text(title),
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.s16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.dashboard_customize_outlined,
                          color: AppColors.primaryDark,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTypography.cardTitle),
                            const SizedBox(height: 2),
                            Text('Route: $routeName',
                                style: AppTypography.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.border),
                  Text('Path: $routePath', style: AppTypography.bodyMedium),
                  if (description != null) ...[
                    const SizedBox(height: 8),
                    Text(description!, style: AppTypography.helper),
                  ],
                ],
              ),
            ),
            if (targetSubRoutes != null && targetSubRoutes!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s24),
              const Text('Sub-Routes Dalam Modul Ini:',
                  style: AppTypography.sectionTitle),
              const SizedBox(height: AppSpacing.s12),
              ...targetSubRoutes!.map((path) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                  child: AppCard(
                    onTap: () => context.push(path),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(path, style: AppTypography.bodyMedium),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: AppSpacing.s24),
            Row(
              children: [
                if (canPop)
                  Expanded(
                    child: AppButton(
                      text: 'Kembali',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.pop(),
                      icon: Icons.arrow_back_rounded,
                    ),
                  ),
                if (canPop) const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Katalog Route',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.push(AppRoutePaths.debugRoutes),
                    icon: Icons.alt_route_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
