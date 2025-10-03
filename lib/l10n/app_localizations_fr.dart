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

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonOpen => 'Ouvrir';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonSearch => 'Rechercher...';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String commonError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get adminShellAppName => 'SmartMenu';

  @override
  String get adminShellNavDashboard => 'Tableau de bord';

  @override
  String get adminShellNavMenu => 'Menu';

  @override
  String get adminShellNavOrders => 'Commandes';

  @override
  String get adminShellNavMedia => 'Médias';

  @override
  String get adminShellNavBranding => 'Branding';

  @override
  String get adminShellNavRestaurantInfo => 'Infos resto';

  @override
  String get adminShellNavSettings => 'Paramètres';

  @override
  String get adminShellUserRole => 'Propriétaire';

  @override
  String get adminShellUserDefault => 'Utilisateur';

  @override
  String get adminShellLogout => 'Se déconnecter';

  @override
  String get adminDashboardTitle => 'Tableau de bord';

  @override
  String get adminDashboardMetricDishes => 'Plats';

  @override
  String get adminDashboardMetricCategories => 'Catégories';

  @override
  String get adminDashboardMetricWithImage => 'Avec image';

  @override
  String get adminDashboardMetricNoImage => 'Sans image';

  @override
  String get adminDashboardMetricSignature => 'Signature';

  @override
  String get adminDashboardAddDish => 'Ajouter un plat';

  @override
  String get adminDashboardQuickActions => 'Actions rapides';

  @override
  String get adminDashboardManageMedia => 'Gérer les médias';

  @override
  String get adminDashboardEditInfo => 'Modifier les infos';

  @override
  String get adminDashboardPreviewMenu => 'Prévisualiser le menu';

  @override
  String get adminDashboardViewClientMenu => 'Voir votre menu côté client';

  @override
  String adminDashboardItemsWithoutImage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments sans image',
      one: '$count élément sans image',
      zero: 'Aucun élément sans image',
    );
    return '$_temp0';
  }

  @override
  String get adminDashboardFix => 'Corriger';

  @override
  String get adminDashboardMyRestaurant => 'Mon Restaurant';

  @override
  String get adminMenuTitle => 'Menu';

  @override
  String get adminMenuManageCategories => 'Gérer catégories';

  @override
  String get adminMenuReorder => 'Réorganiser';

  @override
  String get adminMenuReorderDishes => 'Réorganiser plats';

  @override
  String get adminMenuCategory => 'Catégorie';

  @override
  String get adminMenuName => 'Nom';

  @override
  String get adminMenuPrice => 'Prix';

  @override
  String get adminMenuFeatured => 'Mis en avant';

  @override
  String get adminMenuWithBadges => 'Avec badges';

  @override
  String get adminMenuNoImage => 'Sans image';

  @override
  String get adminMenuAll => 'Toutes';

  @override
  String get adminMenuNewCategory => 'Nouvelle catégorie';

  @override
  String get adminMenuCategoryName => 'Nom de la catégorie';

  @override
  String get adminMenuCategoryExample => 'Ex : Desserts';

  @override
  String get adminMenuNoCategory => 'Sans catégorie';

  @override
  String get adminMenuNoDishes => 'Aucun plat au menu';

  @override
  String get adminMenuAddFirstDish =>
      'Ajoutez votre premier plat pour commencer';

  @override
  String get adminMenuConfirmDelete => 'Confirmer la suppression';

  @override
  String adminMenuConfirmDeleteMessage(String name) {
    return 'Voulez-vous vraiment supprimer \"$name\" ?';
  }

  @override
  String adminMenuDeleteSuccess(String name) {
    return '\"$name\" supprimé avec succès';
  }

  @override
  String adminMenuDeleteError(String error) {
    return 'Erreur lors de la suppression : $error';
  }

  @override
  String get adminMenuCategoryUpdated => 'Catégorie mise à jour.';

  @override
  String get adminOrdersTitle => 'Commandes';

  @override
  String get adminOrdersReceived => 'Reçue';

  @override
  String get adminOrdersPreparing => 'Préparation';

  @override
  String get adminOrdersReady => 'Prête';

  @override
  String get adminOrdersServed => 'Servie';

  @override
  String adminOrdersTable(String number) {
    return 'Table $number';
  }

  @override
  String adminOrdersItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String get adminOrdersMarkPreparing => 'Commencer préparation';

  @override
  String get adminOrdersMarkReady => 'Marquer prête';

  @override
  String get adminOrdersMarkServed => 'Marquer servie';

  @override
  String get adminOrdersNoOrders => 'Aucune commande';

  @override
  String get adminOrdersTotal => 'Total';

  @override
  String adminOrdersServerCall(String table) {
    return 'Appel de la table $table';
  }

  @override
  String get adminOrdersAcknowledge => 'Accuser réception';

  @override
  String get adminOrdersResolve => 'Résoudre';

  @override
  String get adminOrdersJustNow => 'À l\'instant';

  @override
  String adminOrdersMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count min',
      one: 'Il y a 1 min',
    );
    return '$_temp0';
  }

  @override
  String adminOrdersStatusUpdated(String status) {
    return 'Commande mise à jour : $status';
  }

  @override
  String adminOrdersServerCallBody(String table) {
    return '$table demande de l\'assistance';
  }

  @override
  String get adminSettingsTitle => 'Paramètres';

  @override
  String get adminSettingsRestaurant => 'Restaurant';

  @override
  String get adminSettingsRestaurantName => 'Nom du restaurant';

  @override
  String get adminSettingsLoading => 'Chargement...';

  @override
  String get adminSettingsNamePlaceholder => 'Ex : Pizza Mario';

  @override
  String get adminSettingsNameRequired =>
      'Le nom du restaurant est obligatoire';

  @override
  String get adminSettingsNameTooShort =>
      'Le nom doit contenir au moins 2 caractères';

  @override
  String get adminSettingsNameTooLong =>
      'Le nom ne peut pas dépasser 50 caractères';

  @override
  String get adminSettingsNameUpdated =>
      'Nom du restaurant mis à jour avec succès';

  @override
  String adminSettingsSaveError(String error) {
    return 'Erreur lors de la sauvegarde : $error';
  }

  @override
  String get adminSettingsLoadError =>
      'Impossible de charger le nom du restaurant';

  @override
  String get adminSettingsDetailedInfo => 'Informations détaillées';

  @override
  String get adminSettingsDetailedInfoSubtitle =>
      'Description, bandeau promo, devise';

  @override
  String get adminSettingsManageCategories => 'Gérer les catégories';

  @override
  String get adminSettingsCategoriesSubtitle =>
      'Réorganiser, masquer et renommer';

  @override
  String get adminSettingsIntegration => 'Intégration';

  @override
  String get adminSettingsRestaurantCode => 'Code restaurant';

  @override
  String get adminSettingsPublicUrl => 'URL publique';

  @override
  String get adminSettingsGenerateQr => 'Générer QR';

  @override
  String adminSettingsCopied(String value) {
    return 'Copié : $value';
  }

  @override
  String adminSettingsCodeGenerated(String code) {
    return 'Code généré : $code';
  }

  @override
  String get adminSettingsQrGenerator => 'Générateur QR Code';

  @override
  String get adminSettingsConfiguration => 'Configuration';

  @override
  String get adminSettingsCustomMessage => 'Message personnalisé (optionnel)';

  @override
  String get adminSettingsCustomMessageHint => 'Ex : Bienvenue chez nous !';

  @override
  String get adminSettingsCustomMessageHelper => 'Affiché au-dessus du QR code';

  @override
  String get adminSettingsDownloadSize => 'Taille de téléchargement';

  @override
  String get adminSettingsSizeSmall => 'Petit';

  @override
  String get adminSettingsSizeMedium => 'Moyen';

  @override
  String get adminSettingsSizeLarge => 'Grand';

  @override
  String get adminSettingsConfigSaved => 'Configuration sauvegardée';

  @override
  String get adminSettingsScanToAccess => 'Scannez pour accéder au menu';

  @override
  String get adminSettingsDownloadQr => 'Télécharger';

  @override
  String get adminSettingsTemplateA5 => 'Template A5';

  @override
  String get adminSettingsQrDownloaded => 'QR Code téléchargé avec succès !';

  @override
  String get adminSettingsTemplateDownloaded => 'Template A5 téléchargé !';

  @override
  String get adminSettingsUrlCopied => 'URL copiée dans le presse-papier';

  @override
  String get adminSettingsShareMenu => 'Partager votre menu';

  @override
  String get adminSettingsChooseMethod => 'Choisir une méthode';

  @override
  String get adminSettingsCopyLink => 'Copier le lien';

  @override
  String get adminSettingsEmail => 'Email';

  @override
  String get adminSettingsSms => 'SMS';

  @override
  String get adminSettingsWhatsApp => 'WhatsApp';

  @override
  String get adminSettingsFacebook => 'Facebook';

  @override
  String get adminSettingsUrlCopiedSuccess =>
      'URL copiée dans le presse-papier';

  @override
  String get commonShare => 'Partager';
}
