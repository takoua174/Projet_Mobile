import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-video-gallery',
  standalone: true,
  imports: [CommonModule],
  template: `
    <section class="trailers-section" *ngIf="videos && videos.length > 0">
      <h2 class="section-title">Trailers & Videos</h2>
      <div class="trailers-grid">
        <div class="trailer-card" *ngFor="let video of videos" (click)="playVideo.emit(video)">
          <div class="trailer-thumbnail">
            <img 
              [src]="'https://img.youtube.com/vi/' + video.key + '/hqdefault.jpg'" 
              [alt]="video.name"
              class="thumbnail-image" 
            />
            <div class="play-overlay">
              <div class="play-button">
                <svg width="50" height="50" viewBox="0 0 24 24" fill="white">
                  <path d="M8 5v14l11-7z" />
                </svg>
              </div>
            </div>
          </div>
          <div class="trailer-info">
            <p class="trailer-name">{{ video.name }}</p>
            <p class="trailer-type">{{ video.type }}</p>
          </div>
        </div>
      </div>
    </section>
  `,
  styles: [`
    .trailers-section { margin-bottom: 60px; }
    .section-title { font-size: 32px; margin-bottom: 30px; color: #fff; }
    
    .trailers-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
      gap: 20px;
    }

    .trailer-card {
      cursor: pointer;
      border-radius: 10px;
      overflow: hidden;
      background-color: rgba(255, 255, 255, 0.05);
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    .trailer-card:hover {
      transform: translateY(-5px);
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
    }

    .trailer-thumbnail {
      position: relative;
      width: 100%;
      padding-bottom: 56.25%;
      overflow: hidden;
      background-color: #000;
    }

    .thumbnail-image {
      position: absolute;
      top: 0; left: 0; width: 100%; height: 100%;
      object-fit: cover;
    }

    .play-overlay {
      position: absolute;
      top: 0; left: 0; width: 100%; height: 100%;
      background-color: rgba(0, 0, 0, 0.3);
      display: flex; align-items: center; justify-content: center;
      opacity: 0; transition: opacity 0.3s ease;
    }

    .trailer-card:hover .play-overlay { opacity: 1; }

    .play-button {
      width: 60px; height: 60px;
      background-color: rgba(229, 9, 20, 0.9);
      border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      transition: transform 0.3s ease;
    }

    .trailer-card:hover .play-button { transform: scale(1.2); }

    .trailer-info { padding: 15px; }

    .trailer-name {
      font-weight: 600; margin: 0 0 5px 0; font-size: 14px; color: #fff;
      overflow: hidden; text-overflow: ellipsis;
      display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
    }

    .trailer-type { color: #888; margin: 0; font-size: 13px; text-transform: uppercase; }

    @media (max-width: 768px) {
      .trailers-grid { grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); }
      .section-title { font-size: 24px; }
    }
  `]
})
export class VideoGalleryComponent {
  @Input({ required: true }) videos: any[] = [];
  @Output() playVideo = new EventEmitter<any>();
}