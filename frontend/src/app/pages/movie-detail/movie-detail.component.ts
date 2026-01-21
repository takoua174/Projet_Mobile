import { Component, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { TmdbService } from '../../services/tmdb.service';
import {
  MovieDetails,
  Credits,
  Cast,
  Crew,
  Review,
  Movie,
} from '../../models/tmdb.model';
import { forkJoin } from 'rxjs';

@Component({
  selector: 'app-movie-detail',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './movie-detail.component.html',
  styleUrl: './movie-detail.component.css',
})
export class MovieDetailComponent implements OnInit {
  movieDetails = signal<MovieDetails | null>(null);
  cast = signal<Cast[]>([]);
  crew = signal<Crew[]>([]);
  reviews = signal<Review[]>([]);
  similarMovies = signal<Movie[]>([]);
  loading = signal(true);
  error = signal<string | null>(null);

  // Filtered crew members
  director = signal<Crew | null>(null);
  writers = signal<Crew[]>([]);
  producers = signal<Crew[]>([]);

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private tmdbService: TmdbService
  ) {}

  ngOnInit(): void {
    this.route.params.subscribe((params) => {
      const movieId = +params['id'];
      if (movieId) {
        this.loadMovieData(movieId);
      }
    });
  }

  loadMovieData(movieId: number): void {
    this.loading.set(true);
    this.error.set(null);

    forkJoin({
      details: this.tmdbService.getMovieDetails(movieId),
      credits: this.tmdbService.getMovieCredits(movieId),
      reviews: this.tmdbService.getMovieReviews(movieId),
      similar: this.tmdbService.getSimilarMovies(movieId),
    }).subscribe({
      next: (data) => {
        this.movieDetails.set(data.details);
        this.cast.set(data.credits.cast.slice(0, 20)); // Top 20 cast members
        this.crew.set(data.credits.crew);
        this.reviews.set(data.reviews.results);
        this.similarMovies.set(data.similar.results.slice(0, 12));

        // Filter crew members
        const director = data.credits.crew.find((c) => c.job === 'Director');
        this.director.set(director || null);
        this.writers.set(
          data.credits.crew.filter(
            (c) => c.department === 'Writing' && (c.job === 'Writer' || c.job === 'Screenplay')
          )
        );
        this.producers.set(data.credits.crew.filter((c) => c.job === 'Producer').slice(0, 3));

        this.loading.set(false);
      },
      error: (err) => {
        console.error('Error loading movie data:', err);
        this.error.set('Failed to load movie details. Please try again.');
        this.loading.set(false);
      },
    });
  }

  getPosterUrl(path: string | null): string {
    return this.tmdbService.getPosterUrl(path);
  }

  getBackdropUrl(path: string | null): string {
    return this.tmdbService.getBackdropUrl(path);
  }

  getProfileUrl(path: string | null): string {
    return this.tmdbService.getProfileUrl(path);
  }

  getRatingPercentage(rating: number): number {
    return Math.round(rating * 10);
  }

  getRatingClass(rating: number): string {
    const percentage = this.getRatingPercentage(rating);
    if (percentage >= 70) return 'rating-good';
    if (percentage >= 50) return 'rating-average';
    return 'rating-poor';
  }

  formatRuntime(minutes: number): string {
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return `${hours}h ${mins}m`;
  }

  formatDate(dateString: string): string {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  }

  formatCurrency(amount: number): string {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
    }).format(amount);
  }

  truncateText(text: string, maxLength: number = 200): string {
    if (!text) return '';
    return text.length > maxLength ? text.substring(0, maxLength) + '...' : text;
  }

  getWritersNames(): string {
    return this.writers().map(w => w.name).join(', ');
  }

  getProducersNames(): string {
    return this.producers().map(p => p.name).join(', ');
  }

  goBack(): void {
    this.router.navigate(['/home']);
  }

  navigateToMovie(movieId: number): void {
    this.router.navigate(['/movie', movieId]);
  }
}
