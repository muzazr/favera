import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/formatters/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('format formats integer rupiah correctly', () {
      expect(CurrencyFormatter.format(1500000), contains('1.500.000'));
      expect(CurrencyFormatter.format(0), contains('0'));
    });

    test('formatNumber formats number string without symbol', () {
      expect(CurrencyFormatter.formatNumber(5500000), equals('5.500.000'));
    });

    test('parse parses formatted and unformatted strings correctly', () {
      expect(CurrencyFormatter.parse('Rp1.500.000'), equals(1500000));
      expect(CurrencyFormatter.parse('1500000'), equals(1500000));
      expect(CurrencyFormatter.parse(''), equals(0));
      expect(CurrencyFormatter.parse('abc'), equals(0));
    });
  });
}
