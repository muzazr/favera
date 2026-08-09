import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../formatters/currency_formatter.dart';

class AppAmountField extends StatefulWidget {
  final String? label;
  final int initialAmount;
  final ValueChanged<int>? onChanged;
  final String? errorText;
  final bool isExpense;
  final bool enabled;

  const AppAmountField({
    super.key,
    this.label,
    this.initialAmount = 0,
    this.onChanged,
    this.errorText,
    this.isExpense = true,
    this.enabled = true,
  });

  @override
  State<AppAmountField> createState() => _AppAmountFieldState();
}

class _AppAmountFieldState extends State<AppAmountField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialText = widget.initialAmount > 0
        ? CurrencyFormatter.formatNumber(widget.initialAmount)
        : '';
    _controller = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    final parsedInt = CurrencyFormatter.parse(text);
    final formattedText =
        parsedInt > 0 ? CurrencyFormatter.formatNumber(parsedInt) : '';

    if (_controller.text != formattedText) {
      _controller.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }

    if (widget.onChanged != null) {
      widget.onChanged!(parsedInt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountColor =
        widget.isExpense ? AppColors.accentOrange : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style:
                AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.s8),
        ],
        TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          enabled: widget.enabled,
          onChanged: _onTextChanged,
          style: AppTypography.displayBalance.copyWith(
            color: amountColor,
            fontSize: 26,
          ),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: AppTypography.displayBalance.copyWith(
              color: AppColors.disabledText,
              fontSize: 26,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Rp',
                    style: AppTypography.displayBalance.copyWith(
                      color: amountColor,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            errorText: widget.errorText,
          ),
        ),
      ],
    );
  }
}
