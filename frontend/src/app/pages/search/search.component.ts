/*import { Component, OnInit, signal, inject, DestroyRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { TmdbService } from '../../services/tmdb.service';
import { Movie } from '../../models/tmdb.model';
import { debounceTime, distinctUntilChanged, switchMap, tap } from 'rxjs/operators';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { of } from 'rxjs';
import { PosterUrlPipe } from '../../pipe/poster-url-pipe';

type ContentType = 'all' | 'movie' | 'tv';
type SortOption = 'popularity' | 'rating' | 'date';

interface SearchResult {
  id: number;
  title?: string;
  name?: string;
  poster_path: string | null;
  backdrop_path: string | null;
  vote_average: number;
  release_date?: string;
  first_air_date?: string;
  media_type?: string;
  overview: string;
}

@Component({
  selector: 'app-search',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, PosterUrlPipe],
  templateUrl: './search.component.html',
  styleUrl: './search.component.css',
})
export class SearchComponent implements OnInit {
  private tmdbService = inject(TmdbService);
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private destroyRef = inject(DestroyRef);

  searchControl = new FormControl('');
  searchResults = signal<SearchResult[]>([]);
  filteredResults = signal<SearchResult[]>([]);
  isLoading = signal(false);
  currentPage = signal(1);
  totalPages = signal(1);
  hasSearched = signal(false);

  activeFilter = signal<ContentType>('all');
  activeSortOption = signal<SortOption>('popularity');

  ngOnInit(): void {
    // Get query param from URL
    this.route.queryParams.pipe(takeUntilDestroyed(this.destroyRef)).subscribe((params) => {
      const query = params['q'];
      if (query) {
        this.searchControl.setValue(query, { emitEvent: false });
        this.performSearch(query);
      }
    });

    // Listen to search input changes
    this.searchControl.valueChanges
      .pipe(
        debounceTime(500),
        distinctUntilChanged(),
        tap(() => this.isLoading.set(true)),
        switchMap((query) => {
          const term = query?.trim() || '';
          if (term.length < 2) {
            this.resetSearch();
            return of({ results: [], total_pages: 0 });
          }
          this.hasSearched.set(true);
          return this.searchMulti(term, 1);
        }),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe({
        next: (response) => {
          this.searchResults.set(response.results);
          this.applyFilters();
          this.totalPages.set(response.total_pages);
          this.currentPage.set(1);
          this.isLoading.set(false);
          this.updateURL();
        },
        error: (err) => {
          console.error('Search error:', err);
          this.isLoading.set(false);
        },
      });
  }

  private searchMulti(query: string, page: number) {
    return this.tmdbService.searchMulti(query, page);
  }

  performSearch(query: string): void {
    this.isLoading.set(true);
    this.hasSearched.set(true);

    this.searchMulti(query, 1).subscribe({
      next: (response) => {
        this.searchResults.set(response.results);
        this.applyFilters();
        this.totalPages.set(response.total_pages);
        this.currentPage.set(1);
        this.isLoading.set(false);
      },
      error: (err) => {
        console.error('Search error:', err);
        this.isLoading.set(false);
      },
    });
  }

  setFilter(filter: ContentType): void {
    this.activeFilter.set(filter);
    this.applyFilters();
  }

  setSortOption(option: SortOption): void {
    this.activeSortOption.set(option);
    this.applyFilters();
  }

  private applyFilters(): void {
    let results = [...this.searchResults()];

    // Filter by content type
    if (this.activeFilter() !== 'all') {
      results = results.filter((item) => item.media_type === this.activeFilter());
    }

    // Sort results
    switch (this.activeSortOption()) {
      case 'popularity':
        results.sort((a, b) => b.vote_average - a.vote_average);
        break;
      case 'rating':
        results.sort((a, b) => b.vote_average - a.vote_average);
        break;
      case 'date':
        results.sort((a, b) => {
          const dateA = new Date(a.release_date || a.first_air_date || 0).getTime();
          const dateB = new Date(b.release_date || b.first_air_date || 0).getTime();
          return dateB - dateA;
        });
        break;
    }

    this.filteredResults.set(results);
  }

  loadMore(): void {
    const query = this.searchControl.value?.trim();
    if (!query || this.currentPage() >= this.totalPages()) return;

    this.isLoading.set(true);
    const nextPage = this.currentPage() + 1;

    this.searchMulti(query, nextPage).subscribe({
      next: (response) => {
        this.searchResults.update((current) => [...current, ...response.results]);
        this.applyFilters();
        this.currentPage.set(nextPage);
        this.isLoading.set(false);
      },
      error: (err) => {
        console.error('Load more error:', err);
        this.isLoading.set(false);
      },
    });
  }

  navigateToDetail(item: SearchResult): void {
    const type = item.media_type === 'tv' ? 'tv' : 'movie';
    this.router.navigate([`/${type}`, item.id]);
  }

  getTitle(item: SearchResult): string {
    return item.title || item.name || 'Untitled';
  }

  getYear(item: SearchResult): string {
    const date = item.release_date || item.first_air_date;
    return date ? new Date(date).getFullYear().toString() : '';
  }

  getMediaTypeBadge(item: SearchResult): string {
    return item.media_type === 'tv' ? 'TV Show' : 'Movie';
  }

  private resetSearch(): void {
    this.searchResults.set([]);
    this.filteredResults.set([]);
    this.currentPage.set(1);
    this.totalPages.set(1);
    this.isLoading.set(false);
  }

  private updateURL(): void {
    const query = this.searchControl.value?.trim();
    if (query) {
      this.router.navigate([], {
        relativeTo: this.route,
        queryParams: { q: query },
        queryParamsHandling: 'merge',
      });
    }
  }

  clearSearch(): void {
    this.searchControl.setValue('');
    this.resetSearch();
    this.hasSearched.set(false);
    this.router.navigate(['/search']);
  }
}
*/
