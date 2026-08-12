import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static final NumberFormat _compactFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  /// Formats integer rupiah to standard format: e.g. 1500000 -> "Rp1.500.000"
  static String format(int amount) {
    return _formatter.format(amount);
  }

  /// Formats integer rupiah without symbol: e.g. 1500000 -> "1.500.000"
  static String formatNumber(int amount) {
    return _compactFormatter.format(amount).trim();
  }

  /// Safely parses string into integer rupiah: e.g. "Rp 1.500.000" or "1500000" -> 1500000
  static int parse(String text) {
    if (text.isEmpty) return 0;
    // Extract only digits
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return 0;
    return int.tryParse(digitsOnly) ?? 0;
  }
}

/// Real-time thousand separator input formatter for Indonesian Rupiah
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final NumberFormat _decimalFormatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final number = int.tryParse(digitsOnly) ?? 0;
    final formattedText = _decimalFormatter.format(number);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
