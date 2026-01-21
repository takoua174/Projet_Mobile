import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TmdbService } from '../../services/tmdb.service';
import { Movie } from '../../models/tmdb.model';
import { HeroBannerComponent } from "../../components/hero-banner/hero-banner";
import { MovieRowComponent } from '../../components/movie-row/movie-row';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, HeroBannerComponent, MovieRowComponent],
  templateUrl: './home.component.html',
  styleUrl: "./home.component.css" 
})
export class HomeComponent implements OnInit {
  bannerMovie: Movie | null = null;

  constructor(private tmdbService: TmdbService) {}

  ngOnInit() {
    // Fetch Trending movies to pick one for the banner
    this.tmdbService.getTrendingMovies().subscribe(response => {
      if (response.results && response.results.length > 0) {
        // Pick a random movie from the top 20
        const randomIndex = Math.floor(Math.random() * response.results.length);
        this.bannerMovie = response.results[randomIndex];
      }
    });
  }
}