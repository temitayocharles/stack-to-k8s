import { Component, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterModule, ActivatedRoute } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSnackBarModule, MatSnackBar } from '@angular/material/snack-bar';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { Subject, takeUntil, finalize } from 'rxjs';
import { AuthService } from '../../../core/services/auth.service';
import { LoginRequest } from '../../../shared/models/user.model';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    RouterModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    MatProgressSpinnerModule,
    MatSnackBarModule,
    MatCheckboxModule
  ],
  template: `
    <div class="login-container">
      <div class="login-card-wrapper">
        <mat-card class="login-card">
          <mat-card-header class="login-header">
            <div class="logo-section">
              <mat-icon class="logo-icon">school</mat-icon>
              <h1>EduPlatform</h1>
            </div>
            <p class="login-subtitle">Sign in to your account</p>
          </mat-card-header>

          <mat-card-content>
            <form [formGroup]="loginForm" (ngSubmit)="onSubmit()" class="login-form">
              <mat-form-field appearance="outline" class="full-width">
                <mat-label>Username or Email</mat-label>
                <input
                  matInput
                  formControlName="username"
                  placeholder="Enter your username or email"
                  autocomplete="username">
                <mat-icon matSuffix>person</mat-icon>
                <mat-error *ngIf="loginForm.get('username')?.hasError('required')">
                  Username or email is required
                </mat-error>
              </mat-form-field>

              <mat-form-field appearance="outline" class="full-width">
                <mat-label>Password</mat-label>
                <input
                  matInput
                  [type]="hidePassword ? 'password' : 'text'"
                  formControlName="password"
                  placeholder="Enter your password"
                  autocomplete="current-password">
                <button
                  mat-icon-button
                  matSuffix
                  type="button"
                  (click)="hidePassword = !hidePassword"
                  [attr.aria-label]="'Hide password'"
                  [attr.aria-pressed]="hidePassword">
                  <mat-icon>{{hidePassword ? 'visibility_off' : 'visibility'}}</mat-icon>
                </button>
                <mat-error *ngIf="loginForm.get('password')?.hasError('required')">
                  Password is required
                </mat-error>
                <mat-error *ngIf="loginForm.get('password')?.hasError('minlength')">
                  Password must be at least 6 characters
                </mat-error>
              </mat-form-field>

              <div class="form-options">
                <mat-checkbox formControlName="rememberMe" class="remember-me">
                  Remember me
                </mat-checkbox>
                <a routerLink="/auth/forgot-password" class="forgot-password-link">
                  Forgot password?
                </a>
              </div>

              <button
                mat-raised-button
                color="primary"
                type="submit"
                class="login-button full-width"
                [disabled]="loginForm.invalid || isLoading">
                <mat-spinner diameter="20" *ngIf="isLoading"></mat-spinner>
                <span *ngIf="!isLoading">Sign In</span>
                <span *ngIf="isLoading">Signing In...</span>
              </button>

              <div class="divider">
                <span>or</span>
              </div>

              <div class="social-login">
                <button
                  mat-stroked-button
                  type="button"
                  class="social-button full-width"
                  (click)="loginWithGoogle()"
                  [disabled]="isLoading">
                  <mat-icon svgIcon="google"></mat-icon>
                  Continue with Google
                </button>
              </div>
            </form>
          </mat-card-content>

          <mat-card-actions class="login-actions">
            <p class="signup-prompt">
              Don't have an account?
              <a routerLink="/auth/register" class="signup-link">Sign up</a>
            </p>
          </mat-card-actions>
        </mat-card>
      </div>
    </div>
  `,
  styles: [`
    .login-container {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      padding: 2rem;
    }

    .login-card-wrapper {
      width: 100%;
      max-width: 400px;
    }

    .login-card {
      padding: 2rem;
      border-radius: 12px;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
    }

    .login-header {
      text-align: center;
      margin-bottom: 2rem;
    }

    .logo-section {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 0.5rem;
      margin-bottom: 1rem;
    }

    .logo-icon {
      font-size: 48px;
      width: 48px;
      height: 48px;
      color: #3f51b5;
    }

    .login-header h1 {
      font-size: 2rem;
      font-weight: 600;
      margin: 0;
      color: #333;
    }

    .login-subtitle {
      color: #666;
      font-size: 1rem;
      margin: 0;
    }

    .login-form {
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }

    .full-width {
      width: 100%;
    }

    .form-options {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin: 0.5rem 0;
    }

    .remember-me {
      font-size: 0.875rem;
    }

    .forgot-password-link {
      color: #3f51b5;
      text-decoration: none;
      font-size: 0.875rem;
    }

    .forgot-password-link:hover {
      text-decoration: underline;
    }

    .login-button {
      height: 48px;
      font-size: 1rem;
      font-weight: 500;
      margin-top: 1rem;
    }

    .divider {
      text-align: center;
      margin: 1.5rem 0;
      position: relative;
    }

    .divider::before {
      content: '';
      position: absolute;
      top: 50%;
      left: 0;
      right: 0;
      height: 1px;
      background: #e0e0e0;
    }

    .divider span {
      background: white;
      padding: 0 1rem;
      color: #666;
      font-size: 0.875rem;
    }

    .social-login {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    .social-button {
      height: 48px;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
    }

    .login-actions {
      text-align: center;
      padding-top: 1rem;
    }

    .signup-prompt {
      margin: 0;
      font-size: 0.875rem;
      color: #666;
    }

    .signup-link {
      color: #3f51b5;
      text-decoration: none;
      font-weight: 500;
    }

    .signup-link:hover {
      text-decoration: underline;
    }

    @media (max-width: 480px) {
      .login-container {
        padding: 1rem;
      }

      .login-card {
        padding: 1.5rem;
      }

      .form-options {
        flex-direction: column;
        align-items: flex-start;
        gap: 0.5rem;
      }
    }
  `]
})
export class LoginComponent implements OnDestroy {
  loginForm: FormGroup;
  hidePassword = true;
  isLoading = false;
  returnUrl = '/dashboard';
  private destroy$ = new Subject<void>();

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private router: Router,
    private route: ActivatedRoute,
    private snackBar: MatSnackBar
  ) {
    this.loginForm = this.fb.group({
      username: ['', [Validators.required]],
      password: ['', [Validators.required, Validators.minLength(6)]],
      rememberMe: [false]
    });

    // Get return url from route parameters or default to '/dashboard'
    this.returnUrl = this.route.snapshot.queryParams['returnUrl'] || '/dashboard';

    // Redirect if already authenticated
    if (this.authService.isAuthenticated) {
      this.router.navigate([this.returnUrl]);
    }
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  onSubmit(): void {
    if (this.loginForm.valid && !this.isLoading) {
      this.isLoading = true;
      
      const credentials: LoginRequest = {
        username: this.loginForm.get('username')?.value,
        password: this.loginForm.get('password')?.value
      };

      this.authService.login(credentials)
        .pipe(
          takeUntil(this.destroy$),
          finalize(() => this.isLoading = false)
        )
        .subscribe({
          next: (response) => {
            this.snackBar.open('Login successful!', 'Close', {
              duration: 3000,
              panelClass: ['success-snackbar']
            });

            // Navigate based on user role
            if (response.user.roles.includes('ADMIN')) {
              this.router.navigate(['/admin/dashboard']);
            } else if (response.user.roles.includes('INSTRUCTOR')) {
              this.router.navigate(['/instructor/dashboard']);
            } else {
              this.router.navigate([this.returnUrl]);
            }
          },
          error: (error) => {
            this.snackBar.open(error.message || 'Login failed. Please try again.', 'Close', {
              duration: 5000,
              panelClass: ['error-snackbar']
            });
          }
        });
    }
  }

  loginWithGoogle(): void {
    // Placeholder for Google OAuth implementation
    this.snackBar.open('Google login coming soon!', 'Close', {
      duration: 3000
    });
  }
}
