import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import '../../models/tmdb_models.dart';
import '../../widgets/navbar/navbar_widget.dart';
import '../../widgets/hero/hero_banner_widget.dart';
import '../../widgets/content/content_row_widget.dart';
import '../../services/tmdb_service.dart';
import '../../providers/tmdb_provider.dart';

/// MoviePage - Browse movies with hero banner and content rows
/// 
/// Migrated from Angular MovieComponent
/// Features:
/// - Random hero banner from trending movies
/// - Multiple content rows (Trending, Top Rated, Genres)
/// - Horizontal scrolling rows
/// - Loading state with spinner
class MoviePage extends riverpod.ConsumerStatefulWidget {
  const MoviePage({super.key});

  @override
  riverpod.ConsumerState<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends riverpod.ConsumerState<MoviePage> {
  MovieDetails? _bannerMovie;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBannerMovie();
  }

  Future<void> _loadBannerMovie() async {
    try {
      final tmdbService = ref.read(tmdbServiceProvider);
      
      // Wait at least 1 second for better UX
      final results = await Future.wait([
        tmdbService.getTrendingMovies('week'),
        Future.delayed(const Duration(seconds: 1)),
      ]);

      final movies = results[0] as List<MovieDetails>;
      
      if (movies.isNotEmpty) {
        // Pick random movie
        final randomIndex = DateTime.now().millisecondsSinceEpoch % movies.length;
        setState(() {
          _bannerMovie = movies[randomIndex];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _bannerMovie == null) {
      return _buildLoader();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: Column(
        children: [
          const NavbarWidget(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Banner
          HeroBannerWidget(
            item: _bannerMovie!,
            contentType: 'movie',
          ),

          // Content Rows
          const SizedBox(height: 20),
          
          const ContentRowWidget(
            title: 'Trending Now',
            fetchType: 'trending',
            contentType: 'movie',
          ),

          const ContentRowWidget(
            title: 'Top Rated',
            fetchType: 'topRated',
            contentType: 'movie',
          ),

          const ContentRowWidget(
            title: 'Action Thrillers',
            fetchType: 'genre',
            contentType: 'movie',
            genreId: '28', // Action
          ),

          const ContentRowWidget(
            title: 'Comedy contents',
            fetchType: 'genre',
            contentType: 'movie',
            genreId: '35', // Comedy
          ),

          const ContentRowWidget(
            title: 'Horror contents',
            fetchType: 'genre',
            contentType: 'movie',
            genreId: '27', // Horror
          ),

          const ContentRowWidget(
            title: 'Romance contents',
            fetchType: 'genre',
            contentType: 'movie',
            genreId: '10749', // Romance
          ),

          const ContentRowWidget(
            title: 'Documentaries',
            fetchType: 'genre',
            contentType: 'movie',
            genreId: '99', // Documentary
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              onEnd: () {
                if (mounted) setState(() {});
              },
              child: const Text(
                'Loading Movies...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
