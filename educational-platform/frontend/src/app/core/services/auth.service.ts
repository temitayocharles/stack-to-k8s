import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { BehaviorSubject, Observable, throwError, timer } from 'rxjs';
import { map, catchError, tap, switchMap } from 'rxjs/operators';
import { Router } from '@angular/router';
import { 
  User, 
  LoginRequest, 
  LoginResponse, 
  CreateUserRequest, 
  RefreshTokenRequest,
  ChangePasswordRequest,
  ResetPasswordRequest,
  ResetPasswordConfirmRequest
} from '../../shared/models/user.model';
import { environment } from '../../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly baseUrl = environment.apiUrl;
  private readonly tokenKey = 'auth_token';
  private readonly refreshTokenKey = 'refresh_token';
  private readonly userKey = 'current_user';

  private currentUserSubject = new BehaviorSubject<User | null>(null);
  private refreshTokenTimeout?: any;
  public redirectUrl: string = '/dashboard';

  public currentUser$ = this.currentUserSubject.asObservable();

  constructor(
    private http: HttpClient,
    private router: Router
  ) {
    this.initializeAuth();
  }

  private initializeAuth(): void {
    const token = this.getToken();
    const storedUser = localStorage.getItem(this.userKey);
    
    if (token && storedUser) {
      try {
        const user = JSON.parse(storedUser);
        this.currentUserSubject.next(user);
        this.startRefreshTokenTimer();
      } catch (error) {
        console.error('Error parsing stored user:', error);
        this.logout();
      }
    }
  }

  public get currentUserValue(): User | null {
    return this.currentUserSubject.value;
  }

  public get isAuthenticated(): boolean {
    return !!this.getToken() && !!this.currentUserValue;
  }

  public get isStudent(): boolean {
    return this.currentUserValue?.roles.includes('STUDENT') || false;
  }

  public get isInstructor(): boolean {
    return this.currentUserValue?.roles.includes('INSTRUCTOR') || false;
  }

  public get isAdmin(): boolean {
    return this.currentUserValue?.roles.includes('ADMIN') || false;
  }

  public hasRole(role: string): boolean {
    return this.currentUserValue?.roles.includes(role) || false;
  }

  public hasAnyRole(roles: string[]): boolean {
    return roles.some(role => this.hasRole(role));
  }

  login(credentials: LoginRequest): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(`${this.baseUrl}/auth/login`, credentials)
      .pipe(
        tap(response => {
          this.setTokens(response.token, response.refreshToken);
          this.setCurrentUser(response.user);
          this.startRefreshTokenTimer();
        }),
        catchError(this.handleError)
      );
  }

  register(userData: CreateUserRequest): Observable<User> {
    return this.http.post<User>(`${this.baseUrl}/auth/register`, userData)
      .pipe(catchError(this.handleError));
  }

  logout(): void {
    this.clearTokens();
    this.clearCurrentUser();
    this.stopRefreshTokenTimer();
    this.currentUserSubject.next(null);
    this.router.navigate(['/auth/login']);
  }

  refreshToken(): Observable<LoginResponse> {
    const refreshToken = this.getRefreshToken();
    if (!refreshToken) {
      this.logout();
      return throwError(() => new Error('No refresh token available'));
    }

    const request: RefreshTokenRequest = { refreshToken };
    
    return this.http.post<LoginResponse>(`${this.baseUrl}/auth/refresh-token`, request)
      .pipe(
        tap(response => {
          this.setTokens(response.token, response.refreshToken);
          this.setCurrentUser(response.user);
          this.startRefreshTokenTimer();
        }),
        catchError(error => {
          this.logout();
          return throwError(() => error);
        })
      );
  }

  changePassword(request: ChangePasswordRequest): Observable<void> {
    return this.http.put<void>(`${this.baseUrl}/auth/change-password`, request)
      .pipe(catchError(this.handleError));
  }

  resetPassword(request: ResetPasswordRequest): Observable<void> {
    return this.http.post<void>(`${this.baseUrl}/auth/reset-password`, request)
      .pipe(catchError(this.handleError));
  }

  confirmResetPassword(request: ResetPasswordConfirmRequest): Observable<void> {
    return this.http.post<void>(`${this.baseUrl}/auth/reset-password/confirm`, request)
      .pipe(catchError(this.handleError));
  }

  getCurrentUser(): Observable<User> {
    return this.http.get<User>(`${this.baseUrl}/auth/me`)
      .pipe(
        tap(user => this.setCurrentUser(user)),
        catchError(this.handleError)
      );
  }

  updateProfile(user: Partial<User>): Observable<User> {
    return this.http.put<User>(`${this.baseUrl}/auth/profile`, user)
      .pipe(
        tap(updatedUser => this.setCurrentUser(updatedUser)),
        catchError(this.handleError)
      );
  }

  getAuthHeaders(): HttpHeaders {
    const token = this.getToken();
    return new HttpHeaders({
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    });
  }

  private setTokens(token: string, refreshToken: string): void {
    localStorage.setItem(this.tokenKey, token);
    localStorage.setItem(this.refreshTokenKey, refreshToken);
  }

  private clearTokens(): void {
    localStorage.removeItem(this.tokenKey);
    localStorage.removeItem(this.refreshTokenKey);
  }

  private getToken(): string | null {
    return localStorage.getItem(this.tokenKey);
  }

  private getRefreshToken(): string | null {
    return localStorage.getItem(this.refreshTokenKey);
  }

  private setCurrentUser(user: User): void {
    localStorage.setItem(this.userKey, JSON.stringify(user));
    this.currentUserSubject.next(user);
  }

  private clearCurrentUser(): void {
    localStorage.removeItem(this.userKey);
  }

  private startRefreshTokenTimer(): void {
    // Parse json object from base64 encoded jwt token
    const token = this.getToken();
    if (!token) return;

    try {
      const jwtToken = JSON.parse(atob(token.split('.')[1]));
      
      // Set a timeout to refresh the token a minute before it expires
      const expires = new Date(jwtToken.exp * 1000);
      const timeout = expires.getTime() - Date.now() - (60 * 1000);
      
      if (timeout > 0) {
        this.refreshTokenTimeout = setTimeout(() => {
          this.refreshToken().subscribe({
            error: () => this.logout()
          });
        }, timeout);
      } else {
        // Token is expired or about to expire, refresh immediately
        this.refreshToken().subscribe({
          error: () => this.logout()
        });
      }
    } catch (error) {
      console.error('Error parsing JWT token:', error);
      this.logout();
    }
  }

  private stopRefreshTokenTimer(): void {
    if (this.refreshTokenTimeout) {
      clearTimeout(this.refreshTokenTimeout);
      this.refreshTokenTimeout = null;
    }
  }

  private handleError(error: any): Observable<never> {
    let errorMessage = 'An error occurred';
    
    if (error.error?.message) {
      errorMessage = error.error.message;
    } else if (error.message) {
      errorMessage = error.message;
    } else if (error.status) {
      switch (error.status) {
        case 401:
          errorMessage = 'Invalid credentials';
          break;
        case 403:
          errorMessage = 'Access denied';
          break;
        case 404:
          errorMessage = 'Resource not found';
          break;
        case 500:
          errorMessage = 'Server error occurred';
          break;
        default:
          errorMessage = `Error: ${error.status}`;
      }
    }

    console.error('Auth Service Error:', error);
    return throwError(() => new Error(errorMessage));
  }
}
