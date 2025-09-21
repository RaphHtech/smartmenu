import 'package:flutter/material.dart';

class BadgesLegendWidget extends StatelessWidget {
  const BadgesLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Guide des badges',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          ..._buildLegendItems(),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Compris'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLegendItems() {
    final items = [
      {
        'badge': 'populaire',
        'title': 'Populaire',
        'desc': 'Les plats les plus commandés',
        'color': const Color(0xFFFF8C00),
        'icon': Icons.star
      },
      {
        'badge': 'nouveau',
        'title': 'Nouveau',
        'desc': 'Nouveautés de la carte',
        'color': const Color(0xFF4F46E5),
        'icon': Icons.fiber_new
      },
      {
        'badge': 'spécialité',
        'title': 'Spécialité',
        'desc': 'Spécialités de la maison',
        'color': const Color(0xFF7C3AED),
        'icon': Icons.restaurant
      },
      {
        'badge': 'chef',
        'title': 'Choix du chef',
        'desc': 'Recommandations du chef',
        'color': const Color(0xFF0891B2),
        'icon': Icons.person
      },
      {
        'badge': 'saisonnier',
        'title': 'Saisonnier',
        'desc': 'Plats de saison',
        'color': const Color(0xFF059669),
        'icon': Icons.eco
      },
    ];

    return items
        .map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item['icon'] as IconData,
                            size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['desc'] as String,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }
}
