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
  String get adminDashboardFix => 'עדכן';

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

  @override
  String get adminSettingsTitle => 'הגדרות';

  @override
  String get adminSettingsRestaurant => 'מסעדה';

  @override
  String get adminSettingsRestaurantName => 'שם המסעדה';

  @override
  String get adminSettingsLoading => 'טוען...';

  @override
  String get adminSettingsNamePlaceholder => 'לדוגמה: פיצה מריו';

  @override
  String get adminSettingsNameRequired => 'שם המסעדה הוא שדה חובה';

  @override
  String get adminSettingsNameTooShort => 'השם חייב להכיל לפחות 2 תווים';

  @override
  String get adminSettingsNameTooLong => 'השם לא יכול לעבור 50 תווים';

  @override
  String get adminSettingsNameUpdated => 'שם המסעדה עודכן בהצלחה';

  @override
  String adminSettingsSaveError(String error) {
    return 'שגיאה בשמירה: $error';
  }

  @override
  String get adminSettingsLoadError => 'לא ניתן לטעון את שם המסעדה';

  @override
  String get adminSettingsDetailedInfo => 'מידע מפורט';

  @override
  String get adminSettingsDetailedInfoSubtitle => 'תיאור, באנר קידום, מטבע';

  @override
  String get adminSettingsManageCategories => 'נהל קטגוריות';

  @override
  String get adminSettingsCategoriesSubtitle => 'סדר מחדש, הסתר ושנה שם';

  @override
  String get adminSettingsIntegration => 'אינטגרציה';

  @override
  String get adminSettingsRestaurantCode => 'קוד מסעדה';

  @override
  String get adminSettingsPublicUrl => 'כתובת URL ציבורית';

  @override
  String get adminSettingsGenerateQr => 'צור QR';

  @override
  String adminSettingsCopied(String value) {
    return 'הועתק: $value';
  }

  @override
  String adminSettingsCodeGenerated(String code) {
    return 'קוד נוצר: $code';
  }

  @override
  String get adminSettingsQrGenerator => 'מחולל קוד QR';

  @override
  String get adminSettingsConfiguration => 'הגדרות';

  @override
  String get adminSettingsCustomMessage => 'הודעה מותאמת אישית (אופציונלי)';

  @override
  String get adminSettingsCustomMessageHint => 'לדוגמה: ברוכים הבאים!';

  @override
  String get adminSettingsCustomMessageHelper => 'מוצג מעל קוד ה-QR';

  @override
  String get adminSettingsDownloadSize => 'גודל הורדה';

  @override
  String get adminSettingsSizeSmall => 'קטן';

  @override
  String get adminSettingsSizeMedium => 'בינוני';

  @override
  String get adminSettingsSizeLarge => 'גדול';

  @override
  String get adminSettingsConfigSaved => 'ההגדרות נשמרו';

  @override
  String get adminSettingsScanToAccess => 'סרוק כדי לגשת לתפריט';

  @override
  String get adminSettingsDownloadQr => 'הורד';

  @override
  String get adminSettingsTemplateA5 => 'תבנית A5';

  @override
  String get adminSettingsQrDownloaded => 'קוד QR הורד בהצלחה!';

  @override
  String get adminSettingsTemplateDownloaded => 'תבנית A5 הורדה!';

  @override
  String get adminSettingsUrlCopied => 'הכתובת הועתקה ללוח';

  @override
  String get adminSettingsShareMenu => 'שתף את התפריט שלך';

  @override
  String get adminSettingsChooseMethod => 'בחר שיטה';

  @override
  String get adminSettingsCopyLink => 'העתק קישור';

  @override
  String get adminSettingsEmail => 'אימייל';

  @override
  String get adminSettingsSms => 'SMS';

  @override
  String get adminSettingsWhatsApp => 'WhatsApp';

  @override
  String get adminSettingsFacebook => 'Facebook';

  @override
  String get adminSettingsUrlCopiedSuccess => 'הכתובת הועתקה ללוח';

  @override
  String get commonShare => 'שתף';

  @override
  String get commonLanguage => 'שפה';

  @override
  String get adminRestaurantInfoTitle => 'מידע על המסעדה';

  @override
  String get adminRestaurantInfoTaglineSection => 'טקסט משנה (תיאור קצר)';

  @override
  String get adminRestaurantInfoTaglinePlaceholder =>
      'לדוגמה: פיצה איטלקית אמיתית בתל אביב';

  @override
  String get adminRestaurantInfoTaglineMaxLength => '120 תווים מקסימום';

  @override
  String get adminRestaurantInfoPromoToggleTitle => 'הצג באנר פרסומי';

  @override
  String get adminRestaurantInfoPromoToggleSubtitle =>
      'בטל סימון כדי להסתיר את הבאנר באתר';

  @override
  String get adminRestaurantInfoPromoSection => 'באנר פרסומי (אופציונלי)';

  @override
  String get adminRestaurantInfoPromoPlaceholder =>
      'לדוגמה: ✨ פיצה שנייה -50% • משלוח חינם מ-80₪ ✨';

  @override
  String get adminRestaurantInfoPromoMaxLength => '140 תווים מקסימום';

  @override
  String adminRestaurantInfoLoadError(String error) {
    return 'שגיאה בטעינת מידע: $error';
  }

  @override
  String get adminRestaurantInfoSaveSuccess => 'המידע נשמר ✅';

  @override
  String adminRestaurantInfoSaveError(String error) {
    return 'שגיאה בשמירה: $error';
  }

  @override
  String get adminMediaTitle => 'מדיה';

  @override
  String get adminMediaAddButton => 'הוסף';

  @override
  String get adminMediaDropZoneClick => 'לחץ לבחירת קובץ';

  @override
  String get adminMediaDropZoneFormats => 'PNG, JPG, WebP - מקסימום 5MB';

  @override
  String get adminMediaErrorFormat =>
      'פורמט לא נתמך. השתמש ב-PNG, JPG או WebP.';

  @override
  String get adminMediaErrorSize => 'קובץ גדול מדי (מקסימום 5MB).';

  @override
  String adminMediaErrorLoad(String error) {
    return 'שגיאה בטעינת מדיה: $error';
  }

  @override
  String adminMediaErrorUpload(String error) {
    return 'שגיאת העלאה: $error';
  }

  @override
  String get adminMediaSuccessUpload => 'התמונה הועלתה בהצלחה!';

  @override
  String get adminMediaSuccessDelete => 'המדיה נמחק בהצלחה';

  @override
  String get adminMediaSuccessAssign => 'התמונה הוקצתה בהצלחה';

  @override
  String get adminMediaUploadProgress => 'העלאה בתהליך...';

  @override
  String get adminMediaDeleteTitle => 'מחק מדיה';

  @override
  String adminMediaDeleteConfirm(String name) {
    return 'האם אתה בטוח שברצונך למחוק את \"$name\"?';
  }

  @override
  String get adminMediaDeleteButton => 'מחק';

  @override
  String get adminMediaAssignTitle => 'הקצה למנה';

  @override
  String get adminMediaAssignSearch => 'חפש מנה...';

  @override
  String get adminMediaAssignNoDishes => 'אין מנות זמינות';

  @override
  String get adminMediaEmptyTitle => 'אין מדיה';

  @override
  String get adminMediaEmptySubtitle =>
      'הוסף את התמונות הראשונות שלך כדי להתחיל';

  @override
  String get adminMediaAssignButton => 'הקצה';

  @override
  String get adminBrandingTitle => 'מיתוג';

  @override
  String get adminBrandingIdentity => 'זהות המותג';

  @override
  String get adminBrandingLogoSection => 'לוגו המסעדה';

  @override
  String get adminBrandingLogoFormat =>
      'פורמט מומלץ: PNG מרובע, רקע שקוף, מינימום 256×256px';

  @override
  String get adminBrandingLogoFormats => 'PNG מומלץ (רקע שקוף), JPG מקובל';

  @override
  String get adminBrandingUploadClick => 'לחץ להעלאת לוגו';

  @override
  String get adminBrandingErrorSize => 'הקובץ חייב להיות קטן מ-2MB';

  @override
  String get adminBrandingErrorFormat => 'אנא בחר תמונה (PNG/JPG)';

  @override
  String adminBrandingErrorSelection(String error) {
    return 'שגיאה בבחירה: $error';
  }

  @override
  String adminBrandingErrorLoad(String error) {
    return 'שגיאת טעינה: $error';
  }

  @override
  String get adminBrandingSuccessUpload => 'הלוגו הועלה בהצלחה';

  @override
  String get adminBrandingSuccessDelete => 'הלוגו נמחק בהצלחה';

  @override
  String get adminBrandingPreviewTitle => 'תצוגה מקדימה';

  @override
  String get adminBrandingPreviewDescription =>
      'ראה כיצד הלוגו שלך יופיע בממשק הלקוח';

  @override
  String get adminBrandingPreviewHero => 'כותרת ראשית';

  @override
  String get adminBrandingPreviewSticky => 'כותרת דביקה (מכווצת)';

  @override
  String get adminBrandingRestaurantDefault => 'מסעדה';

  @override
  String get badgesGuideSubtitle => 'תגיות אלו מסייעות להדגיש מנות מיוחדות';

  @override
  String get adminReorderTitle => 'סידור התפריט מחדש ';

  @override
  String get adminReorderBreadcrumbReorganize => 'סידור מחדש';

  @override
  String get adminReorderSaving => 'שומר...';

  @override
  String get adminReorderSaved => 'נשמר';

  @override
  String adminReorderSavedAgo(String time) {
    return 'נשמר • לפני $time';
  }

  @override
  String get adminReorderError => 'שגיאה';

  @override
  String get adminReorderUnsaved => 'לא נשמר';

  @override
  String get adminReorderPreview => 'תצוגה מקדימה';

  @override
  String get adminReorderBulkActions => 'פעולות קבוצתיות';

  @override
  String adminReorderMoveItems(int count) {
    return 'העבר ($count)';
  }

  @override
  String adminReorderHideItems(int count) {
    return 'הסתר ($count)';
  }

  @override
  String adminReorderShowItems(int count) {
    return 'הצג ($count)';
  }

  @override
  String get adminReorderCancelSelection => 'בטל בחירה';

  @override
  String get adminReorderCategories => 'קטגוריות';

  @override
  String adminReorderDishCount(int count, String category) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count מנות',
      one: 'מנה אחת',
      zero: '0 מנות',
    );
    return '$_temp0 • $category';
  }

  @override
  String get adminReorderSelect => 'בחר';

  @override
  String get adminReorderNoDishes => 'אין מנות בקטגוריה זו';

  @override
  String get adminReorderSignatureBadge => 'מיוחד';

  @override
  String adminReorderMoveDialogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count מנות',
      one: 'מנה אחת',
    );
    return 'העבר $_temp0';
  }

  @override
  String adminReorderLoadError(String error) {
    return 'שגיאת טעינה: $error';
  }

  @override
  String adminReorderPreviewError(String error) {
    return 'לא ניתן לפתוח תצוגה מקדימה: $error';
  }

  @override
  String adminReorderTimeSeconds(int seconds) {
    return '$secondsש';
  }

  @override
  String adminReorderTimeMinutes(int minutes) {
    return '$minutesד';
  }

  @override
  String get adminDishFormTitleEdit => 'עריכת מנה';

  @override
  String get adminDishFormTitleAdd => 'הוספת מנה';

  @override
  String get adminDishFormName => 'שם המנה *';

  @override
  String get adminDishFormDescription => 'תיאור';

  @override
  String get adminDishFormPrice => 'מחיר *';

  @override
  String get adminDishFormCategory => 'קטגוריה';

  @override
  String get adminDishFormNameRequired => 'שם בעברית הוא שדה חובה';

  @override
  String get adminDishFormPriceRequired => 'מחיר הוא שדה חובה';

  @override
  String get adminDishFormPriceInvalid => 'מחיר לא תקין';

  @override
  String get adminDishFormCopyFromFrench => 'העתק מצרפתית';

  @override
  String get adminDishFormCopyFromHebrew => 'העתק מעברית';

  @override
  String get adminDishFormCopyFromEnglish => 'העתק מאנגלית';

  @override
  String adminDishFormCopiedFrom(String language) {
    return 'תוכן הועתק מ$language';
  }

  @override
  String get adminDishFormOptions => 'אפשרויות';

  @override
  String get adminDishFormFeatured => 'הצג בראש';

  @override
  String get adminDishFormFeaturedSubtitle => 'נעץ בראש הקטגוריה';

  @override
  String get adminDishFormBadges => 'תגיות';

  @override
  String get adminDishFormBadgePopular => 'פופולרי';

  @override
  String get adminDishFormBadgeNew => 'חדש';

  @override
  String get adminDishFormBadgeSpecialty => 'מומחיות';

  @override
  String get adminDishFormBadgeChef => 'שף';

  @override
  String get adminDishFormBadgeSeasonal => 'עונתי';

  @override
  String get adminDishFormVisible => 'גלוי בתפריט';

  @override
  String get adminDishFormVisibleSubtitle => 'לקוחות יכולים לראות מנה זו';

  @override
  String get adminDishFormAddPhoto => 'הוסף תמונה';

  @override
  String get adminDishFormClickToSelect => 'לחץ לבחירה';

  @override
  String get adminDishFormAddButton => 'הוסף';

  @override
  String get adminDishFormChangeButton => 'שנה';

  @override
  String get adminDishFormRemoveButton => 'הסר';

  @override
  String get adminDishFormRemovePhoto => 'הסר תמונה';

  @override
  String get adminDishFormCannotSelectPhoto => 'לא ניתן לבחור תמונה';

  @override
  String adminDishFormSaveSuccess(String action) {
    return 'המנה $action בהצלחה';
  }

  @override
  String get adminDishFormActionModified => 'עודכנה';

  @override
  String get adminDishFormActionAdded => 'נוספה';

  @override
  String adminDishFormSaveError(String error) {
    return 'שגיאה: $error';
  }

  @override
  String get adminDishFormButtonSave => 'שמור';

  @override
  String get adminDishFormButtonAdd => 'הוסף';

  @override
  String get adminDishFormLanguageHebrew => '🇮🇱 עברית';

  @override
  String get adminDishFormLanguageEnglish => '🇬🇧 English';

  @override
  String get adminDishFormLanguageFrench => '🇫🇷 Français';

  @override
  String get adminCategoryManagerTitle => 'ניהול קטגוריות';

  @override
  String get adminCategoryManagerSubtitle => 'סדר מחדש והגדר';

  @override
  String get adminCategoryManagerSubtitleFull =>
      'סדר מחדש והגדר את הקטגוריות שלך';

  @override
  String get adminCategoryManagerNew => 'חדש';

  @override
  String get adminCategoryManagerUnsaved => 'שינויים לא נשמרו';

  @override
  String get adminCategoryManagerSaving => 'שומר...';

  @override
  String get adminCategoryManagerSaved => 'נשמר';

  @override
  String adminCategoryManagerSavedAgo(String time) {
    return 'נשמר • לפני $time';
  }

  @override
  String get adminCategoryManagerError => 'נכשל. נסה שוב';

  @override
  String get adminCategoryManagerHiddenBadge => 'מוסתר';

  @override
  String get adminCategoryManagerShowAction => 'הצג';

  @override
  String get adminCategoryManagerHideAction => 'הסתר';

  @override
  String adminCategoryManagerShowSemantic(String category) {
    return 'הצג $category';
  }

  @override
  String adminCategoryManagerHideSemantic(String category) {
    return 'הסתר $category';
  }

  @override
  String get adminCategoryManagerRenameAction => 'שנה שם';

  @override
  String adminCategoryManagerRenameSemantic(String category) {
    return 'שנה שם $category';
  }

  @override
  String get adminCategoryManagerDeleteAction => 'מחק';

  @override
  String adminCategoryManagerDeleteSemantic(String category) {
    return 'מחק $category';
  }

  @override
  String get adminCategoryManagerDragHint => 'גרור ושחרר כדי לסדר מחדש';

  @override
  String adminCategoryManagerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count קטגוריות',
      one: 'קטגוריה אחת',
    );
    return '$_temp0';
  }

  @override
  String get adminCategoryManagerDeleteTitle => 'למחוק קטגוריה?';

  @override
  String adminCategoryManagerDeleteMessage(String category) {
    return '\"$category\" תוסר מהרשימה.';
  }

  @override
  String get adminCategoryManagerRenameTitle => 'שינוי שם קטגוריה';

  @override
  String adminCategoryManagerRenameMessage(
      String oldName, String newName, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count מנות',
      one: 'מנה אחת',
    );
    return 'שנה שם מ\"$oldName\" ל\"$newName\" — $_temp0 יעודכנו.';
  }

  @override
  String adminCategoryManagerRenameProgress(int percent) {
    return 'מעדכן... $percent%';
  }

  @override
  String get adminCategoryManagerConfirm => 'אשר';

  @override
  String adminCategoryManagerSaveError(String error) {
    return 'שגיאת שמירה: $error';
  }

  @override
  String get adminCategoryManagerRetry => 'נסה שוב';

  @override
  String get adminCategoryManagerDefaultName => 'קטגוריה חדשה';

  @override
  String get adminSignupTitle => 'צור את המרחב שלך';

  @override
  String get adminSignupSubtitle => 'התחל לנהל את המסעדה שלך תוך דקות';

  @override
  String get adminSignupEmailLabel => 'אימייל מקצועי';

  @override
  String get adminSignupEmailPlaceholder => 'restaurant@example.com';

  @override
  String get adminSignupPasswordLabel => 'סיסמה';

  @override
  String get adminSignupPasswordPlaceholder => '••••••••';

  @override
  String get adminSignupButton => 'צור חשבון';

  @override
  String get adminSignupAlreadyHaveAccount => 'כבר יש לך חשבון?';

  @override
  String get adminSignupLoginLink => 'התחבר';

  @override
  String get adminSignupEmailRequired => 'נא להזין את האימייל שלך';

  @override
  String get adminSignupPasswordHint => 'מומלץ 8+ תווים';

  @override
  String get adminSignupPasswordRequired => 'נא להזין סיסמה';

  @override
  String get adminSignupPasswordTooShort => 'הסיסמה חייבת להכיל לפחות 8 תווים';

  @override
  String get adminSignupConfirmPasswordLabel => 'אשר סיסמה';

  @override
  String get adminSignupConfirmPasswordRequired => 'נא לאשר את הסיסמה שלך';

  @override
  String get adminSignupPasswordMismatch => 'הסיסמאות אינן תואמות';

  @override
  String get adminSignupButtonLoading => 'יוצר חשבון...';

  @override
  String get adminSignupErrorGeneric =>
      'לא ניתן ליצור חשבון. בדוק את המידע שלך.';

  @override
  String get adminSignupErrorUnknown => 'אירעה שגיאה. אנא נסה שוב.';

  @override
  String get adminSettingsDefaultLanguage => 'שפת תפריט ברירת מחדל';

  @override
  String get adminSettingsDefaultLanguageSubtitle =>
      'שפה המוצגת ללקוחות כברירת מחדל';

  @override
  String get adminSettingsDefaultLanguageUpdated => 'שפת ברירת המחדל עודכנה';

  @override
  String get adminSettingsMenuFeatures => 'תכונות התפריט';

  @override
  String get adminSettingsEnableOrders => 'הפעל הזמנות';

  @override
  String get adminSettingsEnableOrdersSubtitle => 'אפשר ללקוחות לבצע הזמנות';

  @override
  String get adminSettingsOrdersUpdated => 'הגדרת הזמנות עודכנה';

  @override
  String get adminSettingsEnableServerCall => 'הפעל קריאה למלצר';

  @override
  String get adminSettingsEnableServerCallSubtitle =>
      'הצג כפתור קריאה למלצר ללקוחות';

  @override
  String get adminSettingsServerCallUpdated => 'הגדרת קריאה למלצר עודכנה';

  @override
  String get cartVisualOnly => 'הראה סל זה למלצר כדי להזמין';

  @override
  String get viewOrder => 'צפה בהזמנה';

  @override
  String get adminResetTitle => 'שכחת סיסמה';

  @override
  String get adminResetSubtitle => 'הזן את המייל שלך לקבלת קישור לאיפוס';

  @override
  String get adminResetButton => 'שלח קישור';

  @override
  String get adminResetSending => 'שולח...';

  @override
  String get adminResetBackToLogin => 'חזרה להתחברות';

  @override
  String get adminResetEmailSentTitle => 'המייל נשלח';

  @override
  String get adminResetEmailSentMessage =>
      'קישור לאיפוס סיסמה נשלח לכתובת המייל שלך.';
}
