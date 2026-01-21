import { Component, inject, Input, OnChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { Movie } from '../../models/tmdb.model';
import { TmdbService } from '../../services/tmdb.service';

@Component({
  selector: 'app-hero-banner',
  standalone: true,
  imports: [CommonModule],
  templateUrl:"./hero-banner.html",
  styleUrl:"./hero-banner.css"
})
export class HeroBannerComponent implements OnChanges {
  @Input() movie: Movie | null = null;
  backdropUrl: string = '';

  constructor(
  ) {}

    private tmdbService = inject(TmdbService);
    private router = inject(Router);

  ngOnChanges() {
    if (this.movie) {
      this.backdropUrl = this.tmdbService.getBackdropUrl(this.movie.backdrop_path);
    }
  }

  navigateToDetail(): void {
    if (this.movie) {
      this.router.navigate(['/movie', this.movie.id]);
    }
  }
}