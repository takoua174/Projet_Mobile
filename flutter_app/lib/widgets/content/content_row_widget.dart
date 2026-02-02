import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import '../../models/tmdb_models.dart';
import '../../services/tmdb_service.dart';
import '../../providers/tmdb_provider.dart';
import 'content_card_widget.dart';

/// ContentRowWidget - Horizontal scrollable row of content
/// 
/// Migrated from Angular ContentRowComponent
/// Features:
/// - Horizontal scrolling with pagination
/// - Detects scroll to end and loads more
/// - Supports different fetch types (trending, topRated, genre)
/// - Responsive card sizing
class ContentRowWidget extends riverpod.ConsumerStatefulWidget {
  final String title;
  final String fetchType; // 'trending', 'topRated', 'genre'
  final String contentType; // 'movie' or 'tv'
  final String? genreId;

  const ContentRowWidget({
    super.key,
    required this.title,
    required this.fetchType,
    required this.contentType,
    this.genreId,
  });

  @override
  riverpod.ConsumerState<ContentRowWidget> createState() => _ContentRowWidgetState();
}

class _ContentRowWidgetState extends riverpod.ConsumerState<ContentRowWidget> {
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _items = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tmdbService = ref.read(tmdbServiceProvider);
      final results = await _fetchData(tmdbService, 1);

      if (mounted) {
        setState(() {
          _items.addAll(results);
          _currentPage = 1;
          _isLoading = false;
          _hasMore = results.isNotEmpty;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tmdbService = ref.read(tmdbServiceProvider);
      final nextPage = _currentPage + 1;
      final results = await _fetchData(tmdbService, nextPage);

      if (mounted) {
        setState(() {
          if (results.isNotEmpty) {
            _items.addAll(results);
            _currentPage = nextPage;
          } else {
            _hasMore = false;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<List<dynamic>> _fetchData(TmdbService service, int page) async {
    switch (widget.fetchType) {
      case 'trending':
        if (widget.contentType == 'movie') {
          return await service.getTrendingMovies('week', page: page);
        } else {
          return await service.getTrendingTVShows('week', page: page);
        }

      case 'topRated':
        if (widget.contentType == 'movie') {
          return await service.getTopRatedMovies(page: page);
        } else {
          return await service.getTopRatedTVShows(page: page);
        }

      case 'genre':
        if (widget.genreId == null) return [];
        if (widget.contentType == 'movie') {
          final response = await service.discoverMovies(
            genres: widget.genreId!,
            page: page,
          );
          final results = response['results'] as List;
          return results.map((e) => MovieDetails.fromJson(e)).toList();
        } else {
          final response = await service.discoverTVShows(
            genres: widget.genreId!,
            page: page,
          );
          final results = response['results'] as List;
          return results.map((e) => TVShowDetails.fromJson(e)).toList();
        }

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && !_isLoading) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 768
        ? 140.0
        : screenWidth < 1200
            ? 180.0
            : 220.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: EdgeInsets.only(
            left: screenWidth < 768 ? 16 : 40,
            right: screenWidth < 768 ? 16 : 40,
            bottom: 12,
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth < 768 ? 18 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Horizontal Scrollable Content
        SizedBox(
          height: cardWidth * 1.8, // Maintain aspect ratio
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 768 ? 16 : 40,
            ),
            itemCount: _items.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _items.length) {
                return _buildLoader(cardWidth);
              }

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ContentCardWidget(
                  item: _items[index],
                  contentType: widget.contentType,
                  width: cardWidth,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLoader(double cardWidth) {
    return Container(
      width: cardWidth,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
      ),
    );
  }
}
