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

  @override
  String get commonLanguage => 'Langue';

  @override
  String get adminRestaurantInfoTitle => 'Infos du restaurant';

  @override
  String get adminRestaurantInfoTaglineSection =>
      'Texte sous le titre (tagline)';

  @override
  String get adminRestaurantInfoTaglinePlaceholder =>
      'Ex. La vraie pizza italienne à Tel Aviv';

  @override
  String get adminRestaurantInfoTaglineMaxLength => '120 caractères max';

  @override
  String get adminRestaurantInfoPromoToggleTitle => 'Afficher le bandeau promo';

  @override
  String get adminRestaurantInfoPromoToggleSubtitle =>
      'Décoche pour masquer la bannière sur le site';

  @override
  String get adminRestaurantInfoPromoSection =>
      'Bandeau promotionnel (optionnel)';

  @override
  String get adminRestaurantInfoPromoPlaceholder =>
      'Ex. ✨ 2ème pizza -50% • Livraison offerte dès 80₪ ✨';

  @override
  String get adminRestaurantInfoPromoMaxLength => '140 caractères max';

  @override
  String adminRestaurantInfoLoadError(String error) {
    return 'Impossible de charger les infos : $error';
  }

  @override
  String get adminRestaurantInfoSaveSuccess => 'Infos enregistrées ✅';

  @override
  String adminRestaurantInfoSaveError(String error) {
    return 'Erreur enregistrement : $error';
  }

  @override
  String get adminMediaTitle => 'Médias';

  @override
  String get adminMediaAddButton => 'Ajouter';

  @override
  String get adminMediaDropZoneClick => 'cliquez pour sélectionner';

  @override
  String get adminMediaDropZoneFormats => 'PNG, JPG, WebP - Max 5MB';

  @override
  String get adminMediaErrorFormat =>
      'Format non supporté. Utilisez PNG, JPG ou WebP.';

  @override
  String get adminMediaErrorSize => 'Fichier trop volumineux (max 5MB).';

  @override
  String adminMediaErrorLoad(String error) {
    return 'Erreur chargement médias : $error';
  }

  @override
  String adminMediaErrorUpload(String error) {
    return 'Erreur upload : $error';
  }

  @override
  String get adminMediaSuccessUpload => 'Image uploadée avec succès !';

  @override
  String get adminMediaSuccessDelete => 'Média supprimé avec succès';

  @override
  String get adminMediaSuccessAssign => 'Image assignée avec succès';

  @override
  String get adminMediaUploadProgress => 'Upload en cours...';

  @override
  String get adminMediaDeleteTitle => 'Supprimer le média';

  @override
  String adminMediaDeleteConfirm(String name) {
    return 'Voulez-vous vraiment supprimer \"$name\" ?';
  }

  @override
  String get adminMediaDeleteButton => 'Supprimer';

  @override
  String get adminMediaAssignTitle => 'Assigner à un plat';

  @override
  String get adminMediaAssignSearch => 'Rechercher un plat…';

  @override
  String get adminMediaAssignNoDishes => 'Aucun plat disponible';

  @override
  String get adminMediaEmptyTitle => 'Aucun média';

  @override
  String get adminMediaEmptySubtitle =>
      'Ajoutez vos premières images pour commencer';

  @override
  String get adminMediaAssignButton => 'Assigner';

  @override
  String get adminBrandingTitle => 'Branding';

  @override
  String get adminBrandingIdentity => 'Identité de marque';

  @override
  String get adminBrandingLogoSection => 'Logo du restaurant';

  @override
  String get adminBrandingLogoFormat =>
      'Format recommandé : PNG carré, fond transparent, minimum 256×256px';

  @override
  String get adminBrandingLogoFormats =>
      'PNG recommandé (fond transparent), JPG accepté';

  @override
  String get adminBrandingUploadClick => 'Cliquez pour téléverser un logo';

  @override
  String get adminBrandingErrorSize => 'Le fichier doit faire moins de 2MB';

  @override
  String get adminBrandingErrorFormat =>
      'Veuillez sélectionner une image (PNG/JPG)';

  @override
  String adminBrandingErrorSelection(String error) {
    return 'Erreur lors de la sélection : $error';
  }

  @override
  String adminBrandingErrorLoad(String error) {
    return 'Erreur de chargement : $error';
  }

  @override
  String get adminBrandingSuccessUpload => 'Logo téléversé avec succès';

  @override
  String get adminBrandingSuccessDelete => 'Logo supprimé avec succès';

  @override
  String get adminBrandingPreviewTitle => 'Aperçu rendu';

  @override
  String get adminBrandingPreviewDescription =>
      'Visualisez comment votre logo apparaîtra dans l\'interface client';

  @override
  String get adminBrandingPreviewHero => 'Header principal';

  @override
  String get adminBrandingPreviewSticky => 'Header rétracté (sticky)';

  @override
  String get adminBrandingRestaurantDefault => 'Restaurant';

  @override
  String get badgesGuideSubtitle =>
      'Ces badges permettent de mettre en avant des plats spéciaux';

  @override
  String get adminReorderTitle => 'Réorganiser le menu';

  @override
  String get adminReorderBreadcrumbReorganize => 'Réorganiser';

  @override
  String get adminReorderSaving => 'Enregistrement...';

  @override
  String get adminReorderSaved => 'Enregistré';

  @override
  String adminReorderSavedAgo(String time) {
    return 'Enregistré • il y a $time';
  }

  @override
  String get adminReorderError => 'Erreur';

  @override
  String get adminReorderUnsaved => 'Non enregistré';

  @override
  String get adminReorderPreview => 'Prévisualiser';

  @override
  String get adminReorderBulkActions => 'Actions groupées';

  @override
  String adminReorderMoveItems(int count) {
    return 'Déplacer ($count)';
  }

  @override
  String adminReorderHideItems(int count) {
    return 'Masquer ($count)';
  }

  @override
  String adminReorderShowItems(int count) {
    return 'Afficher ($count)';
  }

  @override
  String get adminReorderCancelSelection => 'Annuler sélection';

  @override
  String get adminReorderCategories => 'Catégories';

  @override
  String adminReorderDishCount(int count, String category) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plats',
      one: '1 plat',
      zero: '0 plat',
    );
    return '$_temp0 • $category';
  }

  @override
  String get adminReorderSelect => 'Sélectionner';

  @override
  String get adminReorderNoDishes => 'Aucun plat dans cette catégorie';

  @override
  String get adminReorderSignatureBadge => 'Signature';

  @override
  String adminReorderMoveDialogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plats',
      one: '1 plat',
    );
    return 'Déplacer $_temp0';
  }

  @override
  String adminReorderLoadError(String error) {
    return 'Erreur de chargement : $error';
  }

  @override
  String adminReorderPreviewError(String error) {
    return 'Impossible d\'ouvrir l\'aperçu : $error';
  }

  @override
  String adminReorderTimeSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String adminReorderTimeMinutes(int minutes) {
    return '${minutes}min';
  }

  @override
  String get adminDishFormTitleEdit => 'Modifier le plat';

  @override
  String get adminDishFormTitleAdd => 'Ajouter un plat';

  @override
  String get adminDishFormName => 'Nom du plat *';

  @override
  String get adminDishFormDescription => 'Description';

  @override
  String get adminDishFormPrice => 'Prix *';

  @override
  String get adminDishFormCategory => 'Catégorie';

  @override
  String get adminDishFormNameRequired => 'Le nom en hébreu est obligatoire';

  @override
  String get adminDishFormPriceRequired => 'Prix obligatoire';

  @override
  String get adminDishFormPriceInvalid => 'Prix invalide';

  @override
  String get adminDishFormCopyFromFrench => 'Copier depuis français';

  @override
  String get adminDishFormCopyFromHebrew => 'Copier depuis hébreu';

  @override
  String get adminDishFormCopyFromEnglish => 'Copier depuis anglais';

  @override
  String adminDishFormCopiedFrom(String language) {
    return 'Contenu copié depuis $language';
  }

  @override
  String get adminDishFormOptions => 'Options';

  @override
  String get adminDishFormFeatured => 'Mettre en avant';

  @override
  String get adminDishFormFeaturedSubtitle =>
      'Épingler en haut de la catégorie';

  @override
  String get adminDishFormBadges => 'Badges';

  @override
  String get adminDishFormBadgePopular => 'populaire';

  @override
  String get adminDishFormBadgeNew => 'nouveau';

  @override
  String get adminDishFormBadgeSpecialty => 'spécialité';

  @override
  String get adminDishFormBadgeChef => 'chef';

  @override
  String get adminDishFormBadgeSeasonal => 'saisonnier';

  @override
  String get adminDishFormVisible => 'Visible sur le menu';

  @override
  String get adminDishFormVisibleSubtitle => 'Les clients peuvent voir ce plat';

  @override
  String get adminDishFormAddPhoto => 'Ajouter une photo';

  @override
  String get adminDishFormClickToSelect => 'Cliquez pour sélectionner';

  @override
  String get adminDishFormAddButton => 'Ajouter';

  @override
  String get adminDishFormChangeButton => 'Changer';

  @override
  String get adminDishFormRemoveButton => 'Retirer';

  @override
  String get adminDishFormRemovePhoto => 'Retirer la photo';

  @override
  String get adminDishFormCannotSelectPhoto =>
      'Impossible de sélectionner la photo';

  @override
  String adminDishFormSaveSuccess(String action) {
    return 'Plat $action avec succès';
  }

  @override
  String get adminDishFormActionModified => 'modifié';

  @override
  String get adminDishFormActionAdded => 'ajouté';

  @override
  String adminDishFormSaveError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get adminDishFormButtonSave => 'Enregistrer';

  @override
  String get adminDishFormButtonAdd => 'Ajouter';

  @override
  String get adminDishFormLanguageHebrew => '🇮🇱 עברית';

  @override
  String get adminDishFormLanguageEnglish => '🇬🇧 English';

  @override
  String get adminDishFormLanguageFrench => '🇫🇷 Français';

  @override
  String get adminCategoryManagerTitle => 'Gérer les catégories';

  @override
  String get adminCategoryManagerSubtitle => 'Réorganisez et configurez';

  @override
  String get adminCategoryManagerSubtitleFull =>
      'Réorganisez et configurez vos catégories';

  @override
  String get adminCategoryManagerNew => 'Nouvelle';

  @override
  String get adminCategoryManagerUnsaved => 'Modifications non enregistrées';

  @override
  String get adminCategoryManagerSaving => 'Sauvegarde...';

  @override
  String get adminCategoryManagerSaved => 'Enregistré';

  @override
  String adminCategoryManagerSavedAgo(String time) {
    return 'Enregistré • il y a $time';
  }

  @override
  String get adminCategoryManagerError => 'Échec. Réessayer';

  @override
  String get adminCategoryManagerHiddenBadge => 'Masquée';

  @override
  String get adminCategoryManagerShowAction => 'Afficher';

  @override
  String get adminCategoryManagerHideAction => 'Masquer';

  @override
  String adminCategoryManagerShowSemantic(String category) {
    return 'Afficher $category';
  }

  @override
  String adminCategoryManagerHideSemantic(String category) {
    return 'Masquer $category';
  }

  @override
  String get adminCategoryManagerRenameAction => 'Renommer';

  @override
  String adminCategoryManagerRenameSemantic(String category) {
    return 'Renommer $category';
  }

  @override
  String get adminCategoryManagerDeleteAction => 'Supprimer';

  @override
  String adminCategoryManagerDeleteSemantic(String category) {
    return 'Supprimer $category';
  }

  @override
  String get adminCategoryManagerDragHint => 'Glissez-déposez pour réorganiser';

  @override
  String adminCategoryManagerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count catégories',
      one: '1 catégorie',
    );
    return '$_temp0';
  }

  @override
  String get adminCategoryManagerDeleteTitle => 'Supprimer la catégorie ?';

  @override
  String adminCategoryManagerDeleteMessage(String category) {
    return '« $category » sera retirée de la liste.';
  }

  @override
  String get adminCategoryManagerRenameTitle => 'Renommer la catégorie';

  @override
  String adminCategoryManagerRenameMessage(
      String oldName, String newName, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plats',
      one: '1 plat',
    );
    return 'Renommer « $oldName » en « $newName » — $_temp0 seront mis à jour.';
  }

  @override
  String adminCategoryManagerRenameProgress(int percent) {
    return 'Mise à jour en cours... $percent%';
  }

  @override
  String get adminCategoryManagerConfirm => 'Confirmer';

  @override
  String adminCategoryManagerSaveError(String error) {
    return 'Erreur de sauvegarde : $error';
  }

  @override
  String get adminCategoryManagerRetry => 'Réessayer';

  @override
  String get adminCategoryManagerDefaultName => 'Nouvelle catégorie';

  @override
  String get adminSignupTitle => 'Créer votre espace';

  @override
  String get adminSignupSubtitle =>
      'Commencez à gérer votre restaurant en quelques minutes';

  @override
  String get adminSignupEmailLabel => 'Email professionnel';

  @override
  String get adminSignupEmailPlaceholder => 'restaurant@exemple.com';

  @override
  String get adminSignupPasswordLabel => 'Mot de passe';

  @override
  String get adminSignupPasswordPlaceholder => '••••••••';

  @override
  String get adminSignupButton => 'Créer mon espace';

  @override
  String get adminSignupAlreadyHaveAccount => 'Déjà un compte ?';

  @override
  String get adminSignupLoginLink => 'Se connecter';

  @override
  String get adminSignupEmailRequired => 'Veuillez saisir votre email';

  @override
  String get adminSignupPasswordHint => '8+ caractères recommandés';

  @override
  String get adminSignupPasswordRequired => 'Veuillez saisir un mot de passe';

  @override
  String get adminSignupPasswordTooShort =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get adminSignupConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get adminSignupConfirmPasswordRequired =>
      'Veuillez confirmer votre mot de passe';

  @override
  String get adminSignupPasswordMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get adminSignupButtonLoading => 'Création en cours...';

  @override
  String get adminSignupErrorGeneric =>
      'Impossible de créer le compte. Vérifiez vos informations.';

  @override
  String get adminSignupErrorUnknown =>
      'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get adminSettingsDefaultLanguage => 'Langue par défaut du menu';

  @override
  String get adminSettingsDefaultLanguageSubtitle =>
      'Langue affichée aux clients par défaut';

  @override
  String get adminSettingsDefaultLanguageUpdated =>
      'Langue par défaut mise à jour';

  @override
  String get adminSettingsMenuFeatures => 'Fonctionnalités du menu';

  @override
  String get adminSettingsEnableOrders => 'Activer les commandes';

  @override
  String get adminSettingsEnableOrdersSubtitle =>
      'Permettre aux clients de passer des commandes';

  @override
  String get adminSettingsOrdersUpdated => 'Paramètre des commandes mis à jour';

  @override
  String get adminSettingsEnableServerCall => 'Activer l\'appel serveur';

  @override
  String get adminSettingsEnableServerCallSubtitle =>
      'Afficher le bouton d\'appel serveur aux clients';

  @override
  String get adminSettingsServerCallUpdated =>
      'Paramètre d\'appel serveur mis à jour';

  @override
  String get cartVisualOnly =>
      'Montrez ce panier au serveur pour passer commande';

  @override
  String get viewOrder => 'Voir commande';
}
