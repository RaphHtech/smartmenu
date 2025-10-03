import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('he')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'SmartMenu'**
  String get appTitle;

  /// Menu label
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Shopping cart label
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// Orders label
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// Total price label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Button to add item to cart
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// Button to submit order
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// Order confirmation message
  ///
  /// In en, this message translates to:
  /// **'Order Confirmed!'**
  String get orderConfirmed;

  /// Button to call waiter
  ///
  /// In en, this message translates to:
  /// **'Call Waiter'**
  String get callWaiter;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Empty cart message
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty!'**
  String get cartEmpty;

  /// Item added confirmation
  ///
  /// In en, this message translates to:
  /// **'{itemName} added to cart!'**
  String itemAddedToCart(String itemName);

  /// Order creation success
  ///
  /// In en, this message translates to:
  /// **'Order created!'**
  String get orderCreated;

  /// Restaurant notification confirmation
  ///
  /// In en, this message translates to:
  /// **'The restaurant has been notified.'**
  String get restaurantNotified;

  /// Order error message
  ///
  /// In en, this message translates to:
  /// **'Error placing order'**
  String get orderError;

  /// Table ID error
  ///
  /// In en, this message translates to:
  /// **'Table not identified'**
  String get tableNotIdentified;

  /// Waiter call confirmation
  ///
  /// In en, this message translates to:
  /// **'Waiter called!'**
  String get waiterCalled;

  /// Staff arrival message
  ///
  /// In en, this message translates to:
  /// **'A member of our team is coming.'**
  String get staffComing;

  /// Cooldown message
  ///
  /// In en, this message translates to:
  /// **'Please wait {seconds}s between calls'**
  String cooldownWait(String seconds);

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// Pizzas category
  ///
  /// In en, this message translates to:
  /// **'Pizzas'**
  String get categoryPizzas;

  /// Starters category
  ///
  /// In en, this message translates to:
  /// **'Starters'**
  String get categoryStarters;

  /// Pasta category
  ///
  /// In en, this message translates to:
  /// **'Pasta'**
  String get categoryPasta;

  /// Desserts category
  ///
  /// In en, this message translates to:
  /// **'Desserts'**
  String get categoryDesserts;

  /// Drinks category
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get categoryDrinks;

  /// Other category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// Footer branding
  ///
  /// In en, this message translates to:
  /// **'Powered by SmartMenu'**
  String get poweredBy;

  /// Order label
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// Order label with item count
  ///
  /// In en, this message translates to:
  /// **'Order ({count})'**
  String orderWithCount(int count);

  /// Items plural
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// Item singular
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get item;

  /// Finalize order action
  ///
  /// In en, this message translates to:
  /// **'Finalize my order'**
  String get finalizeOrder;

  /// Order review modal title
  ///
  /// In en, this message translates to:
  /// **'Order Review'**
  String get orderReview;

  /// Your order review header
  ///
  /// In en, this message translates to:
  /// **'Review your order'**
  String get yourOrderReview;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Items label (already have items/item, this is alternative)
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get articles;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get back;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get confirm;

  /// Accessibility announcement
  ///
  /// In en, this message translates to:
  /// **'Order confirmed'**
  String get orderConfirmedAnnouncement;

  /// Add button
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get add;

  /// Popular badge
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get badgePopular;

  /// New badge
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get badgeNew;

  /// Specialty badge
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get badgeSpecialty;

  /// Chef's choice badge
  ///
  /// In en, this message translates to:
  /// **'Chef\'s choice'**
  String get badgeChef;

  /// Seasonal badge
  ///
  /// In en, this message translates to:
  /// **'Seasonal'**
  String get badgeSeasonal;

  /// Signature dish badge
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get badgeSignature;

  /// Confirmation message for item removal
  ///
  /// In en, this message translates to:
  /// **'Remove this item?'**
  String get removeThisItem;

  /// Button to remove item from cart
  ///
  /// In en, this message translates to:
  /// **'REMOVE FROM CART'**
  String get removeFromCart;

  /// Update button
  ///
  /// In en, this message translates to:
  /// **'UPDATE'**
  String get update;

  /// Accessibility label
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get increaseQuantity;

  /// Accessibility label
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get decreaseQuantity;

  /// Tooltip increase
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// Tooltip decrease
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// Waiter button label
  ///
  /// In en, this message translates to:
  /// **'Waiter'**
  String get waiter;

  /// Badges guide title
  ///
  /// In en, this message translates to:
  /// **'Badges Guide'**
  String get badgesGuide;

  /// Popular badge description
  ///
  /// In en, this message translates to:
  /// **'Most ordered dishes'**
  String get badgeDescPopular;

  /// New badge description
  ///
  /// In en, this message translates to:
  /// **'New items on the menu'**
  String get badgeDescNew;

  /// Specialty badge description
  ///
  /// In en, this message translates to:
  /// **'House specialties'**
  String get badgeDescSpecialty;

  /// Chef badge description
  ///
  /// In en, this message translates to:
  /// **'Chef recommendations'**
  String get badgeDescChef;

  /// Seasonal badge description
  ///
  /// In en, this message translates to:
  /// **'Seasonal dishes'**
  String get badgeDescSeasonal;

  /// Understood button
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// Generic add action
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// Generic edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// Generic delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Generic cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Generic save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Generic open action
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get commonOpen;

  /// Generic close action
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get commonSearch;

  /// Loading state
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String commonError(String error);

  /// Application name in sidebar
  ///
  /// In en, this message translates to:
  /// **'SmartMenu'**
  String get adminShellAppName;

  /// Dashboard navigation item
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminShellNavDashboard;

  /// Menu navigation item
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get adminShellNavMenu;

  /// Orders navigation item
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get adminShellNavOrders;

  /// Media navigation item
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get adminShellNavMedia;

  /// Branding navigation item
  ///
  /// In en, this message translates to:
  /// **'Branding'**
  String get adminShellNavBranding;

  /// Restaurant info navigation item
  ///
  /// In en, this message translates to:
  /// **'Restaurant Info'**
  String get adminShellNavRestaurantInfo;

  /// Settings navigation item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get adminShellNavSettings;

  /// User role label in footer
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get adminShellUserRole;

  /// Default user name fallback
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get adminShellUserDefault;

  /// Logout menu item
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get adminShellLogout;

  /// Dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminDashboardTitle;

  /// Dishes metric label
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get adminDashboardMetricDishes;

  /// Categories metric label
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get adminDashboardMetricCategories;

  /// With image metric label
  ///
  /// In en, this message translates to:
  /// **'With image'**
  String get adminDashboardMetricWithImage;

  /// No image metric label
  ///
  /// In en, this message translates to:
  /// **'No image'**
  String get adminDashboardMetricNoImage;

  /// Signature dishes metric label
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get adminDashboardMetricSignature;

  /// Add dish button
  ///
  /// In en, this message translates to:
  /// **'Add a dish'**
  String get adminDashboardAddDish;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get adminDashboardQuickActions;

  /// Manage media action
  ///
  /// In en, this message translates to:
  /// **'Manage media'**
  String get adminDashboardManageMedia;

  /// Edit restaurant info action
  ///
  /// In en, this message translates to:
  /// **'Edit info'**
  String get adminDashboardEditInfo;

  /// Preview menu action
  ///
  /// In en, this message translates to:
  /// **'Preview menu'**
  String get adminDashboardPreviewMenu;

  /// Client menu preview description
  ///
  /// In en, this message translates to:
  /// **'View your menu as a client'**
  String get adminDashboardViewClientMenu;

  /// Alert for items without images
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items without image} one{{count} item without image} other{{count} items without image}}'**
  String adminDashboardItemsWithoutImage(int count);

  /// Fix button in alerts
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get adminDashboardFix;

  /// Default restaurant name fallback
  ///
  /// In en, this message translates to:
  /// **'My Restaurant'**
  String get adminDashboardMyRestaurant;

  /// Menu page title
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get adminMenuTitle;

  /// Manage categories action
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get adminMenuManageCategories;

  /// Reorder dishes action
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get adminMenuReorder;

  /// Reorder dishes popup menu item
  ///
  /// In en, this message translates to:
  /// **'Reorder dishes'**
  String get adminMenuReorderDishes;

  /// Category dropdown label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get adminMenuCategory;

  /// Sort by name option
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get adminMenuName;

  /// Sort by price option
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get adminMenuPrice;

  /// Featured filter
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get adminMenuFeatured;

  /// With badges filter
  ///
  /// In en, this message translates to:
  /// **'With badges'**
  String get adminMenuWithBadges;

  /// No image filter
  ///
  /// In en, this message translates to:
  /// **'No image'**
  String get adminMenuNoImage;

  /// All categories filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminMenuAll;

  /// New category dialog title
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get adminMenuNewCategory;

  /// Category name field label
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get adminMenuCategoryName;

  /// Category name field hint
  ///
  /// In en, this message translates to:
  /// **'E.g.: Desserts'**
  String get adminMenuCategoryExample;

  /// No category label for uncategorized dishes
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get adminMenuNoCategory;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No dishes in menu'**
  String get adminMenuNoDishes;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Add your first dish to get started'**
  String get adminMenuAddFirstDish;

  /// Delete confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get adminMenuConfirmDelete;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete \"{name}\"?'**
  String adminMenuConfirmDeleteMessage(String name);

  /// Delete success message
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" deleted successfully'**
  String adminMenuDeleteSuccess(String name);

  /// Delete error message
  ///
  /// In en, this message translates to:
  /// **'Error deleting: {error}'**
  String adminMenuDeleteError(String error);

  /// Category update success message
  ///
  /// In en, this message translates to:
  /// **'Category updated.'**
  String get adminMenuCategoryUpdated;

  /// Orders screen title
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get adminOrdersTitle;

  /// Status: order received
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get adminOrdersReceived;

  /// Status: order in preparation
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get adminOrdersPreparing;

  /// Status: order ready
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get adminOrdersReady;

  /// Status: order served
  ///
  /// In en, this message translates to:
  /// **'Served'**
  String get adminOrdersServed;

  /// Table number label
  ///
  /// In en, this message translates to:
  /// **'Table {number}'**
  String adminOrdersTable(String number);

  /// Number of items in order
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String adminOrdersItems(int count);

  /// Action: mark order as preparing
  ///
  /// In en, this message translates to:
  /// **'Start preparing'**
  String get adminOrdersMarkPreparing;

  /// Action: mark order as ready
  ///
  /// In en, this message translates to:
  /// **'Mark ready'**
  String get adminOrdersMarkReady;

  /// Action: mark order as served
  ///
  /// In en, this message translates to:
  /// **'Mark served'**
  String get adminOrdersMarkServed;

  /// Empty state for orders tab
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get adminOrdersNoOrders;

  /// Order total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get adminOrdersTotal;

  /// Server call notification
  ///
  /// In en, this message translates to:
  /// **'Server call from Table {table}'**
  String adminOrdersServerCall(String table);

  /// Action: acknowledge server call
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get adminOrdersAcknowledge;

  /// Action: resolve server call
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get adminOrdersResolve;

  /// Time indicator: just now
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get adminOrdersJustNow;

  /// Time indicator: minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min ago} other{{count} min ago}}'**
  String adminOrdersMinutesAgo(int count);

  /// Success message after status update
  ///
  /// In en, this message translates to:
  /// **'Order updated: {status}'**
  String adminOrdersStatusUpdated(String status);

  /// Server call notification body
  ///
  /// In en, this message translates to:
  /// **'{table} needs assistance'**
  String adminOrdersServerCallBody(String table);

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get adminSettingsTitle;

  /// Restaurant section header
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get adminSettingsRestaurant;

  /// Restaurant name label
  ///
  /// In en, this message translates to:
  /// **'Restaurant name'**
  String get adminSettingsRestaurantName;

  /// Loading state
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get adminSettingsLoading;

  /// Name field placeholder
  ///
  /// In en, this message translates to:
  /// **'E.g.: Pizza Mario'**
  String get adminSettingsNamePlaceholder;

  /// Validation: name required
  ///
  /// In en, this message translates to:
  /// **'Restaurant name is required'**
  String get adminSettingsNameRequired;

  /// Validation: name too short
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get adminSettingsNameTooShort;

  /// Validation: name too long
  ///
  /// In en, this message translates to:
  /// **'Name cannot exceed 50 characters'**
  String get adminSettingsNameTooLong;

  /// Success message after name update
  ///
  /// In en, this message translates to:
  /// **'Restaurant name updated successfully'**
  String get adminSettingsNameUpdated;

  /// Generic save error
  ///
  /// In en, this message translates to:
  /// **'Save error: {error}'**
  String adminSettingsSaveError(String error);

  /// Error loading restaurant name
  ///
  /// In en, this message translates to:
  /// **'Unable to load restaurant name'**
  String get adminSettingsLoadError;

  /// Detailed info section title
  ///
  /// In en, this message translates to:
  /// **'Detailed information'**
  String get adminSettingsDetailedInfo;

  /// Detailed info subtitle
  ///
  /// In en, this message translates to:
  /// **'Description, promo banner, currency'**
  String get adminSettingsDetailedInfoSubtitle;

  /// Manage categories button
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get adminSettingsManageCategories;

  /// Categories subtitle
  ///
  /// In en, this message translates to:
  /// **'Reorder, hide and rename'**
  String get adminSettingsCategoriesSubtitle;

  /// Integration section header
  ///
  /// In en, this message translates to:
  /// **'Integration'**
  String get adminSettingsIntegration;

  /// Restaurant code label
  ///
  /// In en, this message translates to:
  /// **'Restaurant code'**
  String get adminSettingsRestaurantCode;

  /// Public URL label
  ///
  /// In en, this message translates to:
  /// **'Public URL'**
  String get adminSettingsPublicUrl;

  /// Generate QR button
  ///
  /// In en, this message translates to:
  /// **'Generate QR'**
  String get adminSettingsGenerateQr;

  /// Copied notification
  ///
  /// In en, this message translates to:
  /// **'Copied: {value}'**
  String adminSettingsCopied(String value);

  /// Code generation success
  ///
  /// In en, this message translates to:
  /// **'Code generated: {code}'**
  String adminSettingsCodeGenerated(String code);

  /// QR generator dialog title
  ///
  /// In en, this message translates to:
  /// **'QR Code Generator'**
  String get adminSettingsQrGenerator;

  /// Configuration section
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get adminSettingsConfiguration;

  /// Custom message field label
  ///
  /// In en, this message translates to:
  /// **'Custom message (optional)'**
  String get adminSettingsCustomMessage;

  /// Custom message hint
  ///
  /// In en, this message translates to:
  /// **'E.g.: Welcome!'**
  String get adminSettingsCustomMessageHint;

  /// Custom message helper text
  ///
  /// In en, this message translates to:
  /// **'Displayed above QR code'**
  String get adminSettingsCustomMessageHelper;

  /// Download size label
  ///
  /// In en, this message translates to:
  /// **'Download size'**
  String get adminSettingsDownloadSize;

  /// Small size option
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get adminSettingsSizeSmall;

  /// Medium size option
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get adminSettingsSizeMedium;

  /// Large size option
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get adminSettingsSizeLarge;

  /// Config save success
  ///
  /// In en, this message translates to:
  /// **'Configuration saved'**
  String get adminSettingsConfigSaved;

  /// QR instruction text
  ///
  /// In en, this message translates to:
  /// **'Scan to access the menu'**
  String get adminSettingsScanToAccess;

  /// Download QR button
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get adminSettingsDownloadQr;

  /// A5 template button
  ///
  /// In en, this message translates to:
  /// **'A5 Template'**
  String get adminSettingsTemplateA5;

  /// QR download success
  ///
  /// In en, this message translates to:
  /// **'QR Code downloaded successfully!'**
  String get adminSettingsQrDownloaded;

  /// Template download success
  ///
  /// In en, this message translates to:
  /// **'A5 template downloaded!'**
  String get adminSettingsTemplateDownloaded;

  /// URL copy success
  ///
  /// In en, this message translates to:
  /// **'URL copied to clipboard'**
  String get adminSettingsUrlCopied;

  /// Share dialog title
  ///
  /// In en, this message translates to:
  /// **'Share your menu'**
  String get adminSettingsShareMenu;

  /// Share method label
  ///
  /// In en, this message translates to:
  /// **'Choose a method'**
  String get adminSettingsChooseMethod;

  /// Copy link button
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get adminSettingsCopyLink;

  /// Email share option
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminSettingsEmail;

  /// SMS share option
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get adminSettingsSms;

  /// WhatsApp share option
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get adminSettingsWhatsApp;

  /// Facebook share option
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get adminSettingsFacebook;

  /// URL copy success with icon
  ///
  /// In en, this message translates to:
  /// **'URL copied to clipboard'**
  String get adminSettingsUrlCopiedSuccess;

  /// Share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
