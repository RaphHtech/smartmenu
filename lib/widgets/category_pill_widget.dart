import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

// Widget helper pour les pills de catégories
class CategoryPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const CategoryPill({
    required this.label,
    required this.isActive,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color.fromRGBO(255, 255, 255, 0.9)
              : const Color.fromRGBO(255, 255, 255, 0.1),
          border: Border.all(
            color: isActive
                ? Colors.white
                : const Color.fromRGBO(255, 255, 255, 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15.2,
          ),
        ),
      ),
    );
  }
}
