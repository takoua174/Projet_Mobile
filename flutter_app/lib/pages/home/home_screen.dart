import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/auth_model.dart';
import '../../models/tmdb_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tmdb_provider.dart';
import '../../config/routes.dart';
import '../../widgets/navbar/navbar_widget.dart';
import '../../widgets/genre/genre_column_widget.dart';

/// HomeScreen - Main landing page displaying movie and TV show genres
/// 
/// Migrated from Angular HomeComponent
/// Dependencies:
/// - NavbarWidget ✅ CONVERTED
/// - GenreColumnWidget ✅ CONVERTED
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch genres
    final movieGenresAsync = ref.watch(movieGenresProvider);
    final tvGenresAsync = ref.watch(tvGenresProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: Column(
        children: [
          // Navbar - Converted from Angular
          const NavbarWidget(),
          
          Expanded(
            child: _buildHomeContent(
              context,
              movieGenresAsync,
              tvGenresAsync,
            ),
          ),
        ],
      ),
    );
  }

  /// Main content area with responsive layout
  Widget _buildHomeContent(
    BuildContext context,
    AsyncValue<List<Genre>> movieGenresAsync,
    AsyncValue<List<Genre>> tvGenresAsync,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive: Column for mobile, Row for desktop
        final isMobile = constraints.maxWidth < 768;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: isMobile
                ? _buildMobileLayout(movieGenresAsync, tvGenresAsync)
                : _buildDesktopLayout(movieGenresAsync, tvGenresAsync),
          ),
        );
      },
    );
  }

  /// Desktop layout (side-by-side columns)
  Widget _buildDesktopLayout(
    AsyncValue<List<Genre>> movieGenresAsync,
    AsyncValue<List<Genre>> tvGenresAsync,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: _buildGenreColumnContent('movie', movieGenresAsync),
            ),
          ),
          Expanded(
            child: _buildGenreColumnContent('tv', tvGenresAsync),
          ),
        ],
      ),
    );
  }

  /// Mobile layout (stacked columns)
  Widget _buildMobileLayout(
    AsyncValue<List<Genre>> movieGenresAsync,
    AsyncValue<List<Genre>> tvGenresAsync,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: _buildGenreColumnContent('movie', movieGenresAsync),
        ),
        Container(
          height: 1,
          color: Colors.white.withOpacity(0.1),
        ),
        SizedBox(
          height: 400,
          child: _buildGenreColumnContent('tv', tvGenresAsync),
        ),
      ],
    );
  }

  /// Genre column content with loading/error states
  Widget _buildGenreColumnContent(
    String contentType,
    AsyncValue<List<Genre>> genresAsync,
  ) {
    return genresAsync.when(
      data: (genres) {
        return GenreColumnWidget(
          title: contentType,
          genres: genres,
          contentType: contentType,
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: Colors.red),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Error loading genres: $error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Handle logout action
  void _handleLogout(WidgetRef ref, BuildContext context) {
    ref.read(authServiceProvider).logout();
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }
}