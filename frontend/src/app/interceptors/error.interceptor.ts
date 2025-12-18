import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { Router } from '@angular/router';
import { AuthService } from '../services/auth.service';
import { StateService } from '../services/state.service';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);
  const authService = inject(AuthService);
  const stateService = inject(StateService);

  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      let errorMessage = 'An error occurred';

      if (error.error instanceof ErrorEvent) {
        errorMessage = error.error.message;
      } else {
        switch (error.status) {
          case 401:
            errorMessage = 'Unauthorized. Please login again.';
            authService.logout();
            router.navigate(['/login']);
            break;
          case 403:
            errorMessage = 'Access forbidden';
            break;
          case 404:
            errorMessage = 'Resource not found';
            break;
          case 500:
            errorMessage = 'Internal server error';
            break;
          default:
            if (error.error?.message) {
              if (Array.isArray(error.error.message)) {
                errorMessage = error.error.message.join(', ');
              } else {
                errorMessage = error.error.message;
              }
            } else {
              errorMessage = `Error: ${error.status} - ${error.statusText}`;
            }
        }
      }

      // Store error in state service
      stateService.setError('global', errorMessage);

      console.error('HTTP Error:', {
        status: error.status,
        message: errorMessage,
        url: req.url,
      });

      return throwError(() => ({
        status: error.status,
        message: errorMessage,
        originalError: error,
      }));
    })
  );
};
