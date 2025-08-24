import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/restaurant.dart';
import '../providers/language_provider.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final LanguageProvider languageProvider;
  final Restaurant restaurant;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.languageProvider,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          final localizedName = restaurant.settings.getLocalizedCategory(
            category,
            languageProvider.currentLanguageCode,
          );

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: () => onCategorySelected(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromRGBO(255, 255, 255, 0.9)
                        : const Color.fromRGBO(255, 255, 255, 0.1),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : const Color.fromRGBO(255, 255, 255, 0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isSelected ? [AppColors.primaryShadow] : [],
                  ),
                  child: Center(
                    child: Text(
                      localizedName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
