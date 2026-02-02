import 'package:flutter/material.dart';
import '../../models/tmdb_models.dart';

/// MediaGridWidget - Displays a responsive grid of media content
/// 
/// Migrated from Angular MediaRowComponent
/// Features:
/// - Responsive grid layout
/// - Adjusts columns based on screen size
/// - Movie/TV show cards with posters
/// - Click navigation to detail pages
class MediaGridWidget extends StatelessWidget {
  final List<dynamic> items; // List of MovieDetails or TVShowDetails
  final String contentType; // 'movie' or 'tv'

  const MediaGridWidget({
    super.key,
    required this.items,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine number of columns based on screen width
        int crossAxisCount;
        if (constraints.maxWidth >= 1400) {
          crossAxisCount = 6;
        } else if (constraints.maxWidth >= 1200) {
          crossAxisCount = 5;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.65, // Poster ratio
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildMediaCard(context, item);
          },
        );
      },
    );
  }

  Widget _buildMediaCard(BuildContext context, dynamic item) {
    // Extract common properties
    final id = item.id as int;
    final title = _getTitle(item);
    final posterPath = _getPosterPath(item);
    final voteAverage = _getVoteAverage(item);
    final releaseDate = _getReleaseDate(item);

    return InkWell(
      onTap: () => _navigateToDetail(context, id),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster Image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                ),
                child: posterPath != null
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w500$posterPath',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      )
                    : _buildPlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          // Rating and Date
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Color(0xFFFFD700),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                voteAverage.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              if (releaseDate != null) ...[
                const SizedBox(width: 8),
                Text(
                  '• ${_formatYear(releaseDate)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.white.withOpacity(0.05),
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          size: 48,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  String _getTitle(dynamic item) {
    // For MovieDetails
    if (item is MovieDetails) {
      return item.title ?? 'Untitled';
    }
    // For TVShowDetails
    if (item is TVShowDetails) {
      return item.name ?? 'Untitled';
    }
    // Fallback to dynamic access
    try {
      if (item.title != null) return item.title as String;
    } catch (e) {}
    try {
      if (item.name != null) return item.name as String;
    } catch (e) {}
    return 'Untitled';
  }

  String? _getPosterPath(dynamic item) {
    try {
      return item.posterPath as String?;
    } catch (e) {
      return null;
    }
  }

  double _getVoteAverage(dynamic item) {
    try {
      final vote = item.voteAverage;
      if (vote is int) return vote.toDouble();
      if (vote is double) return vote;
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  String? _getReleaseDate(dynamic item) {
    try {
      if (item.releaseDate != null) return item.releaseDate as String;
      if (item.firstAirDate != null) return item.firstAirDate as String;
      return null;
    } catch (e) {
      return null;
    }
  }

  String _formatYear(String date) {
    try {
      return date.split('-')[0];
    } catch (e) {
      return date;
    }
  }

  void _navigateToDetail(BuildContext context, int id) {
    // Navigate to movie or TV detail page
    final route = contentType == 'movie' ? '/movie/$id' : '/tv/$id';
    Navigator.of(context).pushNamed(route);
  }
}
