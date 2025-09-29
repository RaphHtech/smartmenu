// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SmartMenu';

  @override
  String get menu => 'Menu';

  @override
  String get cart => 'Panier';

  @override
  String get orders => 'Commandes';

  @override
  String get total => 'Total';

  @override
  String get addToCart => 'Ajouter au panier';

  @override
  String get placeOrder => 'Passer commande';

  @override
  String get orderConfirmed => 'Commande confirmée !';

  @override
  String get callWaiter => 'Appeler le serveur';

  @override
  String get loading => 'Chargement...';

  @override
  String get cartEmpty => 'Votre panier est vide !';

  @override
  String itemAddedToCart(String itemName) {
    return '$itemName ajouté au panier !';
  }

  @override
  String get orderCreated => 'Commande créée !';

  @override
  String get restaurantNotified => 'Le restaurant a été notifié.';

  @override
  String get orderError => 'Erreur lors de la commande';

  @override
  String get tableNotIdentified => 'Table non identifiée';

  @override
  String get waiterCalled => 'Serveur appelé !';

  @override
  String get staffComing => 'Un membre de notre équipe arrive.';

  @override
  String cooldownWait(String seconds) {
    return 'Veuillez attendre ${seconds}s entre les appels';
  }

  @override
  String error(String error) {
    return 'Erreur : $error';
  }

  @override
  String get categoryPizzas => 'Pizzas';

  @override
  String get categoryStarters => 'Entrées';

  @override
  String get categoryPasta => 'Pâtes';

  @override
  String get categoryDesserts => 'Desserts';

  @override
  String get categoryDrinks => 'Boissons';

  @override
  String get categoryOther => 'Autres';

  @override
  String get poweredBy => 'Propulsé par SmartMenu';

  @override
  String get order => 'Commande';

  @override
  String orderWithCount(int count) {
    return 'Commande ($count)';
  }

  @override
  String get items => 'articles';

  @override
  String get item => 'article';

  @override
  String get finalizeOrder => 'Finaliser ma commande';

  @override
  String get orderReview => 'Révision de commande';

  @override
  String get yourOrderReview => 'Révision de votre commande';

  @override
  String get close => 'Fermer';

  @override
  String get articles => 'articles';

  @override
  String get back => 'RETOUR';

  @override
  String get confirm => 'CONFIRMER';

  @override
  String get orderConfirmedAnnouncement => 'Commande confirmée';

  @override
  String get add => 'AJOUTER';

  @override
  String get badgePopular => 'Populaire';

  @override
  String get badgeNew => 'Nouveau';

  @override
  String get badgeSpecialty => 'Spécialité';

  @override
  String get badgeChef => 'Choix du chef';

  @override
  String get badgeSeasonal => 'Saisonnier';

  @override
  String get badgeSignature => 'Signature';

  @override
  String get removeThisItem => 'Retirer cet article ?';

  @override
  String get removeFromCart => 'SUPPRIMER DU PANIER';

  @override
  String get update => 'METTRE À JOUR';

  @override
  String get increaseQuantity => 'Augmenter la quantité';

  @override
  String get decreaseQuantity => 'Diminuer la quantité';

  @override
  String get increase => 'Augmenter';

  @override
  String get decrease => 'Diminuer';

  @override
  String get waiter => 'Serveur';

  @override
  String get badgesGuide => 'Guide des badges';

  @override
  String get badgeDescPopular => 'Les plats les plus commandés';

  @override
  String get badgeDescNew => 'Nouveautés de la carte';

  @override
  String get badgeDescSpecialty => 'Spécialités de la maison';

  @override
  String get badgeDescChef => 'Recommandations du chef';

  @override
  String get badgeDescSeasonal => 'Plats de saison';

  @override
  String get understood => 'Compris';
}
