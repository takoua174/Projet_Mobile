import { Component, Input, OnInit, ElementRef, ViewChild, inject } from '@angular/core';
import { CommonModule, NgTemplateOutlet } from '@angular/common';
import { Router } from '@angular/router';
import { TmdbService } from '../../services/tmdb.service';
import { Movie } from '../../models/tmdb.model';

@Component({
  selector: 'app-movie-row',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './movie-row.html',
  styleUrl : "./movie-row.css"
})
export class MovieRowComponent implements OnInit {
  @Input() title: string = '';
  @Input() fetchType: 'trending' | 'topRated' | 'genre' = 'trending';
  @Input() genreId?: string; // For genre fetch
  @Input() isLarge: boolean = false;

  @ViewChild('scrollContainer') scrollContainer!: ElementRef;

  movies: Movie[] = [];
  currentPage: number = 1;
  isLoading: boolean = false;
  totalPages: number = 1;

  constructor() {}


  private tmdbService: TmdbService = inject(TmdbService);
  private router: Router = inject(Router);

  ngOnInit() {
    this.loadMovies();
  }

  getPoster(path: string | null): string {
    return this.tmdbService.getPosterUrl(path);
  }

  navigateToDetail(movieId: number): void {
    this.router.navigate(['/movie', movieId]);
  }

  loadMovies() {
    if (this.isLoading || this.currentPage > this.totalPages) return;

    this.isLoading = true;

    let obs$;
    
    // Determine which API call to make
    if (this.fetchType === 'trending') {
      obs$ = this.tmdbService.getTrendingMovies(); // Trending usually doesn't paginate via generic endpoint easily, simplifying to popular for pagination or keeping purely trending
    } else if (this.fetchType === 'topRated') {
      obs$ = this.tmdbService.getTopRatedMovies(this.currentPage);
    } else if (this.fetchType === 'genre' && this.genreId) {
      obs$ = this.tmdbService.discoverMovies({ 
        with_genres: this.genreId, 
        page: this.currentPage.toString() 
      });
    } else {
       // Default to popular if nothing matches
       obs$ = this.tmdbService.getPopularMovies(this.currentPage);
    }

    obs$.subscribe({
      next: (res) => {
        // Append new movies to existing list
        this.movies = [...this.movies, ...res.results];
        this.totalPages = res.total_pages;
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Error fetching row data', err);
        this.isLoading = false;
      }
    });
  }

  // Infinite Scroll Logic (Horizontal)
  onScroll() {
    const element = this.scrollContainer.nativeElement;
    // Check if we are near the right edge
    const atRightEdge = element.scrollLeft + element.clientWidth >= element.scrollWidth - 100; // 100px buffer

    if (atRightEdge && !this.isLoading) {
      this.currentPage++;
      this.loadMovies();
    }
  }
}
