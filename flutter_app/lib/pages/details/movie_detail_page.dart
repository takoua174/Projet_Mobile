import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'dart:convert';
import '../../models/tmdb_models.dart';
import '../../services/tmdb_service.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/movie_detail_provider.dart';
import '../../config/environment.dart';
import '../../widgets/review/create_review_widget.dart';
import 'widgets/widgets.dart';

class MovieDetailPage extends StatelessWidget {
  final int id;

  const MovieDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    // Inject the provider locally for this page
    return ChangeNotifierProvider(
      create: (context) => MovieDetailProvider(
        Provider.of<TmdbService>(context, listen: false),
        Provider.of<ApiService>(context, listen: false),
      )..loadMovie(id),
      child: const _MovieDetailScaffold(),
    );
  }
}

class _MovieDetailScaffold extends riverpod.ConsumerWidget {
  const _MovieDetailScaffold();

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final provider = Provider.of<MovieDetailProvider>(context);
    final movie = provider.movie;
    final currentUser = ref.watch(currentUserProvider);

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(provider.error!)),
      );
    }

    if (movie == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, movie),
          SliverToBoxAdapter(child: _buildHeaderInfo(context, movie, ref)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                movie.overview,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          if (provider.cast.isNotEmpty) ...[
             const SliverToBoxAdapter(child: SectionHeader(title: "Cast")),
             SliverToBoxAdapter(child: CastListWidget(cast: provider.cast)),
          ],
          if (provider.videos.isNotEmpty) ...[
             const SliverToBoxAdapter(child: SectionHeader(title: "Videos")),
             SliverToBoxAdapter(child: VideoCarouselWidget(videos: provider.videos)),
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CreateReviewWidget(
                movieId: movie.id.toString(),
                movieTitle: movie.title,
                onReviewCreated: () {
                  // Reload only reviews after creating a new one
                  provider.loadReviews(movie.id);
                },
              ),
            ),
          ),
          if (provider.userReviews.isNotEmpty || provider.reviews.isNotEmpty) ...[
             const SliverToBoxAdapter(child: SectionHeader(title: "Reviews")),
             SliverList(
               delegate: SliverChildBuilderDelegate(
                 (context, index) {
                   if (index < provider.userReviews.length) {
                     // User reviews from local API
                     final review = provider.userReviews[index];
                     return _buildUserReviewCard(context, ref, review, currentUser, provider);
                   } else {
                     // TMDB reviews
                     final tmdbIndex = index - provider.userReviews.length;
                     final review = provider.reviews[tmdbIndex];
                     return _buildTmdbReviewCard(review);
                   }
                 },
                 childCount: provider.userReviews.length + provider.reviews.length,
               ),
             ),
          ],
          if (provider.similarMovies.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SectionHeader(title: "Similar Movies")),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 280,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.similarMovies.take(12).length,
                  itemBuilder: (context, index) {
                    final movie = provider.similarMovies[index];
                    return _buildSimilarMovieCard(context, movie);
                  },
                ),
              ),
            ),
          ],
           const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, MovieDetails movie) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          movie.title,
          style: const TextStyle(
            shadows: [Shadow(color: Colors.black, blurRadius: 10)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            movie.backdropPath != null
                ? CachedNetworkImage(
                    imageUrl:
                        '${AppConfig.tmdbImageBaseUrl}/original${movie.backdropPath}',
                    fit: BoxFit.cover,
                  )
                : Container(color: Colors.grey[800]),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, MovieDetails movie, riverpod.WidgetRef ref) {
    final authProvider = ref.watch(authChangeNotifierProvider);
    final isFavorite = authProvider.isFavoriteMovie(movie.id);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster slightly overlapping could be negative padding, but simpler is just here
              Hero(
                tag: 'movie_poster_${movie.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: movie.posterPath != null
                      ? CachedNetworkImage(
                          imageUrl:
                              '${AppConfig.tmdbImageBaseUrl}/w500${movie.posterPath}',
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 100,
                          height: 150,
                          color: Colors.grey,
                          child: const Icon(Icons.movie, size: 50),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    if (movie.tagline.isNotEmpty)
                      Text(
                        movie.tagline,
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    const SizedBox(height: 8),
                     Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        Text('${movie.runtime} min'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.releaseDate.isNotEmpty
                        ? DateFormat.yMMMd().format(DateTime.parse(movie.releaseDate))
                        : "Unknown Date",
                       style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Genres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: movie.genres.map((g) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(g.name),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Play"),
                  style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.red,
                     foregroundColor: Colors.white,
                  ),
                ),
              ),
               const SizedBox(width: 16),
               Expanded(
                 child: OutlinedButton.icon(
                   onPressed: authProvider.isAuthenticated
                       ? () async {
                           final success = await authProvider.toggleFavorite(
                             movie.id,
                             'movie',
                           );
                           if (context.mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: Text(
                                   success
                                       ? (isFavorite
                                           ? 'Removed from favorites'
                                           : 'Added to favorites')
                                       : 'Failed to update favorites',
                                 ),
                                 backgroundColor: success
                                     ? const Color(0xFF22c55e)
                                     : const Color(0xFFDC2626),
                                 behavior: SnackBarBehavior.floating,
                                 duration: const Duration(seconds: 2),
                               ),
                             );
                           }
                         }
                       : () {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(
                               content: Text('Please login to add favorites'),
                               backgroundColor: Color(0xFFDC2626),
                               behavior: SnackBarBehavior.floating,
                             ),
                           );
                         },
                   icon: Icon(
                     isFavorite ? Icons.favorite : Icons.favorite_border,
                   ),
                   label: Text(isFavorite ? "Favorited" : "Favorite"),
                   style: OutlinedButton.styleFrom(
                     foregroundColor: Colors.red,
                     side: const BorderSide(color: Colors.red),
                   ),
                 ),
               ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserReviewCard(
    BuildContext context,
    riverpod.WidgetRef ref,
    dynamic review,
    dynamic currentUser,
    MovieDetailProvider provider,
  ) {
    final isOwnReview = currentUser != null && 
                        review['author'] == currentUser.username;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileAvatar(
                  review['author_details']?['profile_image'],
                  review['author'],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              review['author'] ?? 'Anonymous',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'User Review',
                              style: TextStyle(
                                color: Color(0xFF667eea),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        review['created_at'] != null
                            ? _formatDate(review['created_at'])
                            : '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (review['author_details']?['rating'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFffd700).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '★ ${review['author_details']['rating']}/10',
                      style: const TextStyle(
                        color: Color(0xFFffd700),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (isOwnReview) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: const Color(0xFFDC2626),
                    onPressed: () => _deleteReview(context, ref, review, provider),
                    tooltip: 'Delete review',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            _ExpandableText(
              text: review['content'] ?? '',
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteReview(
    BuildContext context,
    riverpod.WidgetRef ref,
    dynamic review,
    MovieDetailProvider provider,
  ) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text(
          'Delete Review',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this review?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.deleteReview(review['id']);
      
      // Reload reviews
      if (provider.movie != null) {
        await provider.loadReviews(provider.movie!.id);
      }

      // Show success snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Review deleted successfully'),
              ],
            ),
            backgroundColor: const Color(0xFF22c55e),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Show error snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Failed to delete review: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Widget _buildTmdbReviewCard(Review review) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[800],
                  child: Text(
                    review.author[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.author,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'TMDB',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(review.createdAt),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ExpandableText(
              text: review.content,
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String? profileImage, String? author) {
    // Handle base64 images
    if (profileImage != null && profileImage.isNotEmpty) {
      if (profileImage.startsWith('data:image')) {
        try {
          final base64String = profileImage.split(',')[1];
          final bytes = base64Decode(base64String);
          return CircleAvatar(
            radius: 20,
            backgroundImage: MemoryImage(bytes),
            backgroundColor: const Color(0xFFDC2626),
          );
        } catch (e) {
          // Fall through to default avatar
        }
      } else if (profileImage.startsWith('http')) {
        return CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(profileImage),
          backgroundColor: const Color(0xFFDC2626),
        );
      }
    }
    
    // Default avatar with first letter
    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFDC2626),
      child: Text(
        author?[0].toUpperCase() ?? 'U',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat.yMMMd().format(date);
    } catch (e) {
      return dateString; // Return as-is if parsing fails
    }
  }

  Widget _buildSimilarMovieCard(BuildContext context, MovieDetails movie) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailPage(id: movie.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: movie.posterPath != null
                  ? CachedNetworkImage(
                      imageUrl: '${AppConfig.tmdbImageBaseUrl}/w300${movie.posterPath}',
                      height: 210,
                      width: 140,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 210,
                      width: 140,
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie, size: 50),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  movie.voteAverage.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;

  const _ExpandableText({
    required this.text,
    this.maxLines = 5,
  });

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _isExpanded = false;
  bool _hasOverflow = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if text overflows
        final textSpan = TextSpan(
          text: widget.text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            height: 1.5,
          ),
        );
        
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout(maxWidth: constraints.maxWidth);
        _hasOverflow = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.5,
              ),
              maxLines: _isExpanded ? null : widget.maxLines,
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (_hasOverflow) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      _isExpanded ? 'Show less' : 'Read more',
                      style: const TextStyle(
                        color: Color(0xFF667eea),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: const Color(0xFF667eea),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

