import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';

class AppPillChoiceOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const AppPillChoiceOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

class AppPillChoice<T> extends StatelessWidget {
  final List<AppPillChoiceOption<T>> options;
  final T? selectedValue;
  final List<T>? selectedValues;
  final ValueChanged<T>? onSelected;
  final ValueChanged<List<T>>? onMultiSelected;
  final bool isMultiSelect;

  const AppPillChoice({
    super.key,
    required this.options,
    this.selectedValue,
    this.selectedValues,
    this.onSelected,
    this.onMultiSelected,
    this.isMultiSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = isMultiSelect
            ? (selectedValues?.contains(option.value) ?? false)
            : selectedValue == option.value;

        return InkWell(
          onTap: () {
            if (isMultiSelect) {
              if (onMultiSelected != null) {
                final current = List<T>.from(selectedValues ?? []);
                if (current.contains(option.value)) {
                  current.remove(option.value);
                } else {
                  current.add(option.value);
                }
                onMultiSelected!(current);
              }
            } else {
              if (onSelected != null) {
                onSelected!(option.value);
              }
            }
          },
          borderRadius: AppRadius.pillBorder,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: AppRadius.pillBorder,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null) ...[
                  Icon(
                    option.icon,
                    size: 16,
                    color: isSelected
                        ? AppColors.surface
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  option.label,
                  style: AppTypography.caption.copyWith(
                    color:
                        isSelected ? AppColors.surface : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
