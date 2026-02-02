import 'package:flutter/material.dart';
import '../../models/tmdb_models.dart';
import '../../pages/genre/genre_content_page.dart';

/// GenreCell Widget - Individual genre item with hover effect
/// 
/// Migrated from Angular GenreCellComponent
/// Features:
/// - Click to navigate to genre content page
/// - Hover effects (scale + color change)
/// - Passes genre ID and name to detail route
class GenreCellWidget extends StatefulWidget {
  final Genre genre;
  final String contentType;

  const GenreCellWidget({
    super.key,
    required this.genre,
    required this.contentType,
  });

  @override
  State<GenreCellWidget> createState() => _GenreCellWidgetState();
}

class _GenreCellWidgetState extends State<GenreCellWidget> {
  bool _isHovered = false;

  void _handleClick(BuildContext context) {
    // Navigate to genre content page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GenreContentPage(
          contentType: widget.contentType,
          genreId: widget.genre.id.toString(),
          genreName: widget.genre.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => _handleClick(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            border: Border.all(
              color: _isHovered
                  ? Colors.white
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              widget.genre.name,
              style: TextStyle(
                color: _isHovered ? Colors.white : const Color(0xFFE5E5E5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
