import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'dart:async';

/// CreateReviewWidget - Form to write and submit a movie review
/// 
/// Migrated from Angular CreateReviewComponent
/// Features:
/// - Star rating selector (1-10)
/// - Review text input with auto-save to local storage
/// - Authentication check
/// - Submit/Cancel actions
/// - Success/Error messages
class CreateReviewWidget extends riverpod.ConsumerStatefulWidget {
  final String movieId;
  final String movieTitle;
  final VoidCallback? onReviewCreated;

  const CreateReviewWidget({
    super.key,
    required this.movieId,
    required this.movieTitle,
    this.onReviewCreated,
  });

  @override
  riverpod.ConsumerState<CreateReviewWidget> createState() =>
      _CreateReviewWidgetState();
}

class _CreateReviewWidgetState extends riverpod.ConsumerState<CreateReviewWidget> {
  final _contentController = TextEditingController();
  int? _rating;
  bool _submitting = false;
  String? _error;
  bool _success = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadSavedReview();
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedReview() async {
    final prefs = await SharedPreferences.getInstance();
    final savedContent = prefs.getString(widget.movieId);
    if (savedContent != null && mounted) {
      _contentController.text = savedContent;
    }
  }

  void _onContentChanged() {
    // Debounce saving to local storage
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(widget.movieId, _contentController.text);
    });
  }

  Future<void> _submitReview() async {
    final currentUser = ref.read(currentUserProvider);
    
    if (currentUser == null) {
      setState(() {
        _error = 'You must be logged in to submit a review';
      });
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please write a review';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.createReview(
        movieId: widget.movieId,
        author: currentUser.username,
        authorDetails: {
          'name': currentUser.username,
          'username': currentUser.username,
          'profile_image': currentUser.profilePicture,
          'rating': _rating,
        },
        content: _contentController.text,
      );

      if (mounted) {
        setState(() {
          _success = true;
          _submitting = false;
        });

        // Clear form and local storage
        _contentController.clear();
        _rating = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(widget.movieId);

        // Reset success message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _success = false;
            });
          }
        });

        // Notify parent to reload reviews
        widget.onReviewCreated?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to submit review. Please try again.';
          _submitting = false;
        });
      }
    }
  }

  void _cancelReview() {
    setState(() {
      _contentController.clear();
      _rating = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isAuthenticated = currentUser != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Write a Review',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your thoughts about ${widget.movieTitle}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),

          // Content
          if (!isAuthenticated) _buildLoginPrompt() else _buildReviewForm(),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            Text(
              'Please log in to write a review',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Log In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Error message
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFDC2626).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFFfca5a5),
                fontSize: 14,
              ),
            ),
          ),

        // Success message
        if (_success)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF22c55e).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF22c55e).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF86efac), size: 20),
                SizedBox(width: 8),
                Text(
                  'Review submitted successfully!',
                  style: TextStyle(
                    color: Color(0xFF86efac),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

        // Rating selector
        const Text(
          'Rating (Optional)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildRatingSelector(),
        const SizedBox(height: 20),

        // Review text area
        const Text(
          'Your Review *',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contentController,
          enabled: !_submitting,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'What did you think about this movie?',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.4),
            ),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.4),
                width: 1,
              ),
            ),
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 20),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _submitting ? null : _cancelReview,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: (_submitting || _contentController.text.trim().isEmpty)
                  ? null
                  : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF667eea).withOpacity(0.6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(_submitting ? 'Submitting...' : 'Submit Review'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        return Wrap(
          spacing: isMobile ? 2 : 4,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...List.generate(10, (index) {
              final star = index + 1;
              final isActive = _rating != null && star <= _rating!;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = star;
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(isMobile ? 2 : 4),
                    child: Text(
                      '★',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 28,
                        color: isActive
                            ? const Color(0xFFffd700)
                            : Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (_rating != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '$_rating/10',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
