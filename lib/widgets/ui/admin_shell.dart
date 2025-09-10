// lib/widgets/ui/admin_shell.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmenu_app/screens/admin/admin_dashboard_overview_screen.dart';
// import 'package:smartmenu_app/screens/admin/admin_dashboard_overview_screen.dart';
import '../../core/design/admin_tokens.dart';
import '../../core/design/admin_typography.dart';
import '../../screens/admin/admin_login_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/admin_media_screen.dart';
import '../../screens/admin/admin_settings_screen.dart';
import '../../screens/admin/admin_restaurant_info_screen.dart';
import '../../widgets/ui/admin_themed.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedRoute = '/dashboard';
  String get _currentRoute => widget.activeRoute ?? _selectedRoute;

  @override
  void initState() {
    super.initState();
    if (widget.activeRoute != null) {
      _selectedRoute = widget.activeRoute!;
    }
  }

  @override
  void didUpdateWidget(covariant AdminShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeRoute != null &&
        widget.activeRoute != oldWidget.activeRoute) {
      setState(() => _selectedRoute = widget.activeRoute!);
    }
  }

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Navigation items
  final List<AdminNavItem> _navItems = [
    const AdminNavItem(
      route: '/dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    const AdminNavItem(
      route: '/menu',
      icon: Icons.restaurant_menu_outlined,
      activeIcon: Icons.restaurant_menu,
      label: 'Menu',
    ),
    const AdminNavItem(
      route: '/media',
      icon: Icons.photo_library_outlined,
      activeIcon: Icons.photo_library,
      label: 'Médias',
    ),
    const AdminNavItem(
      route: '/info',
      icon: Icons.info_outline,
      activeIcon: Icons.info,
      label: 'Infos resto',
    ),
    const AdminNavItem(
      route: '/settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Paramètres',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AdminTokens.neutral50,

      // Drawer pour mobile
      drawer: _buildDrawer(),

      body: Row(
        children: [
          // Sidebar pour desktop
          if (MediaQuery.of(context).size.width >= 1024) _buildSidebar(),

          // Zone de contenu principal
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
            'SmartMenu',
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
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AdminTokens.space16),
      children: _navItems.map((item) {
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
                decoration: BoxDecoration(
                  color: isActive ? AdminTokens.primary50 : Colors.transparent,
                  borderRadius: BorderRadius.circular(AdminTokens.radius8),
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
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
              (_currentUser?.email?.substring(0, 1).toUpperCase()) ?? 'U',
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
                const Text(
                  'Propriétaire',
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
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 16, color: AdminTokens.error500),
                    SizedBox(width: 8),
                    Text('Se déconnecter'),
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
        padding: const EdgeInsets.symmetric(horizontal: AdminTokens.space24),
        child: Row(
          children: [
            // Menu burger pour mobile
            // Leading (back ou burger)
            Builder(
              builder: (context) {
                final w = MediaQuery.of(context).size.width;
                final canPop = Navigator.of(context).canPop();

                // ✅ Utiliser activeRoute en priorité pour déterminer showBack
                final currentRoute = _currentRoute;
                final showBack =
                    (currentRoute == '/dashboard') ? false : canPop;
                if (w < 1024) {
                  return IconButton(
                    icon:
                        Icon(showBack ? Icons.arrow_back_ios_new : Icons.menu),
                    onPressed: () => showBack
                        ? Navigator.maybePop(context)
                        : _scaffoldKey.currentState?.openDrawer(),
                  );
                }

                if (showBack) {
                  return IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.maybePop(context),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Titre de la page
            Text(
              widget.title,
              style: AdminTypography.headlineLarge,
            ),

            const Spacer(),

            // Actions personnalisées
            if (widget.actions != null) ...widget.actions!,

            // Sur mobile, quand on a "retour", on offre aussi un accès au menu (drawer)
            if (MediaQuery.of(context).size.width < 1024 &&
                Navigator.of(context).canPop())
              IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'Menu',
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),

            // Recherche globale
            if (MediaQuery.of(context).size.width >= 1000) ...[
              Container(
                width: 280,
                height: 36,
                margin: const EdgeInsets.only(left: AdminTokens.space16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    hintStyle: AdminTypography.bodySmall.copyWith(
                      color: AdminTokens.neutral400,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: AdminTokens.iconSm,
                      color: AdminTokens.neutral400,
                    ),
                    filled: true,
                    fillColor: AdminTokens.neutral50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AdminTokens.space12,
                      vertical: AdminTokens.space8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AdminTokens.radius8),
                      borderSide: const BorderSide(
                        color: AdminTokens.neutral300,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AdminTokens.radius8),
                      borderSide: const BorderSide(
                        color: AdminTokens.neutral300,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AdminTokens.radius8),
                      borderSide: const BorderSide(
                        color: AdminTokens.primary500,
                        width: 2,
                      ),
                    ),
                  ),
                  style: AdminTypography.bodySmall,
                ),
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // TODO: Ouvrir modal de recherche
                },
              ),
            ],
          ],
        ),
      ),
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

  String _getRestaurantId() => widget.restaurantId ?? 'newtest';

  void _onNavItemTap(String route) {
    setState(() => _selectedRoute = route);

    // Fermer le drawer sur mobile
    if (MediaQuery.of(context).size.width < 1024) {
      Navigator.of(context).pop();
    }

    final rid = widget.restaurantId ?? _getRestaurantId();

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
      case '/media':
        screen = AdminMediaScreen(restaurantId: rid);
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

  const AdminNavItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
