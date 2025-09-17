import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-not-found',
  standalone: true,
  imports: [CommonModule, RouterModule, MatButtonModule, MatIconModule],
  template: `
    <div class="not-found-container">
      <div class="not-found-content">
        <mat-icon class="not-found-icon">error_outline</mat-icon>
        <h1>404</h1>
        <h2>Page Not Found</h2>
        <p>The page you're looking for doesn't exist or has been moved.</p>
        <div class="actions">
          <button mat-raised-button color="primary" routerLink="/">
            <mat-icon>home</mat-icon>
            Go Home
          </button>
          <button mat-button (click)="goBack()">
            <mat-icon>arrow_back</mat-icon>
            Go Back
          </button>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .not-found-container {
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      padding: 2rem;
      text-align: center;
    }

    .not-found-content {
      max-width: 500px;
    }

    .not-found-icon {
      font-size: 120px;
      width: 120px;
      height: 120px;
      color: #ff6b6b;
      margin-bottom: 1rem;
    }

    h1 {
      font-size: 6rem;
      font-weight: 700;
      margin: 0;
      color: #333;
    }

    h2 {
      font-size: 2rem;
      margin: 0.5rem 0;
      color: #666;
    }

    p {
      font-size: 1.1rem;
      color: #888;
      margin: 1.5rem 0 2rem 0;
      line-height: 1.6;
    }

    .actions {
      display: flex;
      gap: 1rem;
      justify-content: center;
      flex-wrap: wrap;
    }

    button {
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }
  `]
})
export class NotFoundComponent {
  goBack(): void {
    window.history.back();
  }
}
