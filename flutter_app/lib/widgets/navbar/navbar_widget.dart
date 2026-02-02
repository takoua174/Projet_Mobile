import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'dart:convert';
import '../../providers/auth_provider.dart';

/// Navbar Widget - Top navigation bar with menu items and logout
/// 
/// Migrated from Angular NavbarComponent
/// Features:
/// - Responsive design (mobile menu toggle)
/// - Scroll-based background color change
/// - Active route highlighting
/// - Logout button with icon
class NavbarWidget extends riverpod.ConsumerStatefulWidget {
  const NavbarWidget({super.key});

  @override
  riverpod.ConsumerState<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends riverpod.ConsumerState<NavbarWidget> {
  bool _isScrolled = false;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Listen to scroll events from the nearest scrollable
    });
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
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _navigateTo(String route) {
    _closeMenu();
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: (_isScrolled || _isMenuOpen) 
                ? Colors.black 
                : const Color(0xFF141414),
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
                      const SizedBox(width: 12),
                      _buildProfileAvatar(),
                    ] else ...[
                      const SizedBox(width: 40),
                      // Desktop Navigation
                      Expanded(
                        child: Row(
                          children: [
                            _buildNavItems(currentRoute, false),
                            const Spacer(),
                            _buildProfileAvatar(),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        // Mobile Menu Overlay
        if (_isMenuOpen)
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMobileNavItems(currentRoute),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildLogoutButton(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
      ],
    );
  }

  /// Build brand logo
  Widget _buildBrandLogo(BuildContext context) {
    return InkWell(
      onTap: () => _navigateTo('/home'),
      child: const Text(
        'SAHBIFLIX',
        style: TextStyle(
          color: Color(0xFFDC2626),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Build navigation items
  Widget _buildNavItems(String currentRoute, bool isMobile) {
    final navItems = [
      ('Home', '/home'),
      ('TV Shows', '/tv'),
      ('Movies', '/movie'),
      ('Profile', '/profile'),
    ];

    return Row(
      mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
      children: navItems.map((item) {
        final (label, route) = item;
        final isActive = currentRoute == route;

        return _NavItem(
          label: label,
          isActive: isActive,
          onTap: () => _navigateTo(route),
        );
      }).toList(),
    );
  }

  /// Build mobile navigation items (vertical list)
  Widget _buildMobileNavItems(String currentRoute) {
    final navItems = [
      ('Home', '/home'),
      ('TV Shows', '/tv'),
      ('Movies', '/movie'),
      ('Profile', '/profile'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: navItems.map((item) {
        final (label, route) = item;
        final isActive = currentRoute == route;

        return InkWell(
          onTap: () => _navigateTo(route),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            color: isActive ? Colors.white.withOpacity(0.1) : null,
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFFB3B3B3),
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
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

  /// Build profile avatar
  Widget _buildProfileAvatar() {
    final currentUser = ref.watch(currentUserProvider);
    
    ImageProvider? backgroundImage;
    if (currentUser?.profilePicture != null) {
      final profilePic = currentUser!.profilePicture!;
      if (profilePic.startsWith('data:image')) {
        // Base64 image
        try {
          final base64String = profilePic.split(',')[1];
          final bytes = base64Decode(base64String);
          backgroundImage = MemoryImage(bytes);
        } catch (e) {
          // If decoding fails, use default
          backgroundImage = null;
        }
      } else if (profilePic.startsWith('http')) {
        // Network URL
        backgroundImage = NetworkImage(profilePic);
      }
    }
    
    return InkWell(
      onTap: () => _navigateTo('/profile'),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFDC2626),
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFFDC2626),
          backgroundImage: backgroundImage,
          child: backgroundImage == null
              ? const Icon(
                  Icons.person,
                  size: 18,
                  color: Colors.white,
                )
              : null,
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
        padding: const EdgeInsets.all(10),
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
