import 'package:flutter/widgets.dart';
import '../services/currency_service.dart';

class CurrencyScope extends InheritedWidget {
  final String code;

  const CurrencyScope({
    super.key,
    required this.code,
    required super.child,
  });

  static CurrencyScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CurrencyScope>()!;

  @override
  bool updateShouldNotify(covariant CurrencyScope old) => old.code != code;
}

// AJOUTER cette extension :
extension MoneyX on BuildContext {
  String money(num amount) =>
      CurrencyService.format(amount, CurrencyScope.of(this).code);
}
