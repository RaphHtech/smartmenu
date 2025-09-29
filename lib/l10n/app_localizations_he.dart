// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'סמארט-מניו';

  @override
  String get menu => 'תפריט';

  @override
  String get cart => 'סל';

  @override
  String get orders => 'הזמנות';

  @override
  String get total => 'סה״כ';

  @override
  String get addToCart => 'הוסף לסל';

  @override
  String get placeOrder => 'בצע הזמנה';

  @override
  String get orderConfirmed => 'ההזמנה אושרה!';

  @override
  String get callWaiter => 'קרא למלצר';

  @override
  String get loading => 'טוען...';

  @override
  String get cartEmpty => 'הסל שלך ריק!';

  @override
  String itemAddedToCart(String itemName) {
    return '$itemName נוסף לסל!';
  }

  @override
  String get orderCreated => 'ההזמנה נוצרה!';

  @override
  String get restaurantNotified => 'המסעדה קיבלה התראה.';

  @override
  String get orderError => 'שגיאה ביצירת ההזמנה';

  @override
  String get tableNotIdentified => 'השולחן לא זוהה';

  @override
  String get waiterCalled => 'המלצר נקרא!';

  @override
  String get staffComing => 'חבר צוות בדרך אליך.';

  @override
  String cooldownWait(String seconds) {
    return 'נא להמתין $seconds שניות בין קריאות';
  }

  @override
  String error(String error) {
    return 'שגיאה: $error';
  }

  @override
  String get categoryPizzas => 'פיצות';

  @override
  String get categoryStarters => 'מנות ראשונות';

  @override
  String get categoryPasta => 'פסטה';

  @override
  String get categoryDesserts => 'קינוחים';

  @override
  String get categoryDrinks => 'משקאות';

  @override
  String get categoryOther => 'אחר';

  @override
  String get poweredBy => 'מופעל על ידי SmartMenu';

  @override
  String get order => 'הזמנה';

  @override
  String orderWithCount(int count) {
    return 'הזמנה ($count)';
  }

  @override
  String get items => 'פריטים';

  @override
  String get item => 'פריט';

  @override
  String get finalizeOrder => 'סיום ההזמנה';

  @override
  String get orderReview => 'סיכום הזמנה';

  @override
  String get yourOrderReview => 'סיכום ההזמנה';

  @override
  String get close => 'סגור';

  @override
  String get articles => 'פריטים';

  @override
  String get back => 'חזור';

  @override
  String get confirm => 'אשר';

  @override
  String get orderConfirmedAnnouncement => 'ההזמנה אושרה';

  @override
  String get add => 'הוסף';

  @override
  String get badgePopular => 'פופולרי';

  @override
  String get badgeNew => 'חדש';

  @override
  String get badgeSpecialty => 'המיוחדים';

  @override
  String get badgeChef => 'בחירת השף';

  @override
  String get badgeSeasonal => 'עונתי';

  @override
  String get badgeSignature => 'מנת חתימה';

  @override
  String get removeThisItem => 'להסיר פריט זה?';

  @override
  String get removeFromCart => 'הסר מהסל';

  @override
  String get update => 'עדכן';

  @override
  String get increaseQuantity => 'הגדל כמות';

  @override
  String get decreaseQuantity => 'הקטן כמות';

  @override
  String get increase => 'הגדל';

  @override
  String get decrease => 'הקטן';

  @override
  String get waiter => 'מלצר';

  @override
  String get badgesGuide => 'מדריך תגיות';

  @override
  String get badgeDescPopular => 'המנות המוזמנות ביותר';

  @override
  String get badgeDescNew => 'חדש בתפריט';

  @override
  String get badgeDescSpecialty => 'מנות המיוחדים של הבית';

  @override
  String get badgeDescChef => 'המלצות השף';

  @override
  String get badgeDescSeasonal => 'מנות עונתיות';

  @override
  String get understood => 'הבנתי';
}
