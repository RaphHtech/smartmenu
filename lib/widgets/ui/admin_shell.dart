import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:smartmenu_app/core/breakpoint_controller.dart';
import 'package:smartmenu_app/l10n/app_localizations.dart';
import 'package:smartmenu_app/screens/admin/admin_branding_screen.dart';
import 'package:smartmenu_app/screens/admin/admin_orders_screen.dart';
import 'package:smartmenu_app/state/language_provider.dart';
import '../../screens/admin/admin_dashboard_overview_screen.dart';
import '../../core/design/admin_tokens.dart';
import '../../core/design/admin_typography.dart';
import '../../screens/admin/admin_login_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/admin_media_screen.dart';
import '../../screens/admin/admin_settings_screen.dart';
import '../../screens/admin/admin_restaurant_info_screen.dart';
import '../../widgets/ui/admin_themed.dart';
import '../../widgets/language_selector_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Layout principal pour l'interface admin avec sidebar + topbar
/// Interface SaaS professionnelle inspirée de Notion, Linear, Stripe
class AdminShell extends StatefulWidget {
  final Widget child;
  final String title;
  final List<String> breadcrumbs;
  final List<Widget>? actions;
  final String? restaurantId;
  final String? activeRoute; // ✅ AJOUTER cette ligne

  const AdminShell({
    super.key,
    required this.child,
    required this.title,
    this.breadcrumbs = const [],
    this.actions,
    this.restaurantId,
    this.activeRoute, // ✅ AJOUTER cette ligne
  });

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  static final _logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
    level: kDebugMode ? Level.debug : Level.off,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedRoute = '/dashboard';
  String get _currentRoute => widget.activeRoute ?? _selectedRoute;
  late final BreakpointController _breakpointController;
  @override
  void initState() {
    super.initState();
    if (widget.activeRoute != null) {
      _selectedRoute = widget.activeRoute!;
    }

    // ✅ CORRECT
    _breakpointController = BreakpointController(false);
  }

  @override
  void didUpdateWidget(covariant AdminShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _logger.d(
        'AdminShell didUpdateWidget - old: ${oldWidget.activeRoute}, new: ${widget.activeRoute}');
    if (widget.activeRoute != null &&
        widget.activeRoute != oldWidget.activeRoute) {
      setState(() => _selectedRoute = widget.activeRoute!);
    }
  }

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Navigation items
// Navigation items (construits dynamiquement pour i18n)
  List<AdminNavItem> _getNavItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      AdminNavItem(
        route: '/dashboard',
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: l10n.adminShellNavDashboard,
      ),
      AdminNavItem(
        route: '/menu',
        icon: Icons.restaurant_menu_outlined,
        activeIcon: Icons.restaurant_menu,
        label: l10n.adminShellNavMenu,
      ),
      AdminNavItem(
        route: '/orders',
        icon: Icons.receipt_outlined,
        activeIcon: Icons.receipt,
        label: l10n.adminShellNavOrders,
        showBadge: true,
      ),
      AdminNavItem(
        route: '/media',
        icon: Icons.photo_library_outlined,
        activeIcon: Icons.photo_library,
        label: l10n.adminShellNavMedia,
      ),
      AdminNavItem(
        route: '/branding',
        icon: Icons.palette_outlined,
        activeIcon: Icons.palette,
        label: l10n.adminShellNavBranding,
      ),
      AdminNavItem(
        route: '/info',
        icon: Icons.info_outline,
        activeIcon: Icons.info,
        label: l10n.adminShellNavRestaurantInfo,
      ),
      AdminNavItem(
        route: '/settings',
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: l10n.adminShellNavSettings,
      ),
    ];
  }

  @override
  void dispose() {
    _breakpointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.d(
        'AdminShell rebuild ${DateTime.now().millisecond} - route: $_currentRoute');

    return LayoutBuilder(
      builder: (context, constraints) {
        // Mettre à jour le contrôleur avec la largeur actuelle
        _breakpointController.update(constraints.maxWidth);

        return ValueListenableBuilder<bool>(
          valueListenable: _breakpointController,
          builder: (context, isDesktop, child) {
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: AdminTokens.neutral50,
              drawer: _buildDrawer(),
              body: Row(
                children: [
                  if (isDesktop) _buildSidebar(),
                  Expanded(
                    child: Column(
                      children: [
                        _buildTopbar(),
                        _buildBreadcrumbs(),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AdminTokens.space24),
                            child: widget.child,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: AdminTokens.sidebarWidth,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: AdminTokens.neutral200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          Expanded(child: _buildNavigation()),
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildSidebarHeader(),
          Expanded(child: _buildNavigation()),
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      height: AdminTokens.topbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AdminTokens.space20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AdminTokens.neutral200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AdminTokens.primary500, AdminTokens.primary600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AdminTokens.radius8),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: AdminTokens.space12),
          //
          Text(
            AppLocalizations.of(context)!.adminShellAppName,
            style: AdminTypography.headlineLarge.copyWith(
              color: AdminTokens.neutral900,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Builder(
      builder: (context) {
        final navItems = _getNavItems(context);
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: AdminTokens.space16),
          children: navItems.map((item) {
            final isActive = _currentRoute == item.route;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminTokens.space12,
                vertical: AdminTokens.space4,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AdminTokens.radius8),
                  onTap: () => _onNavItemTap(item.route),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AdminTokens.space12,
                      vertical: AdminTokens.space12,
                    ),
                    // État actif plus visible avec barre latérale
                    decoration: BoxDecoration(
                      color:
                          isActive ? AdminTokens.primary50 : Colors.transparent,
                      borderRadius: BorderRadius.circular(AdminTokens.radius8),
                      border: isActive
                          ? const Border(
                              left: BorderSide(
                                  color: AdminTokens.primary600, width: 2),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          size: AdminTokens.iconMd,
                          color: isActive
                              ? AdminTokens.primary600
                              : AdminTokens.neutral500,
                        ),
                        const SizedBox(width: AdminTokens.space12),
                        Text(
                          item.label,
                          style: AdminTypography.bodyMedium.copyWith(
                            color: isActive
                                ? AdminTokens.primary600
                                : AdminTokens.neutral600,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        const Spacer(),

                        // Badge pour les commandes
                        if (item.showBadge && item.route == '/orders')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AdminTokens.neutral100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '0',
                              style: AdminTypography.labelSmall.copyWith(
                                color: AdminTokens.neutral500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(AdminTokens.space16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AdminTokens.neutral200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AdminTokens.primary50,
            child: Text(
              (_currentUser?.email?.split('@')[0]) ??
                  AppLocalizations.of(context)!.adminShellUserDefault,
              style: AdminTypography.labelMedium.copyWith(
                color: AdminTokens.primary600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AdminTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (_currentUser?.email?.split('@')[0]) ?? 'Utilisateur',
                  style: AdminTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppLocalizations.of(context)!.adminShellUserRole,
                  style: AdminTypography.labelSmall,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              size: AdminTokens.iconSm,
              color: AdminTokens.neutral400,
            ),
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout,
                        size: 16, color: AdminTokens.error500),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.adminShellLogout),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopbar() {
    return ValueListenableBuilder<bool>(
      valueListenable: _breakpointController,
      builder: (context, isDesktop, child) {
        return Container(
          height: AdminTokens.topbarHeight,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: AdminTokens.neutral200,
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? AdminTokens.space24 : AdminTokens.space12,
            ),
            child: Row(
              children: [
                // Navigation
                Builder(
                  builder: (context) {
                    final canPop = Navigator.of(context).canPop();
                    final showBack = (_currentRoute != '/dashboard') && canPop;

                    if (!isDesktop) {
                      return IconButton(
                        icon: Icon(
                            showBack ? Icons.arrow_back_ios_new : Icons.menu),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        onPressed: () => showBack
                            ? Navigator.maybePop(context)
                            : _scaffoldKey.currentState?.openDrawer(),
                      );
                    }

                    if (showBack) {
                      return IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.maybePop(context),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                SizedBox(width: isDesktop ? 16 : 12),

                // TITRE
                Expanded(
                  child: Text(
                    widget.title,
                    style: isDesktop
                        ? AdminTypography.headlineLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          )
                        : AdminTypography.headlineMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                SizedBox(width: isDesktop ? 16 : 8),

                // ACTIONS CUSTOM (bouton +, burger ⋮, etc.) - TOUJOURS AFFICHÉES
                if (widget.actions != null) ...[
                  ...widget.actions!,
                  SizedBox(width: isDesktop ? 12 : 8),
                ],

                // DESKTOP: Langue + Avatar
                if (isDesktop) ...[
                  Container(
                    width: 1,
                    height: 24,
                    color: AdminTokens.neutral200,
                  ),
                  const SizedBox(width: 16),
                  const LanguageSelectorWidget(),
                  const SizedBox(width: 16),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AdminTokens.primary50,
                    child: Text(
                      (_currentUser?.email?.substring(0, 1).toUpperCase()) ??
                          'U',
                      style: AdminTypography.labelMedium.copyWith(
                        color: AdminTokens.primary600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],

                // MOBILE: Dropdown langue compact premium
                if (!isDesktop)
                  StatefulBuilder(
                    builder: (context, setState) {
                      final currentLocale = Localizations.localeOf(context);

                      return Theme(
                        data: Theme.of(context).copyWith(
                          popupMenuTheme: PopupMenuThemeData(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AdminTokens.radius12),
                            ),
                            color: Colors.white,
                          ),
                        ),
                        child: PopupMenuButton<Locale>(
                          icon: const Icon(Icons.language, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          offset: const Offset(0, 45),
                          tooltip: AppLocalizations.of(context)!.commonLanguage,
                          onSelected: (locale) async {
                            // ✅ Close menu immédiatement
                            Navigator.of(context, rootNavigator: true).pop();

                            // ✅ Attendre frame suivante
                            await Future.delayed(
                                const Duration(milliseconds: 50));

                            // ✅ Change langue si widget toujours monté
                            if (context.mounted) {
                              final provider = Provider.of<LanguageProvider>(
                                context,
                                listen: false,
                              );
                              await provider.setLocale(locale);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<Locale>(
                              value: const Locale('en'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AdminTokens.space16,
                                vertical: AdminTokens.space12,
                              ),
                              child: SizedBox(
                                width: 150,
                                child: Row(
                                  children: [
                                    const Text('🇬🇧',
                                        style: TextStyle(fontSize: 22)),
                                    const SizedBox(width: AdminTokens.space12),
                                    Expanded(
                                      child: Text(
                                        'English',
                                        style:
                                            AdminTypography.bodyMedium.copyWith(
                                          fontWeight:
                                              currentLocale.languageCode == 'en'
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                          color:
                                              currentLocale.languageCode == 'en'
                                                  ? AdminTokens.primary600
                                                  : AdminTokens.neutral900,
                                        ),
                                      ),
                                    ),
                                    if (currentLocale.languageCode == 'en')
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AdminTokens.primary600,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem<Locale>(
                              value: const Locale('he'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AdminTokens.space16,
                                vertical: AdminTokens.space12,
                              ),
                              child: SizedBox(
                                width: 150,
                                child: Row(
                                  children: [
                                    const Text('🇮🇱',
                                        style: TextStyle(fontSize: 22)),
                                    const SizedBox(width: AdminTokens.space12),
                                    Expanded(
                                      child: Text(
                                        'עברית',
                                        style:
                                            AdminTypography.bodyMedium.copyWith(
                                          fontWeight:
                                              currentLocale.languageCode == 'he'
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                          color:
                                              currentLocale.languageCode == 'he'
                                                  ? AdminTokens.primary600
                                                  : AdminTokens.neutral900,
                                        ),
                                      ),
                                    ),
                                    if (currentLocale.languageCode == 'he')
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AdminTokens.primary600,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem<Locale>(
                              value: const Locale('fr'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AdminTokens.space16,
                                vertical: AdminTokens.space12,
                              ),
                              child: SizedBox(
                                width: 150,
                                child: Row(
                                  children: [
                                    const Text('🇫🇷',
                                        style: TextStyle(fontSize: 22)),
                                    const SizedBox(width: AdminTokens.space12),
                                    Expanded(
                                      child: Text(
                                        'Français',
                                        style:
                                            AdminTypography.bodyMedium.copyWith(
                                          fontWeight:
                                              currentLocale.languageCode == 'fr'
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                          color:
                                              currentLocale.languageCode == 'fr'
                                                  ? AdminTokens.primary600
                                                  : AdminTokens.neutral900,
                                        ),
                                      ),
                                    ),
                                    if (currentLocale.languageCode == 'fr')
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AdminTokens.primary600,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreadcrumbs() {
    if (widget.breadcrumbs.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminTokens.space24,
        vertical: AdminTokens.space12,
      ),
      child: Row(
        children: [
          for (int i = 0; i < widget.breadcrumbs.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(width: AdminTokens.space8),
              const Icon(
                Icons.chevron_right,
                size: AdminTokens.iconSm,
                color: AdminTokens.neutral400,
              ),
              const SizedBox(width: AdminTokens.space8),
            ],
            Text(
              widget.breadcrumbs[i],
              style: AdminTypography.bodySmall.copyWith(
                color: i == widget.breadcrumbs.length - 1
                    ? AdminTokens.neutral600
                    : AdminTokens.neutral400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getRestaurantId() {
    if (widget.restaurantId == null) {
      throw Exception('Restaurant ID manquant dans AdminShell');
    }
    return widget.restaurantId!;
  }

  void _onNavItemTap(String route) {
    setState(() => _selectedRoute = route);

    // Fermer le drawer sur mobile
    if (MediaQuery.of(context).size.width < 1024) {
      Navigator.of(context).pop();
    }

    final rid = _getRestaurantId(); // ← Ligne corrigée

    // ✅ DASHBOARD = Reset pile (racine propre)
    if (route == '/dashboard') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => AdminThemed(
            child: AdminDashboardOverviewScreen(restaurantId: rid),
          ),
        ),
        (r) => false,
      );
      return;
    }

    // ✅ AUTRES PAGES = Push simple (retour visible)
    Widget screen;
    switch (route) {
      case '/menu':
        screen = AdminDashboardScreen(restaurantId: rid);
        break;
      case '/orders':
        screen = AdminOrdersScreen(restaurantId: rid);
        break;
      case '/media':
        screen = AdminMediaScreen(restaurantId: rid);
        break;
      case '/branding':
        screen = AdminBrandingScreen(restaurantId: rid);
        break;
      case '/info':
        screen = AdminRestaurantInfoScreen(restaurantId: rid);
        break;
      case '/settings':
        screen = AdminSettingsScreen(restaurantId: rid);
        break;
      default:
        return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AdminThemed(child: screen)),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
        (route) => false,
      );
    }
  }
}

class AdminNavItem {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool showBadge; // Ajouter cette ligne

  const AdminNavItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.showBadge = false, // Ajouter cette ligne
  });
}
