import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../models/tmdb_models.dart';
import '../../../services/tmdb_service.dart';
import '../../../providers/movie_detail_provider.dart';
import '../../../config/app_config.dart';
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
      )..loadMovie(id),
      child: const _MovieDetailScaffold(),
    );
  }
}

class _MovieDetailScaffold extends StatelessWidget {
  const _MovieDetailScaffold();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MovieDetailProvider>(context);
    final movie = provider.movie;

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
          SliverToBoxAdapter(child: _buildHeaderInfo(context, movie)),
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
          if (provider.reviews.isNotEmpty) ...[
             const SliverToBoxAdapter(child: SectionHeader(title: "Reviews")),
             ReviewListWidget(reviews: provider.reviews),
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

  Widget _buildHeaderInfo(BuildContext context, MovieDetails movie) {
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
               IconButton(
                onPressed: () {
                  // Toggle favorite logic
                },
                icon: const Icon(Icons.favorite_border),
                tooltip: "Add to Favorites",
               ),
            ],
          ),
        ],
      ),
    );
  }
}

