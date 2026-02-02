import 'package:flutter/material.dart';
import '../../models/tmdb_models.dart';
import '../../config/environment.dart';

/// HeroBannerWidget - Large hero banner with backdrop image
/// 
/// Migrated from Angular HeroBannerComponent
/// Features:
/// - Full-width backdrop image with gradient overlay
/// - Title, release date, overview
/// - "More Info" button navigation
/// - Responsive height based on screen size
class HeroBannerWidget extends StatefulWidget {
  final dynamic item; // MovieDetails or TVShowDetails
  final String contentType; // 'movie' or 'tv'

  const HeroBannerWidget({
    super.key,
    required this.item,
    required this.contentType,
  });

  @override
  State<HeroBannerWidget> createState() => _HeroBannerWidgetState();
}

class _HeroBannerWidgetState extends State<HeroBannerWidget> {
  bool _isHovered = false;

  String get _backdropUrl {
    final backdropPath = widget.item.backdropPath ?? widget.item.posterPath;
    if (backdropPath == null || backdropPath.isEmpty) {
      return '';
    }
    return '${AppConfig.tmdbImageBaseUrl}/original$backdropPath';
  }

  String get _title {
    if (widget.contentType == 'movie') {
      return (widget.item as MovieDetails).title ?? 'Unknown Title';
    } else {
      return (widget.item as TVShowDetails).name ?? 'Unknown Title';
    }
  }

  String get _releaseDate {
    String? date;
    if (widget.contentType == 'movie') {
      date = (widget.item as MovieDetails).releaseDate;
    } else {
      date = (widget.item as TVShowDetails).firstAirDate;
    }
    
    if (date == null || date.isEmpty) return '';
    
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.year}';
    } catch (e) {
      return '';
    }
  }

  String get _overview {
    return widget.item.overview ?? '';
  }

  void _navigateToDetail() {
    final id = widget.item.id;
    if (id == null) return;

    Navigator.pushNamed(
      context,
      widget.contentType == 'movie' ? '/movie/$id' : '/tv/$id',
      arguments: {'id': id, 'type': widget.contentType},
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerHeight = screenWidth < 768 
        ? 400.0 
        : screenWidth < 1200 
            ? 500.0 
            : 600.0;

    return Container(
      width: double.infinity,
      height: bannerHeight,
      decoration: BoxDecoration(
        image: _backdropUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(_backdropUrl),
                fit: BoxFit.cover,
              )
            : null,
        color: _backdropUrl.isEmpty ? const Color(0xFF2A2A2A) : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.3),
              const Color(0xFF141414),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: _buildContent(screenWidth),
      ),
    );
  }

  Widget _buildContent(double screenWidth) {
    final isMobile = screenWidth < 768;
    final padding = isMobile ? 20.0 : screenWidth < 1200 ? 40.0 : 60.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            _title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 28 : screenWidth < 1200 ? 40 : 56,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: const Offset(2, 2),
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.8),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          if (_releaseDate.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _releaseDate,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: isMobile ? 16 : 20,
                shadows: [
                  Shadow(
                    offset: const Offset(1, 1),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ],

          if (_overview.isNotEmpty) ...[
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 600,
              ),
              child: Text(
                _overview,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isMobile ? 14 : 16,
                  height: 1.5,
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ],
                ),
                maxLines: isMobile ? 3 : 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // More Info Button
          MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: _navigateToDetail,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 32,
                  vertical: isMobile ? 12 : 16,
                ),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? const Color(0xFF760000)
                      : const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'More Info',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
