import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_theme.dart';
import '../details/movie_detail_page.dart';  // Import MovieDetailPage
import '../details/tv_detail_page.dart';     // Import TvDetailPage

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.primaryGradient.createShader(bounds),
          child: const Text(
            'SahbiFlix',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          // Add temporary buttons to navigate to existing details pages
           IconButton(
            icon: const Icon(Icons.movie),
            tooltip: "Test Movie Details",
            onPressed: () {
               // Navigate to a test movie (e.g., Fight Club id 550)
               Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MovieDetailPage(id: 550))
              );
            },
          ),
           IconButton(
            icon: const Icon(Icons.tv),
            tooltip: "Test TV Details",
            onPressed: () {
               // Navigate to a test TV show (e.g., Breaking Bad id 1396)
               Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TvDetailPage(id: 1396))
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.currentUser;
              return IconButton(
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor,
                  child: user?.profilePicture != null
                      ? null
                      : const Icon(
                          Icons.person,
                          size: 18,
                          color: Colors.white,
                        ),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/profile');
                },
                tooltip: 'Profile',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.movie_outlined,
                size: 100,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to SahbiFlix!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'This is a placeholder home page.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/home-new');
                },
                icon: const Icon(Icons.dashboard),
                label: const Text('Test New Migrated Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/movie');
                },
                icon: const Icon(Icons.movie_filter),
                label: const Text('Test Movie Browse Page'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/tv');
                },
                icon: const Icon(Icons.live_tv),
                label: const Text('Test TV Browse Page'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/profile');
                },
                icon: const Icon(Icons.person),
                label: const Text('Go to Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
