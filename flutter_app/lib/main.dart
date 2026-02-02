import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';
import 'services/tmdb_service.dart'; // Import TMDB service
import 'package:dio/dio.dart'; // Import Dio
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/home/home_page.dart';
import 'pages/home/home_screen.dart'; // New migrated home screen
import 'pages/movie/movie_page.dart'; // Movie browse page
import 'pages/tv/tv_page.dart'; // TV browse page
import 'pages/details/movie_detail_page.dart'; // Movie detail page
import 'pages/details/tv_detail_page.dart'; // TV detail page

void main() {
  runApp(
    const riverpod.ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
         Provider<TmdbService>( // Add TmdbService provider
          create: (_) => TmdbService(Dio()), // Ideally share the Dio instance or config
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            Provider.of<ApiService>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SahbiFlix',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomeScreen(), // Use migrated home
          '/home-old': (context) => const HomePage(), // Keep old home for reference
          '/movie': (context) => const MoviePage(), // Movie browse page
          '/tv': (context) => const TVPage(), // TV browse page
          '/profile': (context) => const ProfilePage(),
        },
        onGenerateRoute: (settings) {
          // Handle movie detail routes: /movie/:id
          if (settings.name != null && settings.name!.startsWith('/movie/')) {
            final id = int.tryParse(settings.name!.split('/').last);
            if (id != null) {
              return MaterialPageRoute(
                builder: (context) => MovieDetailPage(id: id),
              );
            }
          }
          // Handle TV detail routes: /tv/:id
          if (settings.name != null && settings.name!.startsWith('/tv/')) {
            final id = int.tryParse(settings.name!.split('/').last);
            if (id != null) {
              return MaterialPageRoute(
                builder: (context) => TvDetailPage(id: id),
              );
            }
          }
          return null;
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {


    // // ============================================================================

    // // For testing without backend, skip auth check and go straight to home
    // await Future.delayed(const Duration(seconds: 1));
    // if (!mounted) return;
    // Navigator.of(context).pushReplacementNamed('/home');
  
    // // ============================================================================



    // Original Auth Logic
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    // Small delay for splash effect
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final isAuthenticated = await apiService.isAuthenticated();

    if (isAuthenticated) {
      try {
        await authProvider.refreshProfile();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: const Text(
                  'SahbiFlix',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
