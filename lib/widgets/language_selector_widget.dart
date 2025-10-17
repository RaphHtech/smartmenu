import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/language_provider.dart';
import '../services/language_service.dart';

class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLocale = languageProvider.locale;

    return PopupMenuButton<Locale>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LanguageService.getFlag(currentLocale.languageCode),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return LanguageService.supportedLocales.map((Locale locale) {
          final isSelected = locale == currentLocale;
          return PopupMenuItem<Locale>(
            value: locale,
            child: Row(
              children: [
                Text(
                  LanguageService.getFlag(locale.languageCode),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  LanguageService.getNativeName(locale.languageCode),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Theme.of(context).primaryColor : null,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(
                    Icons.check,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ],
              ],
            ),
          );
        }).toList();
      },
      onSelected: (Locale locale) {
        languageProvider.setLocale(locale);
      },
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
