import 'package:flutter/material.dart';
import '../../models/tmdb_models.dart';
import '../../config/environment.dart';

/// ContentCardWidget - Individual content card for horizontal rows
/// 
/// Features:
/// - Poster image with hover effect
/// - Scale animation on hover
/// - Navigation to detail page
class ContentCardWidget extends StatefulWidget {
  final dynamic item; // MovieDetails or TVShowDetails
  final String contentType; // 'movie' or 'tv'
  final double width;

  const ContentCardWidget({
    super.key,
    required this.item,
    required this.contentType,
    required this.width,
  });

  @override
  State<ContentCardWidget> createState() => _ContentCardWidgetState();
}

class _ContentCardWidgetState extends State<ContentCardWidget> {
  bool _isHovered = false;

  String get _posterUrl {
    final posterPath = widget.item.posterPath;
    if (posterPath == null || posterPath.isEmpty) {
      return '';
    }
    return '${AppConfig.tmdbImageBaseUrl}/w500$posterPath';
  }

  String get _title {
    if (widget.contentType == 'movie') {
      return (widget.item as MovieDetails).title ?? 'Unknown Title';
    } else {
      return (widget.item as TVShowDetails).name ?? 'Unknown Title';
    }
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
    final height = widget.width * 1.5;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _navigateToDetail,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: widget.width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _posterUrl.isNotEmpty
                  ? Image.network(
                      _posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_outlined,
              color: Color(0xFF666666),
              size: 48,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _title,
                style: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
