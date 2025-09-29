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
}
