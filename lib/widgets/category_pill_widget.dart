import 'package:flutter/material.dart';
import 'package:smartmenu_app/core/design/client_tokens.dart';

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
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface.withOpacity(0.72),
          borderRadius: BorderRadius.circular(100),
          border: isActive
              ? Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
              ),
        ),
      ),
    );
  }
}
