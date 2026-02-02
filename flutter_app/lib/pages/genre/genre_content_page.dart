import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import '../../models/tmdb_models.dart';
import '../../widgets/navbar/navbar_widget.dart';
import '../../widgets/media/media_grid_widget.dart';
import '../../services/tmdb_service.dart';
import '../../providers/tmdb_provider.dart';

/// GenreContentPage - Displays movies or TV shows filtered by genre
/// 
/// Migrated from Angular GenreContentComponent
/// Features:
/// - Infinite scroll pagination
/// - Loading states with spinner
/// - Empty state handling
/// - "Load More" button
/// - Genre-based content filtering
class GenreContentPage extends riverpod.ConsumerStatefulWidget {
  final String contentType; // 'movie' or 'tv'
  final String genreId;
  final String genreName;

  const GenreContentPage({
    super.key,
    required this.contentType,
    required this.genreId,
    required this.genreName,
  });

  @override
  riverpod.ConsumerState<GenreContentPage> createState() => _GenreContentPageState();
}

class _GenreContentPageState extends riverpod.ConsumerState<GenreContentPage> 
    with SingleTickerProviderStateMixin {
  
  List<dynamic> _items = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _loadInitialContent();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialContent() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // Simulate minimum loading time for better UX
    await Future.delayed(const Duration(seconds: 2));

    await _fetchContent(1);
    
    if (!_hasError) {
      _fadeController.forward();
    }
  }

  Future<void> _fetchContent(int page) async {
    try {
      final tmdbService = ref.read(tmdbServiceProvider);

      if (widget.contentType == 'movie') {
        final response = await tmdbService.discoverMovies(genres: widget.genreId, page: page);
        final results = response['results'] as List;
        final movies = results.map((e) => MovieDetails.fromJson(e)).toList();
        setState(() {
          if (page == 1) {
            _items = movies;
          } else {
            _items.addAll(movies);
          }
          _currentPage = page;
          // Estimate total pages (TMDB typically has 500 max)
          _totalPages = movies.isEmpty ? page : page + 10;
          _isLoading = false;
          _isLoadingMore = false;
          _hasError = false;
        });
      } else {
        final response = await tmdbService.discoverTVShows(genres: widget.genreId, page: page);
        final results = response['results'] as List;
        final tvShows = results.map((e) => TVShowDetails.fromJson(e)).toList();
        setState(() {
          if (page == 1) {
            _items = tvShows;
          } else {
            _items.addAll(tvShows);
          }
          _currentPage = page;
          _totalPages = tvShows.isEmpty ? page : page + 10;
          _isLoading = false;
          _isLoadingMore = false;
          _hasError = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _fetchContent(_currentPage + 1);
  }

  @override
  Widget build(BuildContext context) {
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
    if (_isLoading) {
      return _buildLoader();
    }

    if (_hasError) {
      return _buildError();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width < 768 ? 20 : 60,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildMediaGrid(),
            if (_items.isEmpty) _buildEmptyState(),
            if (_currentPage < _totalPages && _items.isNotEmpty) _buildLoadMoreButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 16),
      child: Text(
        widget.genreName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
    if (_items.isEmpty) return const SizedBox.shrink();

    return MediaGridWidget(
      items: _items,
      contentType: widget.contentType,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              Icons.movie_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No content available for this genre.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator(
                color: Color(0xFFDC2626),
              )
            : ElevatedButton(
                onPressed: _loadMore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF141414),
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: const Color(0xFF6D6D6E).withOpacity(0.38),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'Load More Content',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
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
              // Restart animation
              setState(() {});
            },
            child: const Text(
              'Loading content...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load content',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadInitialContent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
