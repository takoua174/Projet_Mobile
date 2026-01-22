import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TmdbImagePipe } from  '../../pipe/tmdb-image.pipe';

@Component({
  selector: 'app-media-carousel',
  standalone: true,
  imports: [CommonModule, TmdbImagePipe],
  template: `
    <section class="carousel-section" *ngIf="items && items.length > 0">
      <h2 class="section-title">{{ title }}</h2>
      <div class="carousel-grid">
        <div class="carousel-card" *ngFor="let item of items" (click)="itemClicked.emit(item)">
          <img 
            [src]="(item.poster_path || item.profile_path) | tmdbImage:imageType" 
            [alt]="item.title || item.name" 
            class="card-image" 
          />
          <div class="card-info">
            <p class="card-name">{{ item.title || item.name }}</p>
            
            <p class="card-subtitle" *ngIf="item.character">{{ item.character }}</p>
            
            <p class="card-subtitle" *ngIf="item.episode_count">{{ item.episode_count }} Episodes</p>
            
            <p class="card-rating" *ngIf="item.vote_average && !item.character">
              ★ {{ item.vote_average.toFixed(1) }}
            </p>
          </div>
        </div>
      </div>
    </section>
  `,
  styles: [`
    .carousel-section { margin-bottom: 60px; }
    .section-title { font-size: 32px; margin-bottom: 30px; color: #fff; }
    
    .carousel-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
      gap: 20px;
    }

    .carousel-card {
      background-color: rgba(255, 255, 255, 0.05);
      border-radius: 10px;
      overflow: hidden;
      transition: transform 0.3s ease;
      cursor: pointer;
    }

    .carousel-card:hover {
      transform: translateY(-5px);
      background-color: rgba(255, 255, 255, 0.1);
    }

    .card-image {
      width: 100%;
      aspect-ratio: 2/3;
      object-fit: cover;
    }

    .card-info { padding: 15px; }

    .card-name {
      font-weight: 700;
      margin: 0 0 5px 0;
      font-size: 14px;
      color: #fff;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .card-subtitle { color: #999; margin: 0; font-size: 13px; }
    .card-rating { color: #ffd700; margin: 0; font-size: 14px; }

    @media (max-width: 768px) {
      .carousel-grid { grid-template-columns: repeat(auto-fill, minmax(130px, 1fr)); }
      .section-title { font-size: 24px; }
    }
  `]
})
export class MediaCarouselComponent {
  @Input({ required: true }) title: string = '';
  @Input({ required: true }) items: any[] = [];
  @Input() imageType: 'poster' | 'profile' = 'poster';
  @Output() itemClicked = new EventEmitter<any>();
}