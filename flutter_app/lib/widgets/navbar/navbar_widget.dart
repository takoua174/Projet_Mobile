import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';

/// Navbar Widget - Top navigation bar with menu items and logout
/// 
/// Migrated from Angular NavbarComponent
/// Features:
/// - Responsive design (mobile menu toggle)
/// - Scroll-based background color change
/// - Active route highlighting
/// - Logout button with icon
/// 
/// Dependencies:
/// - SearchBarWidget (MISSING - child component)
class NavbarWidget extends ConsumerStatefulWidget {
  const NavbarWidget({super.key});

  @override
  ConsumerState<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends ConsumerState<NavbarWidget> {
  bool _isScrolled = false;
  bool _isMenuOpen = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrolled = _scrollController.hasClients && _scrollController.offset > 50;
    if (scrolled != _isScrolled) {
      setState(() {
        _isScrolled = scrolled;
      });
    }
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _closeMenu() {
    setState(() {
      _isMenuOpen = false;
    });
  }

  void _handleLogout() {
    ref.read(authServiceProvider).logout();
    _closeMenu();
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: (_isScrolled || _isMenuOpen) 
            ? Colors.black 
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 992; // lg breakpoint

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Brand Logo
                _buildBrandLogo(context),
                
                if (isMobile) ...[
                  const Spacer(),
                  _buildMobileMenuButton(),
                ] else ...[
                  const SizedBox(width: 40),
                  // Desktop Navigation
                  Expanded(
                    child: Row(
                      children: [
                        _buildNavItems(currentRoute, false),
                        const Spacer(),
                        _buildSearchBar(),
                        const SizedBox(width: 16),
                        _buildLogoutButton(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build brand logo
  Widget _buildBrandLogo(BuildContext context) {
    return InkWell(
      onTap: () {
        _closeMenu();
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      },
      child: const Text(
        'SAHBIFLIX',
        style: TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Build navigation items
  Widget _buildNavItems(String currentRoute, bool isMobile) {
    final navItems = [
      ('Home', AppRoutes.home),
      ('TV Shows', AppRoutes.tv),
      ('Movies', AppRoutes.movie),
      ('Search', AppRoutes.search),
      ('Profile', AppRoutes.profile),
    ];

    return Row(
      mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
      children: navItems.map((item) {
        final (label, route) = item;
        final isActive = currentRoute == route;

        return _NavItem(
          label: label,
          isActive: isActive,
          onTap: () {
            _closeMenu();
            Navigator.of(context).pushReplacementNamed(route);
          },
        );
      }).toList(),
    );
  }

  /// Build mobile menu button
  Widget _buildMobileMenuButton() {
    return IconButton(
      icon: Icon(
        _isMenuOpen ? Icons.close : Icons.menu,
        color: Colors.white,
        size: 28,
      ),
      onPressed: _toggleMenu,
    );
  }

  /// Build search bar (placeholder)
  Widget _buildSearchBar() {
    // TODO: Replace with SearchBarWidget when converted
    return Container(
      width: 200,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'Search...',
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ),
    );
  }

  /// Build logout button
  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _handleLogout,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFDC2626).withOpacity(0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.logout,
          color: Color(0xFFDC2626),
          size: 20,
        ),
      ),
    );
  }
}

/// Navigation Item Widget
class _NavItem extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color textColor;
    if (widget.isActive) {
      textColor = Colors.white;
    } else if (_isHovered) {
      textColor = const Color(0xFFE5E5E5);
    } else {
      textColor = const Color(0xFFB3B3B3);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.isActive ? null : widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile Menu Overlay
class _MobileMenuOverlay extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final Widget child;

  const _MobileMenuOverlay({
    required this.isOpen,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOpen) return const SizedBox.shrink();

    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black,
        child: child,
      ),
    );
  }
}
