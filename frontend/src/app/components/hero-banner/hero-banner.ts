import { Component, Input, OnChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
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

  constructor(private tmdbService: TmdbService) {}

  ngOnChanges() {
    if (this.movie) {
      this.backdropUrl = this.tmdbService.getBackdropUrl(this.movie.backdrop_path);
    }
  }
}