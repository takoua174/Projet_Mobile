import { Injectable, signal } from '@angular/core';

export interface LoadingState {
  [key: string]: boolean;
}

export interface ErrorState {
  [key: string]: string | null;
}

@Injectable({
  providedIn: 'root',
})
export class StateService {
  private loadingState = signal<LoadingState>({});
  public loading = this.loadingState.asReadonly();
  private errorState = signal<ErrorState>({});
  public errors = this.errorState.asReadonly();
  private globalLoadingState = signal<boolean>(false);
  public globalLoading = this.globalLoadingState.asReadonly();

  setLoading(key: string, isLoading: boolean): void {
    this.loadingState.update((state) => ({ ...state, [key]: isLoading }));
  }

  getLoading(key: string): boolean {
    return this.loadingState()[key] || false;
  }

  clearLoading(key: string): void {
    this.loadingState.update((state) => {
      const newState = { ...state };
      delete newState[key];
      return newState;
    });
  }

  setError(key: string, error: string | null): void {
    this.errorState.update((state) => ({ ...state, [key]: error }));
  }

  getError(key: string): string | null {
    return this.errorState()[key] || null;
  }

  clearError(key: string): void {
    this.errorState.update((state) => {
      const newState = { ...state };
      delete newState[key];
      return newState;
    });
  }

  clearAllErrors(): void {
    this.errorState.set({});
  }

  setGlobalLoading(isLoading: boolean): void {
    this.globalLoadingState.set(isLoading);
  }
}
