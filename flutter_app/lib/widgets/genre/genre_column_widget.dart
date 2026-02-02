import 'package:flutter/material.dart';
import '../../models/tmdb_models.dart';
import '../../config/routes.dart';
import 'genre_cell_widget.dart';

/// GenreColumn Widget - Displays a column of genre items
/// 
/// Migrated from Angular GenreColumnComponent
/// Features:
/// - Clickable title that navigates to content page (Movie or TV)
/// - Subtitle showing "Available genres"
/// - List of genre cells with scroll support
/// - Hover effect on title
class GenreColumnWidget extends StatefulWidget {
  final String title;
  final List<Genre> genres;
  final String contentType;

  const GenreColumnWidget({
    super.key,
    required this.title,
    required this.genres,
    required this.contentType,
  });

  @override
  State<GenreColumnWidget> createState() => _GenreColumnWidgetState();
}

class _GenreColumnWidgetState extends State<GenreColumnWidget> {
  bool _isTitleHovered = false;

  void _handleTitleClick(BuildContext context) {
    // Navigate to movie or TV page based on content type
    if (widget.contentType == 'movie') {
      Navigator.of(context).pushNamed(AppRoutes.movie);
    } else if (widget.contentType == 'tv') {
      Navigator.of(context).pushNamed(AppRoutes.tv);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title - Clickable with hover effect
        Padding(
          padding: const EdgeInsets.only(left: 40, bottom: 20),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isTitleHovered = true),
            onExit: (_) => setState(() => _isTitleHovered = false),
            child: GestureDetector(
              onTap: () => _handleTitleClick(context),
              child: Text(
                widget.title.toUpperCase(),
                style: TextStyle(
                  color: _isTitleHovered
                      ? const Color(0xFF760000)
                      : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),

        // Subtitle
        Padding(
          padding: const EdgeInsets.only(left: 50, bottom: 20),
          child: Text(
            'Available genres :',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),

        // Genres List - Scrollable
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: widget.genres.isEmpty
                ? Center(
                    child: Text(
                      'No genres available',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: widget.genres.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final genre = widget.genres[index];
                      return GenreCellWidget(
                        genre: genre,
                        contentType: widget.contentType,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
