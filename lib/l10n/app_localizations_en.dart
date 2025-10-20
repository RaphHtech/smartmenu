// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SmartMenu';

  @override
  String get menu => 'Menu';

  @override
  String get cart => 'Cart';

  @override
  String get orders => 'Orders';

  @override
  String get total => 'Total';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get orderConfirmed => 'Order Confirmed!';

  @override
  String get callWaiter => 'Call Waiter';

  @override
  String get loading => 'Loading...';

  @override
  String get cartEmpty => 'Your cart is empty!';

  @override
  String itemAddedToCart(String itemName) {
    return '$itemName added to cart!';
  }

  @override
  String get orderCreated => 'Order created!';

  @override
  String get restaurantNotified => 'The restaurant has been notified.';

  @override
  String get orderError => 'Error placing order';

  @override
  String get tableNotIdentified => 'Table not identified';

  @override
  String get waiterCalled => 'Waiter called!';

  @override
  String get staffComing => 'A member of our team is coming.';

  @override
  String cooldownWait(String seconds) {
    return 'Please wait ${seconds}s between calls';
  }

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get categoryPizzas => 'Pizzas';

  @override
  String get categoryStarters => 'Starters';

  @override
  String get categoryPasta => 'Pasta';

  @override
  String get categoryDesserts => 'Desserts';

  @override
  String get categoryDrinks => 'Drinks';

  @override
  String get categoryOther => 'Other';

  @override
  String get poweredBy => 'Powered by SmartMenu';

  @override
  String get order => 'Order';

  @override
  String orderWithCount(int count) {
    return 'Order ($count)';
  }

  @override
  String get items => 'items';

  @override
  String get item => 'item';

  @override
  String get finalizeOrder => 'Finalize my order';

  @override
  String get orderReview => 'Order Review';

  @override
  String get yourOrderReview => 'Review your order';

  @override
  String get close => 'Close';

  @override
  String get articles => 'items';

  @override
  String get back => 'BACK';

  @override
  String get confirm => 'CONFIRM';

  @override
  String get orderConfirmedAnnouncement => 'Order confirmed';

  @override
  String get add => 'ADD';

  @override
  String get badgePopular => 'Popular';

  @override
  String get badgeNew => 'New';

  @override
  String get badgeSpecialty => 'Specialty';

  @override
  String get badgeChef => 'Chef\'s choice';

  @override
  String get badgeSeasonal => 'Seasonal';

  @override
  String get badgeSignature => 'Signature';

  @override
  String get removeThisItem => 'Remove this item?';

  @override
  String get removeFromCart => 'REMOVE FROM CART';

  @override
  String get update => 'UPDATE';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get increase => 'Increase';

  @override
  String get decrease => 'Decrease';

  @override
  String get waiter => 'Waiter';

  @override
  String get badgesGuide => 'Badges Guide';

  @override
  String get badgeDescPopular => 'Most ordered dishes';

  @override
  String get badgeDescNew => 'New items on the menu';

  @override
  String get badgeDescSpecialty => 'House specialties';

  @override
  String get badgeDescChef => 'Chef recommendations';

  @override
  String get badgeDescSeasonal => 'Seasonal dishes';

  @override
  String get understood => 'Understood';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonOpen => 'Open';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSearch => 'Search...';

  @override
  String get commonLoading => 'Loading...';

  @override
  String commonError(String error) {
    return 'Error: $error';
  }

  @override
  String get adminShellAppName => 'SmartMenu';

  @override
  String get adminShellNavDashboard => 'Dashboard';

  @override
  String get adminShellNavMenu => 'Menu';

  @override
  String get adminShellNavOrders => 'Orders';

  @override
  String get adminShellNavMedia => 'Media';

  @override
  String get adminShellNavBranding => 'Branding';

  @override
  String get adminShellNavRestaurantInfo => 'Restaurant Info';

  @override
  String get adminShellNavSettings => 'Settings';

  @override
  String get adminShellUserRole => 'Owner';

  @override
  String get adminShellUserDefault => 'User';

  @override
  String get adminShellLogout => 'Log out';

  @override
  String get adminDashboardTitle => 'Dashboard';

  @override
  String get adminDashboardMetricDishes => 'Dishes';

  @override
  String get adminDashboardMetricCategories => 'Categories';

  @override
  String get adminDashboardMetricWithImage => 'With image';

  @override
  String get adminDashboardMetricNoImage => 'No image';

  @override
  String get adminDashboardMetricSignature => 'Signature';

  @override
  String get adminDashboardAddDish => 'Add a dish';

  @override
  String get adminDashboardQuickActions => 'Quick actions';

  @override
  String get adminDashboardManageMedia => 'Manage media';

  @override
  String get adminDashboardEditInfo => 'Edit info';

  @override
  String get adminDashboardPreviewMenu => 'Preview menu';

  @override
  String get adminDashboardViewClientMenu => 'View your menu as a client';

  @override
  String adminDashboardItemsWithoutImage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items without image',
      one: '$count item without image',
      zero: 'No items without image',
    );
    return '$_temp0';
  }

  @override
  String get adminDashboardFix => 'Fix';

  @override
  String get adminDashboardMyRestaurant => 'My Restaurant';

  @override
  String get adminMenuTitle => 'Menu';

  @override
  String get adminMenuManageCategories => 'Manage categories';

  @override
  String get adminMenuReorder => 'Reorder';

  @override
  String get adminMenuReorderDishes => 'Reorder dishes';

  @override
  String get adminMenuCategory => 'Category';

  @override
  String get adminMenuName => 'Name';

  @override
  String get adminMenuPrice => 'Price';

  @override
  String get adminMenuFeatured => 'Featured';

  @override
  String get adminMenuWithBadges => 'With badges';

  @override
  String get adminMenuNoImage => 'No image';

  @override
  String get adminMenuAll => 'All';

  @override
  String get adminMenuNewCategory => 'New category';

  @override
  String get adminMenuCategoryName => 'Category name';

  @override
  String get adminMenuCategoryExample => 'E.g.: Desserts';

  @override
  String get adminMenuNoCategory => 'No category';

  @override
  String get adminMenuNoDishes => 'No dishes in menu';

  @override
  String get adminMenuAddFirstDish => 'Add your first dish to get started';

  @override
  String get adminMenuConfirmDelete => 'Confirm deletion';

  @override
  String adminMenuConfirmDeleteMessage(String name) {
    return 'Do you really want to delete \"$name\"?';
  }

  @override
  String adminMenuDeleteSuccess(String name) {
    return '\"$name\" deleted successfully';
  }

  @override
  String adminMenuDeleteError(String error) {
    return 'Error deleting: $error';
  }

  @override
  String get adminMenuCategoryUpdated => 'Category updated.';

  @override
  String get adminOrdersTitle => 'Orders';

  @override
  String get adminOrdersReceived => 'Received';

  @override
  String get adminOrdersPreparing => 'Preparing';

  @override
  String get adminOrdersReady => 'Ready';

  @override
  String get adminOrdersServed => 'Served';

  @override
  String adminOrdersTable(String number) {
    return 'Table $number';
  }

  @override
  String adminOrdersItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get adminOrdersMarkPreparing => 'Start preparing';

  @override
  String get adminOrdersMarkReady => 'Mark ready';

  @override
  String get adminOrdersMarkServed => 'Mark served';

  @override
  String get adminOrdersNoOrders => 'No orders';

  @override
  String get adminOrdersTotal => 'Total';

  @override
  String adminOrdersServerCall(String table) {
    return 'Server call from Table $table';
  }

  @override
  String get adminOrdersAcknowledge => 'Acknowledge';

  @override
  String get adminOrdersResolve => 'Resolve';

  @override
  String get adminOrdersJustNow => 'Just now';

  @override
  String adminOrdersMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String adminOrdersStatusUpdated(String status) {
    return 'Order updated: $status';
  }

  @override
  String adminOrdersServerCallBody(String table) {
    return '$table needs assistance';
  }

  @override
  String get adminSettingsTitle => 'Settings';

  @override
  String get adminSettingsRestaurant => 'Restaurant';

  @override
  String get adminSettingsRestaurantName => 'Restaurant name';

  @override
  String get adminSettingsLoading => 'Loading...';

  @override
  String get adminSettingsNamePlaceholder => 'E.g.: Pizza Mario';

  @override
  String get adminSettingsNameRequired => 'Restaurant name is required';

  @override
  String get adminSettingsNameTooShort => 'Name must be at least 2 characters';

  @override
  String get adminSettingsNameTooLong => 'Name cannot exceed 50 characters';

  @override
  String get adminSettingsNameUpdated => 'Restaurant name updated successfully';

  @override
  String adminSettingsSaveError(String error) {
    return 'Save error: $error';
  }

  @override
  String get adminSettingsLoadError => 'Unable to load restaurant name';

  @override
  String get adminSettingsDetailedInfo => 'Detailed information';

  @override
  String get adminSettingsDetailedInfoSubtitle =>
      'Description, promo banner, currency';

  @override
  String get adminSettingsManageCategories => 'Manage categories';

  @override
  String get adminSettingsCategoriesSubtitle => 'Reorder, hide and rename';

  @override
  String get adminSettingsIntegration => 'Integration';

  @override
  String get adminSettingsRestaurantCode => 'Restaurant code';

  @override
  String get adminSettingsPublicUrl => 'Public URL';

  @override
  String get adminSettingsGenerateQr => 'Generate QR';

  @override
  String adminSettingsCopied(String value) {
    return 'Copied: $value';
  }

  @override
  String adminSettingsCodeGenerated(String code) {
    return 'Code generated: $code';
  }

  @override
  String get adminSettingsQrGenerator => 'QR Code Generator';

  @override
  String get adminSettingsConfiguration => 'Configuration';

  @override
  String get adminSettingsCustomMessage => 'Custom message (optional)';

  @override
  String get adminSettingsCustomMessageHint => 'E.g.: Welcome!';

  @override
  String get adminSettingsCustomMessageHelper => 'Displayed above QR code';

  @override
  String get adminSettingsDownloadSize => 'Download size';

  @override
  String get adminSettingsSizeSmall => 'Small';

  @override
  String get adminSettingsSizeMedium => 'Medium';

  @override
  String get adminSettingsSizeLarge => 'Large';

  @override
  String get adminSettingsConfigSaved => 'Configuration saved';

  @override
  String get adminSettingsScanToAccess => 'Scan to access the menu';

  @override
  String get adminSettingsDownloadQr => 'Download';

  @override
  String get adminSettingsTemplateA5 => 'A5 Template';

  @override
  String get adminSettingsQrDownloaded => 'QR Code downloaded successfully!';

  @override
  String get adminSettingsTemplateDownloaded => 'A5 template downloaded!';

  @override
  String get adminSettingsUrlCopied => 'URL copied to clipboard';

  @override
  String get adminSettingsShareMenu => 'Share your menu';

  @override
  String get adminSettingsChooseMethod => 'Choose a method';

  @override
  String get adminSettingsCopyLink => 'Copy link';

  @override
  String get adminSettingsEmail => 'Email';

  @override
  String get adminSettingsSms => 'SMS';

  @override
  String get adminSettingsWhatsApp => 'WhatsApp';

  @override
  String get adminSettingsFacebook => 'Facebook';

  @override
  String get adminSettingsUrlCopiedSuccess => 'URL copied to clipboard';

  @override
  String get commonShare => 'Share';

  @override
  String get commonLanguage => 'Language';

  @override
  String get adminRestaurantInfoTitle => 'Restaurant Info';

  @override
  String get adminRestaurantInfoTaglineSection => 'Subtitle text (tagline)';

  @override
  String get adminRestaurantInfoTaglinePlaceholder =>
      'E.g. Authentic Italian pizza in Tel Aviv';

  @override
  String get adminRestaurantInfoTaglineMaxLength => '120 characters max';

  @override
  String get adminRestaurantInfoPromoToggleTitle => 'Show promo banner';

  @override
  String get adminRestaurantInfoPromoToggleSubtitle =>
      'Uncheck to hide the banner on the site';

  @override
  String get adminRestaurantInfoPromoSection => 'Promotional banner (optional)';

  @override
  String get adminRestaurantInfoPromoPlaceholder =>
      'E.g. ✨ 2nd pizza -50% • Free delivery from 80₪ ✨';

  @override
  String get adminRestaurantInfoPromoMaxLength => '140 characters max';

  @override
  String adminRestaurantInfoLoadError(String error) {
    return 'Unable to load info: $error';
  }

  @override
  String get adminRestaurantInfoSaveSuccess => 'Info saved ✅';

  @override
  String adminRestaurantInfoSaveError(String error) {
    return 'Save error: $error';
  }

  @override
  String get adminMediaTitle => 'Media';

  @override
  String get adminMediaAddButton => 'Add';

  @override
  String get adminMediaDropZoneClick => 'click to select';

  @override
  String get adminMediaDropZoneFormats => 'PNG, JPG, WebP - Max 5MB';

  @override
  String get adminMediaErrorFormat =>
      'Unsupported format. Use PNG, JPG or WebP.';

  @override
  String get adminMediaErrorSize => 'File too large (max 5MB).';

  @override
  String adminMediaErrorLoad(String error) {
    return 'Error loading media: $error';
  }

  @override
  String adminMediaErrorUpload(String error) {
    return 'Upload error: $error';
  }

  @override
  String get adminMediaSuccessUpload => 'Image uploaded successfully!';

  @override
  String get adminMediaSuccessDelete => 'Media deleted successfully';

  @override
  String get adminMediaSuccessAssign => 'Image assigned successfully';

  @override
  String get adminMediaUploadProgress => 'Upload in progress...';

  @override
  String get adminMediaDeleteTitle => 'Delete media';

  @override
  String adminMediaDeleteConfirm(String name) {
    return 'Do you really want to delete \"$name\"?';
  }

  @override
  String get adminMediaDeleteButton => 'Delete';

  @override
  String get adminMediaAssignTitle => 'Assign to a dish';

  @override
  String get adminMediaAssignSearch => 'Search for a dish…';

  @override
  String get adminMediaAssignNoDishes => 'No dishes available';

  @override
  String get adminMediaEmptyTitle => 'No media';

  @override
  String get adminMediaEmptySubtitle => 'Add your first images to get started';

  @override
  String get adminMediaAssignButton => 'Assign';

  @override
  String get adminBrandingTitle => 'Branding';

  @override
  String get adminBrandingIdentity => 'Brand identity';

  @override
  String get adminBrandingLogoSection => 'Restaurant logo';

  @override
  String get adminBrandingLogoFormat =>
      'Recommended format: Square PNG, transparent background, minimum 256×256px';

  @override
  String get adminBrandingLogoFormats =>
      'Recommended PNG (transparent background), JPG accepted';

  @override
  String get adminBrandingUploadClick => 'Click to upload a logo';

  @override
  String get adminBrandingErrorSize => 'File must be less than 2MB';

  @override
  String get adminBrandingErrorFormat => 'Please select an image (PNG/JPG)';

  @override
  String adminBrandingErrorSelection(String error) {
    return 'Error during selection: $error';
  }

  @override
  String adminBrandingErrorLoad(String error) {
    return 'Loading error: $error';
  }

  @override
  String get adminBrandingSuccessUpload => 'Logo uploaded successfully';

  @override
  String get adminBrandingSuccessDelete => 'Logo deleted successfully';

  @override
  String get adminBrandingPreviewTitle => 'Preview render';

  @override
  String get adminBrandingPreviewDescription =>
      'Visualize how your logo will appear in the client interface';

  @override
  String get adminBrandingPreviewHero => 'Main header';

  @override
  String get adminBrandingPreviewSticky => 'Sticky header (collapsed)';

  @override
  String get adminBrandingRestaurantDefault => 'Restaurant';

  @override
  String get badgesGuideSubtitle =>
      'These badges help highlight special dishes';

  @override
  String get adminReorderTitle => 'Reorganize Menu';

  @override
  String get adminReorderBreadcrumbReorganize => 'Reorganize';

  @override
  String get adminReorderSaving => 'Saving...';

  @override
  String get adminReorderSaved => 'Saved';

  @override
  String adminReorderSavedAgo(String time) {
    return 'Saved • $time ago';
  }

  @override
  String get adminReorderError => 'Error';

  @override
  String get adminReorderUnsaved => 'Unsaved';

  @override
  String get adminReorderPreview => 'Preview';

  @override
  String get adminReorderBulkActions => 'Bulk actions';

  @override
  String adminReorderMoveItems(int count) {
    return 'Move ($count)';
  }

  @override
  String adminReorderHideItems(int count) {
    return 'Hide ($count)';
  }

  @override
  String adminReorderShowItems(int count) {
    return 'Show ($count)';
  }

  @override
  String get adminReorderCancelSelection => 'Cancel selection';

  @override
  String get adminReorderCategories => 'Categories';

  @override
  String adminReorderDishCount(int count, String category) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dishes',
      one: '1 dish',
      zero: '0 dishes',
    );
    return '$_temp0 • $category';
  }

  @override
  String get adminReorderSelect => 'Select';

  @override
  String get adminReorderNoDishes => 'No dishes in this category';

  @override
  String get adminReorderSignatureBadge => 'Signature';

  @override
  String adminReorderMoveDialogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dishes',
      one: '1 dish',
    );
    return 'Move $_temp0';
  }

  @override
  String adminReorderLoadError(String error) {
    return 'Loading error: $error';
  }

  @override
  String adminReorderPreviewError(String error) {
    return 'Cannot open preview: $error';
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
  String get adminDishFormTitleEdit => 'Edit Dish';

  @override
  String get adminDishFormTitleAdd => 'Add Dish';

  @override
  String get adminDishFormName => 'Dish name *';

  @override
  String get adminDishFormDescription => 'Description';

  @override
  String get adminDishFormPrice => 'Price *';

  @override
  String get adminDishFormCategory => 'Category';

  @override
  String get adminDishFormNameRequired => 'Name in Hebrew is required';

  @override
  String get adminDishFormPriceRequired => 'Price required';

  @override
  String get adminDishFormPriceInvalid => 'Invalid price';

  @override
  String get adminDishFormCopyFromFrench => 'Copy from French';

  @override
  String get adminDishFormCopyFromHebrew => 'Copy from Hebrew';

  @override
  String get adminDishFormCopyFromEnglish => 'Copy from English';

  @override
  String adminDishFormCopiedFrom(String language) {
    return 'Content copied from $language';
  }

  @override
  String get adminDishFormOptions => 'Options';

  @override
  String get adminDishFormFeatured => 'Feature';

  @override
  String get adminDishFormFeaturedSubtitle => 'Pin to top of category';

  @override
  String get adminDishFormBadges => 'Badges';

  @override
  String get adminDishFormBadgePopular => 'popular';

  @override
  String get adminDishFormBadgeNew => 'new';

  @override
  String get adminDishFormBadgeSpecialty => 'specialty';

  @override
  String get adminDishFormBadgeChef => 'chef';

  @override
  String get adminDishFormBadgeSeasonal => 'seasonal';

  @override
  String get adminDishFormVisible => 'Visible on menu';

  @override
  String get adminDishFormVisibleSubtitle => 'Customers can see this dish';

  @override
  String get adminDishFormAddPhoto => 'Add photo';

  @override
  String get adminDishFormClickToSelect => 'Click to select';

  @override
  String get adminDishFormAddButton => 'Add';

  @override
  String get adminDishFormChangeButton => 'Change';

  @override
  String get adminDishFormRemoveButton => 'Remove';

  @override
  String get adminDishFormRemovePhoto => 'Remove photo';

  @override
  String get adminDishFormCannotSelectPhoto => 'Cannot select photo';

  @override
  String adminDishFormSaveSuccess(String action) {
    return 'Dish $action successfully';
  }

  @override
  String get adminDishFormActionModified => 'modified';

  @override
  String get adminDishFormActionAdded => 'added';

  @override
  String adminDishFormSaveError(String error) {
    return 'Error: $error';
  }

  @override
  String get adminDishFormButtonSave => 'Save';

  @override
  String get adminDishFormButtonAdd => 'Add';

  @override
  String get adminDishFormLanguageHebrew => '🇮🇱 עברית';

  @override
  String get adminDishFormLanguageEnglish => '🇬🇧 English';

  @override
  String get adminDishFormLanguageFrench => '🇫🇷 Français';

  @override
  String get adminCategoryManagerTitle => 'Manage Categories';

  @override
  String get adminCategoryManagerSubtitle => 'Reorganize and configure';

  @override
  String get adminCategoryManagerSubtitleFull =>
      'Reorganize and configure your categories';

  @override
  String get adminCategoryManagerNew => 'New';

  @override
  String get adminCategoryManagerUnsaved => 'Unsaved changes';

  @override
  String get adminCategoryManagerSaving => 'Saving...';

  @override
  String get adminCategoryManagerSaved => 'Saved';

  @override
  String adminCategoryManagerSavedAgo(String time) {
    return 'Saved • $time ago';
  }

  @override
  String get adminCategoryManagerError => 'Failed. Retry';

  @override
  String get adminCategoryManagerHiddenBadge => 'Hidden';

  @override
  String get adminCategoryManagerShowAction => 'Show';

  @override
  String get adminCategoryManagerHideAction => 'Hide';

  @override
  String adminCategoryManagerShowSemantic(String category) {
    return 'Show $category';
  }

  @override
  String adminCategoryManagerHideSemantic(String category) {
    return 'Hide $category';
  }

  @override
  String get adminCategoryManagerRenameAction => 'Rename';

  @override
  String adminCategoryManagerRenameSemantic(String category) {
    return 'Rename $category';
  }

  @override
  String get adminCategoryManagerDeleteAction => 'Delete';

  @override
  String adminCategoryManagerDeleteSemantic(String category) {
    return 'Delete $category';
  }

  @override
  String get adminCategoryManagerDragHint => 'Drag and drop to reorganize';

  @override
  String adminCategoryManagerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categories',
      one: '1 category',
    );
    return '$_temp0';
  }

  @override
  String get adminCategoryManagerDeleteTitle => 'Delete category?';

  @override
  String adminCategoryManagerDeleteMessage(String category) {
    return '\"$category\" will be removed from the list.';
  }

  @override
  String get adminCategoryManagerRenameTitle => 'Rename category';

  @override
  String adminCategoryManagerRenameMessage(
      String oldName, String newName, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dishes',
      one: '1 dish',
    );
    return 'Rename \"$oldName\" to \"$newName\" — $_temp0 will be updated.';
  }

  @override
  String adminCategoryManagerRenameProgress(int percent) {
    return 'Updating... $percent%';
  }

  @override
  String get adminCategoryManagerConfirm => 'Confirm';

  @override
  String adminCategoryManagerSaveError(String error) {
    return 'Save error: $error';
  }

  @override
  String get adminCategoryManagerRetry => 'Retry';

  @override
  String get adminCategoryManagerDefaultName => 'New category';

  @override
  String get adminSignupTitle => 'Create your space';

  @override
  String get adminSignupSubtitle => 'Start managing your restaurant in minutes';

  @override
  String get adminSignupEmailLabel => 'Professional email';

  @override
  String get adminSignupEmailPlaceholder => 'restaurant@example.com';

  @override
  String get adminSignupPasswordLabel => 'Password';

  @override
  String get adminSignupPasswordPlaceholder => '••••••••';

  @override
  String get adminSignupButton => 'Create my account';

  @override
  String get adminSignupAlreadyHaveAccount => 'Already have an account?';

  @override
  String get adminSignupLoginLink => 'Sign in';

  @override
  String get adminSignupEmailRequired => 'Please enter your email';

  @override
  String get adminSignupPasswordHint => '8+ characters recommended';

  @override
  String get adminSignupPasswordRequired => 'Please enter a password';

  @override
  String get adminSignupPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String get adminSignupConfirmPasswordLabel => 'Confirm password';

  @override
  String get adminSignupConfirmPasswordRequired =>
      'Please confirm your password';

  @override
  String get adminSignupPasswordMismatch => 'Passwords do not match';

  @override
  String get adminSignupButtonLoading => 'Creating account...';

  @override
  String get adminSignupErrorGeneric =>
      'Unable to create account. Check your information.';

  @override
  String get adminSignupErrorUnknown => 'An error occurred. Please try again.';

  @override
  String get adminSettingsDefaultLanguage => 'Default menu language';

  @override
  String get adminSettingsDefaultLanguageSubtitle =>
      'Language shown to clients by default';

  @override
  String get adminSettingsDefaultLanguageUpdated => 'Default language updated';

  @override
  String get adminSettingsMenuFeatures => 'Menu features';

  @override
  String get adminSettingsEnableOrders => 'Enable orders';

  @override
  String get adminSettingsEnableOrdersSubtitle =>
      'Allow customers to place orders';

  @override
  String get adminSettingsOrdersUpdated => 'Orders setting updated';

  @override
  String get adminSettingsEnableServerCall => 'Enable server call';

  @override
  String get adminSettingsEnableServerCallSubtitle =>
      'Show server call button to customers';

  @override
  String get adminSettingsServerCallUpdated => 'Server call setting updated';

  @override
  String get cartVisualOnly =>
      'Show this cart to the waiter to place your order';

  @override
  String get viewOrder => 'View order';
}
