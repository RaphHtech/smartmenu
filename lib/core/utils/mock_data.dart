import '../../models/menu_item.dart';
import '../../models/restaurant.dart';

class MockData {
  // Restaurant Pizza Power
  static Restaurant get pizzaPowerRestaurant {
    return Restaurant(
      id: 'pizza_power_tlv',
      name: 'PIZZA POWER',
      description: 'La vraie pizza italienne à Tel Aviv',
      address: 'Dizengoff 45, Tel Aviv',
      phone: '03-1234567',
      theme: 'pizza',
      openingHours: ['Dim-Jeu 11h-23h', 'Ven 11h-15h', 'Sam fermé'],
      isOpen: true,
      supportedLanguages: ['fr', 'en', 'he'],
      defaultLanguage: 'fr',
      nameTranslations: {
        'en': 'PIZZA POWER',
        'he': 'פיצה פאוור',
        'fr': 'PIZZA POWER',
      },
      descriptionTranslations: {
        'en': 'Authentic Italian pizza in Tel Aviv',
        'he': 'פיצה איטלקית אמיתית בתל אביב',
        'fr': 'La vraie pizza italienne à Tel Aviv',
      },
      settings: RestaurantSettings(
        categories: ['pizzas', 'entrees', 'pates', 'desserts', 'boissons'],
        categoryTranslations: {
          'pizzas_fr': '🍕 Pizzas',
          'pizzas_en': '🍕 Pizzas',
          'pizzas_he': '🍕 פיצות',
          'entrees_fr': '🥗 Entrées',
          'entrees_en': '🥗 Starters',
          'entrees_he': '🥗 מנות ראשונות',
          'pates_fr': '🍝 Pâtes',
          'pates_en': '🍝 Pasta',
          'pates_he': '🍝 פסטה',
          'desserts_fr': '🍰 Desserts',
          'desserts_en': '🍰 Desserts',
          'desserts_he': '🍰 קינוחים',
          'boissons_fr': '🍹 Boissons',
          'boissons_en': '🍹 Drinks',
          'boissons_he': '🍹 משקאות',
        },
      ),
    );
  }

  // Menu items Pizza Power
  static List<MenuItem> get menuItems {
    return [
      // PIZZAS
      MenuItem(
        id: 'margherita_royale',
        name: 'Margherita Royale',
        description:
            'Mozzarella di bufala, tomates San Marzano, basilic frais, huile d\'olive extra vierge, sur notre pâte artisanale 48h',
        price: 65,
        category: 'pizzas',
        emoji: '🍕',
        isSignature: true,
        nameTranslations: {
          'en': 'Margherita Royale',
          'he': 'מרגריטה רויאל',
          'fr': 'Margherita Royale',
        },
        descriptionTranslations: {
          'en':
              'Buffalo mozzarella, San Marzano tomatoes, fresh basil, extra virgin olive oil, on our 48h artisanal dough',
          'he':
              'מוצרלה באפלה, עגבניות סן מרצאנו, בזיליקום טרי, שמן זית בתולי מעולה, על בצק מסורתי של 48 שעות',
          'fr':
              'Mozzarella di bufala, tomates San Marzano, basilic frais, huile d\'olive extra vierge, sur notre pâte artisanale 48h',
        },
      ),

      MenuItem(
        id: 'diavola_infernale',
        name: 'Diavola Infernale',
        description:
            'Sauce tomate épicée, mozzarella, salami piquant, piments jalapeños, oignons rouges, huile pimentée maison',
        price: 72,
        category: 'pizzas',
        emoji: '🍕',
        isSignature: true,
        nameTranslations: {
          'en': 'Diavola Infernale',
          'he': 'דיאבולה אינפרנלה',
          'fr': 'Diavola Infernale',
        },
        descriptionTranslations: {
          'en':
              'Spicy tomato sauce, mozzarella, spicy salami, jalapeño peppers, red onions, homemade chili oil',
          'he':
              'רוטב עגבניות חריף, מוצרלה, סלמי חריף, פלפלי חלפיניו, בצל אדום, שמן חריף ביתי',
          'fr':
              'Sauce tomate épicée, mozzarella, salami piquant, piments jalapeños, oignons rouges, huile pimentée maison',
        },
      ),

      MenuItem(
        id: 'quatre_fromages',
        name: 'Quatre Fromages',
        description:
            'Mozzarella, gorgonzola DOP, parmesan 24 mois, ricotta fraîche, miel de truffe, noix',
        price: 78,
        category: 'pizzas',
        emoji: '🍕',
        nameTranslations: {
          'en': 'Four Cheeses',
          'he': 'ארבע גבינות',
          'fr': 'Quatre Fromages',
        },
        descriptionTranslations: {
          'en':
              'Mozzarella, DOP gorgonzola, 24-month parmesan, fresh ricotta, truffle honey, walnuts',
          'he':
              'מוצרלה, גורגונזולה DOP, פרמזן 24 חודשים, ריקוטה טרייה, דבש כמהין, אגוזים',
          'fr':
              'Mozzarella, gorgonzola DOP, parmesan 24 mois, ricotta fraîche, miel de truffe, noix',
        },
      ),

      MenuItem(
        id: 'jambon_champignons',
        name: 'Jambon Champignons',
        description:
            'Prosciutto di Parma 18 mois, champignons porcini, mozzarella, roquette, copeaux de parmesan',
        price: 82,
        category: 'pizzas',
        emoji: '🍕',
        nameTranslations: {
          'en': 'Ham Mushrooms',
          'he': 'חזיר פטריות',
          'fr': 'Jambon Champignons',
        },
        descriptionTranslations: {
          'en':
              '18-month Prosciutto di Parma, porcini mushrooms, mozzarella, arugula, parmesan shavings',
          'he':
              'פרושוטו די פארמה 18 חודשים, פטריות פורצ\'יני, מוצרלה, רוקט, שבבי פרמזן',
          'fr':
              'Prosciutto di Parma 18 mois, champignons porcini, mozzarella, roquette, copeaux de parmesan',
        },
      ),

      MenuItem(
        id: 'vegetarienne_supreme',
        name: 'Végétarienne Suprême',
        description:
            'Aubergines grillées, courgettes, poivrons rouges, champignons, olives Kalamata, mozzarella, basilic',
        price: 68,
        category: 'pizzas',
        emoji: '🍕',
        nameTranslations: {
          'en': 'Supreme Vegetarian',
          'he': 'צמחונית סופרים',
          'fr': 'Végétarienne Suprême',
        },
        descriptionTranslations: {
          'en':
              'Grilled eggplant, zucchini, red peppers, mushrooms, Kalamata olives, mozzarella, basil',
          'he':
              'חצילים צלויים, קישואים, פלפלים אדומים, פטריות, זיתי קלמטה, מוצרלה, בזיליקום',
          'fr':
              'Aubergines grillées, courgettes, poivrons rouges, champignons, olives Kalamata, mozzarella, basilic',
        },
      ),

      MenuItem(
        id: 'fruits_de_mer',
        name: 'Fruits de Mer',
        description:
            'Crevettes, calamars, moules, tomates cerises, ail, persil, huile d\'olive, sans fromage',
        price: 85,
        category: 'pizzas',
        emoji: '🍕',
        nameTranslations: {
          'en': 'Seafood',
          'he': 'פירות ים',
          'fr': 'Fruits de Mer',
        },
        descriptionTranslations: {
          'en':
              'Shrimp, squid, mussels, cherry tomatoes, garlic, parsley, olive oil, no cheese',
          'he':
              'שרימפס, דיונון, צדפות, עגבניות שרי, שום, פטרוזיליה, שמן זית, ללא גבינה',
          'fr':
              'Crevettes, calamars, moules, tomates cerises, ail, persil, huile d\'olive, sans fromage',
        },
      ),

      // ENTRÉES
      MenuItem(
        id: 'antipasti_misto',
        name: 'Antipasti Misto',
        description:
            'Sélection de charcuteries italiennes, fromages vieillis, olives marinées, légumes grillés',
        price: 55,
        category: 'entrees',
        emoji: '🥗',
        nameTranslations: {
          'en': 'Mixed Antipasti',
          'he': 'אנטיפסטי מעורב',
          'fr': 'Antipasti Misto',
        },
        descriptionTranslations: {
          'en':
              'Selection of Italian charcuterie, aged cheeses, marinated olives, grilled vegetables',
          'he':
              'מבחר נקניקים איטלקיים, גבינות מיושנות, זיתים מרווחים, ירקות צלויים',
          'fr':
              'Sélection de charcuteries italiennes, fromages vieillis, olives marinées, légumes grillés',
        },
      ),

      // PÂTES
      MenuItem(
        id: 'carbonara_classique',
        name: 'Carbonara Classique',
        description:
            'Spaghetti, guanciale, œufs fermiers, pecorino romano, poivre noir fraîchement moulu',
        price: 62,
        category: 'pates',
        emoji: '🍝',
        nameTranslations: {
          'en': 'Classic Carbonara',
          'he': 'קרבונרה קלאסית',
          'fr': 'Carbonara Classique',
        },
        descriptionTranslations: {
          'en':
              'Spaghetti, guanciale, farm eggs, pecorino romano, freshly ground black pepper',
          'he':
              'ספגטי, גואנצ\'יאלה, ביצי חווה, פקורינו רומנו, פלפל שחור טחון טרי',
          'fr':
              'Spaghetti, guanciale, œufs fermiers, pecorino romano, poivre noir fraîchement moulu',
        },
      ),

      // DESSERTS
      MenuItem(
        id: 'tiramisu_maison',
        name: 'Tiramisu Maison',
        description:
            'Mascarpone, café expresso, cacao pur, biscuits savoiardi, rhum arrangé',
        price: 32,
        category: 'desserts',
        emoji: '🍰',
        nameTranslations: {
          'en': 'Homemade Tiramisu',
          'he': 'טירמיסו ביתי',
          'fr': 'Tiramisu Maison',
        },
        descriptionTranslations: {
          'en':
              'Mascarpone, espresso coffee, pure cocoa, savoiardi biscuits, spiced rum',
          'he': 'מסקרפונה, קפה אספרסו, קקאו טהור, ביסקוטי סבוארדי, רום מתובל',
          'fr':
              'Mascarpone, café expresso, cacao pur, biscuits savoiardi, rhum arrangé',
        },
      ),

      // BOISSONS
      MenuItem(
        id: 'chianti_classico',
        name: 'Chianti Classico',
        description:
            'Vin rouge toscan, bouteille 750ml, notes de cerise et épices',
        price: 120,
        category: 'boissons',
        emoji: '🍷',
        nameTranslations: {
          'en': 'Chianti Classico',
          'he': 'קיאנטי קלאסיקו',
          'fr': 'Chianti Classico',
        },
        descriptionTranslations: {
          'en': 'Tuscan red wine, 750ml bottle, cherry and spice notes',
          'he': 'יין אדום טוסקני, בקבוק 750 מ"ל, נימי דובדבן ותבלינים',
          'fr': 'Vin rouge toscan, bouteille 750ml, notes de cerise et épices',
        },
      ),
    ];
  }

  // Obtenir les items par catégorie
  static List<MenuItem> getItemsByCategory(String category) {
    return menuItems.where((item) => item.category == category).toList();
  }

  // Obtenir les catégories disponibles
  static List<String> get categories {
    return menuItems.map((item) => item.category).toSet().toList();
  }
}
