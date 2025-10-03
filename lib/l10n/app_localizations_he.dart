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
  String get badgeDescSpecialty => 'המנות המיוחדות של הבית';

  @override
  String get badgeDescChef => 'המלצות השף';

  @override
  String get badgeDescSeasonal => 'מנות עונתיות';

  @override
  String get understood => 'הבנתי';

  @override
  String get commonAdd => 'הוסף';

  @override
  String get commonEdit => 'ערוך';

  @override
  String get commonDelete => 'מחק';

  @override
  String get commonCancel => 'ביטול';

  @override
  String get commonSave => 'שמור';

  @override
  String get commonOpen => 'פתח';

  @override
  String get commonClose => 'סגור';

  @override
  String get commonSearch => 'חיפוש...';

  @override
  String get commonLoading => 'טוען...';

  @override
  String commonError(String error) {
    return 'שגיאה: $error';
  }

  @override
  String get adminShellAppName => 'SmartMenu';

  @override
  String get adminShellNavDashboard => 'לוח בקרה';

  @override
  String get adminShellNavMenu => 'תפריט';

  @override
  String get adminShellNavOrders => 'הזמנות';

  @override
  String get adminShellNavMedia => 'מדיה';

  @override
  String get adminShellNavBranding => 'מיתוג';

  @override
  String get adminShellNavRestaurantInfo => 'פרטי מסעדה';

  @override
  String get adminShellNavSettings => 'הגדרות';

  @override
  String get adminShellUserRole => 'בעלים';

  @override
  String get adminShellUserDefault => 'משתמש';

  @override
  String get adminShellLogout => 'התנתק';

  @override
  String get adminDashboardTitle => 'לוח בקרה';

  @override
  String get adminDashboardMetricDishes => 'מנות';

  @override
  String get adminDashboardMetricCategories => 'קטגוריות';

  @override
  String get adminDashboardMetricWithImage => 'עם תמונה';

  @override
  String get adminDashboardMetricNoImage => 'ללא תמונה';

  @override
  String get adminDashboardMetricSignature => 'מנות חתימה';

  @override
  String get adminDashboardAddDish => 'הוסף מנה';

  @override
  String get adminDashboardQuickActions => 'פעולות מהירות';

  @override
  String get adminDashboardManageMedia => 'נהל מדיה';

  @override
  String get adminDashboardEditInfo => 'ערוך פרטים';

  @override
  String get adminDashboardPreviewMenu => 'תצוגה מקדימה של התפריט';

  @override
  String get adminDashboardViewClientMenu => 'צפה בתפריט שלך כלקוח';

  @override
  String adminDashboardItemsWithoutImage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count פריטים ללא תמונה',
      one: 'פריט אחד ללא תמונה',
      zero: 'אין פריטים ללא תמונה',
    );
    return '$_temp0';
  }

  @override
  String get adminDashboardFix => 'עדקן';

  @override
  String get adminDashboardMyRestaurant => 'המסעדה שלי';

  @override
  String get adminMenuTitle => 'תפריט';

  @override
  String get adminMenuManageCategories => 'נהל קטגוריות';

  @override
  String get adminMenuReorder => 'סדר מחדש';

  @override
  String get adminMenuReorderDishes => 'סדר מנות מחדש';

  @override
  String get adminMenuCategory => 'קטגוריה';

  @override
  String get adminMenuName => 'שם';

  @override
  String get adminMenuPrice => 'מחיר';

  @override
  String get adminMenuFeatured => 'מומלץ';

  @override
  String get adminMenuWithBadges => 'עם תגיות';

  @override
  String get adminMenuNoImage => 'ללא תמונה';

  @override
  String get adminMenuAll => 'הכל';

  @override
  String get adminMenuNewCategory => 'קטגוריה חדשה';

  @override
  String get adminMenuCategoryName => 'שם הקטגוריה';

  @override
  String get adminMenuCategoryExample => 'לדוגמה: קינוחים';

  @override
  String get adminMenuNoCategory => 'ללא קטגוריה';

  @override
  String get adminMenuNoDishes => 'אין מנות בתפריט';

  @override
  String get adminMenuAddFirstDish => 'הוסף את המנה הראשונה שלך כדי להתחיל';

  @override
  String get adminMenuConfirmDelete => 'אישור מחיקה';

  @override
  String adminMenuConfirmDeleteMessage(String name) {
    return 'האם אתה בטוח שברצונך למחוק את \"$name\"?';
  }

  @override
  String adminMenuDeleteSuccess(String name) {
    return '\"$name\" נמחק בהצלחה';
  }

  @override
  String adminMenuDeleteError(String error) {
    return 'שגיאה במחיקה: $error';
  }

  @override
  String get adminMenuCategoryUpdated => 'הקטגוריה עודכנה.';

  @override
  String get adminOrdersTitle => 'הזמנות';

  @override
  String get adminOrdersReceived => 'התקבלה';

  @override
  String get adminOrdersPreparing => 'בהכנה';

  @override
  String get adminOrdersReady => 'מוכנה';

  @override
  String get adminOrdersServed => 'הוגשה';

  @override
  String adminOrdersTable(String number) {
    return 'שולחן $number';
  }

  @override
  String adminOrdersItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count פריטים',
      one: 'פריט אחד',
    );
    return '$_temp0';
  }

  @override
  String get adminOrdersMarkPreparing => 'התחל הכנה';

  @override
  String get adminOrdersMarkReady => 'סמן מוכנה';

  @override
  String get adminOrdersMarkServed => 'סמן הוגשה';

  @override
  String get adminOrdersNoOrders => 'אין הזמנות';

  @override
  String get adminOrdersTotal => 'סה״כ';

  @override
  String adminOrdersServerCall(String table) {
    return 'קריאה משולחן $table';
  }

  @override
  String get adminOrdersAcknowledge => 'אישור קבלה';

  @override
  String get adminOrdersResolve => 'סגור קריאה';

  @override
  String get adminOrdersJustNow => 'ממש עכשיו';

  @override
  String adminOrdersMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'לפני $count דקות',
      one: 'לפני דקה',
    );
    return '$_temp0';
  }

  @override
  String adminOrdersStatusUpdated(String status) {
    return 'ההזמנה עודכנה: $status';
  }

  @override
  String adminOrdersServerCallBody(String table) {
    return '$table זקוק לסיוע';
  }
}
