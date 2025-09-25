import 'package:intl/intl.dart';

class CurrencyConfig {
  final String code;
  final String symbol;
  final String locale;

  const CurrencyConfig({
    required this.code,
    required this.symbol,
    required this.locale,
  });
}

class CurrencyService {
  static const _configs = {
    'ILS': CurrencyConfig(code: 'ILS', symbol: '₪', locale: 'he_IL'),
    'EUR': CurrencyConfig(code: 'EUR', symbol: '€', locale: 'fr_FR'),
    'USD': CurrencyConfig(code: 'USD', symbol: '\$', locale: 'en_US'),
  };

  static CurrencyConfig getConfig(String? currencyCode) {
    return _configs[currencyCode?.toUpperCase()] ?? _configs['ILS']!;
  }

  static String format(num amount, String? currencyCode, {int? decimals}) {
    final config = getConfig(currencyCode);
    final formatter = NumberFormat.currency(
      locale: config.locale,
      symbol: config.symbol,
      decimalDigits: decimals ?? (amount % 1 == 0 ? 0 : 2),
    );
    return formatter.format(amount);
  }
}
