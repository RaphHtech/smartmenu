import 'package:flutter/material.dart';

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
    return ChoiceChip(
      selected: isActive,
      onSelected: (_) => onTap(),
      label: Text(label, maxLines: 1, overflow: TextOverflow.fade),
      shape: const StadiumBorder(),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.72),
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: isActive
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
          ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
