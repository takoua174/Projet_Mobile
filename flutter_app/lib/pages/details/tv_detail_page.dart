import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/tmdb_models.dart';
import '../../services/tmdb_service.dart';
import '../../providers/tv_detail_provider.dart';
import '../../config/environment.dart';
import 'widgets/widgets.dart';

class TvDetailPage extends StatelessWidget {
  final int id;

  const TvDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TvDetailProvider(
         Provider.of<TmdbService>(context, listen: false),
      )..loadTvShow(id),
      child: const _TvDetailScaffold(),
    );
  }
}

class _TvDetailScaffold extends StatelessWidget {
  const _TvDetailScaffold();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TvDetailProvider>(context);
    final tv = provider.tvShow;

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(provider.error!)),
      );
    }

    if (tv == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, tv),
          SliverToBoxAdapter(child: _buildHeaderInfo(context, tv)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                tv.overview,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          // Seasons Section
           if (tv.seasons.isNotEmpty) ...[
             const SliverToBoxAdapter(child: SectionHeader(title: "Seasons")),
             SliverToBoxAdapter(child: _buildSeasonList(tv.seasons)),
           ],

          if (provider.cast.isNotEmpty) ...[
             const SliverToBoxAdapter(child: SectionHeader(title: "Cast")),
             SliverToBoxAdapter(child: CastListWidget(cast: provider.cast)),
          ],
          if (provider.videos.isNotEmpty) ...[
             const SliverToBoxAdapter(child: SectionHeader(title: "Videos")),
             SliverToBoxAdapter(child: VideoCarouselWidget(videos: provider.videos)),
          ],
           const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, TVShowDetails tv) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          tv.name,
          style: const TextStyle(
            shadows: [Shadow(color: Colors.black, blurRadius: 10)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            tv.backdropPath != null
                ? CachedNetworkImage(
                    imageUrl:
                        '${AppConfig.tmdbImageBaseUrl}/original${tv.backdropPath}',
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

  Widget _buildHeaderInfo(BuildContext context, TVShowDetails tv) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'tv_poster_${tv.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: tv.posterPath != null
                      ? CachedNetworkImage(
                          imageUrl:
                              '${AppConfig.tmdbImageBaseUrl}/w500${tv.posterPath}',
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 100,
                          height: 150,
                          color: Colors.grey,
                          child: const Icon(Icons.tv, size: 50),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tv.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                     Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          tv.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        Text('${tv.numberOfSeasons} Seasons'),
                      ],
                    ),
                    const SizedBox(height: 8),
                     Text(
                      tv.firstAirDate.isNotEmpty
                        ? "First Air: ${DateFormat.yMMMd().format(DateTime.parse(tv.firstAirDate))}"
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
              children: tv.genres.map((g) {
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
               IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
               ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonList(List<Season> seasons) {
      return SizedBox(
        height: 180,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: seasons.length,
          itemBuilder: (context, index) {
            final season = seasons[index];
            return Container(
              width: 120,
              margin: const EdgeInsets.only(right: 16),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   ClipRRect(
                     borderRadius: BorderRadius.circular(8),
                     child: season.posterPath != null
                        ? CachedNetworkImage(
                            imageUrl: '${AppConfig.tmdbImageBaseUrl}/w200${season.posterPath}',
                            height: 140,
                            width: 120,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 140,
                            width: 120,
                            color: Colors.grey[800],
                            child: const Icon(Icons.tv_off),
                          ),
                   ),
                   const SizedBox(height: 4),
                   Text(
                     season.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                   ),
                    Text(
                     "${season.episodeCount} Episodes",
                      style: Theme.of(context).textTheme.bodySmall,
                   ),
                 ],
               ),
            );
          },
        ),
      );
  }
}

