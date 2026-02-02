import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import '../../models/tmdb_models.dart';
import '../../widgets/navbar/navbar_widget.dart';
import '../../widgets/hero/hero_banner_widget.dart';
import '../../widgets/content/content_row_widget.dart';
import '../../providers/tmdb_provider.dart';

/// TVPage - Browse TV shows with hero banner and content rows
/// 
/// Migrated from Angular TvShowComponent
/// Features:
/// - Random hero banner from trending TV shows
/// - Multiple content rows (Trending, Top Rated, Genres)
/// - Horizontal scrolling rows
/// - Loading state with spinner
class TVPage extends riverpod.ConsumerStatefulWidget {
  const TVPage({super.key});

  @override
  riverpod.ConsumerState<TVPage> createState() => _TVPageState();
}

class _TVPageState extends riverpod.ConsumerState<TVPage> {
  TVShowDetails? _bannerTVShow;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBannerTVShow();
  }

  Future<void> _loadBannerTVShow() async {
    try {
      final tmdbService = ref.read(tmdbServiceProvider);
      
      // Wait at least 1 second for better UX
      final results = await Future.wait([
        tmdbService.getTrendingTVShows('week'),
        Future.delayed(const Duration(seconds: 1)),
      ]);

      final tvShows = results[0] as List<TVShowDetails>;
      
      if (tvShows.isNotEmpty) {
        // Pick random TV show
        final randomIndex = DateTime.now().millisecondsSinceEpoch % tvShows.length;
        setState(() {
          _bannerTVShow = tvShows[randomIndex];
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
    if (_isLoading || _bannerTVShow == null) {
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
            item: _bannerTVShow!,
            contentType: 'tv',
          ),

          // Content Rows
          const SizedBox(height: 20),
          
          const ContentRowWidget(
            title: 'Trending TV Shows',
            fetchType: 'trending',
            contentType: 'tv',
          ),

          const ContentRowWidget(
            title: 'Top Rated TV Shows',
            fetchType: 'topRated',
            contentType: 'tv',
          ),

          const ContentRowWidget(
            title: 'Action & Adventure',
            fetchType: 'genre',
            contentType: 'tv',
            genreId: '10759', // Action & Adventure
          ),

          const ContentRowWidget(
            title: 'Comedy',
            fetchType: 'genre',
            contentType: 'tv',
            genreId: '35', // Comedy
          ),

          const ContentRowWidget(
            title: 'Sci-Fi & Fantasy',
            fetchType: 'genre',
            contentType: 'tv',
            genreId: '10765', // Sci-Fi & Fantasy
          ),

          const ContentRowWidget(
            title: 'Documentaries',
            fetchType: 'genre',
            contentType: 'tv',
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
                'Loading TV Shows...',
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
