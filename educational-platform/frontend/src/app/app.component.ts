import { Component, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet, RouterModule } from '@angular/router';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSidenavModule, MatSidenav } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatMenuModule } from '@angular/material/menu';
import { MatBadgeModule } from '@angular/material/badge';
import { Observable } from 'rxjs';
import { AuthService } from './core/services/auth.service';
import { User } from './shared/models/user.model';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    CommonModule,
    RouterOutlet,
    RouterModule,
    MatToolbarModule,
    MatButtonModule,
    MatIconModule,
    MatSidenavModule,
    MatListModule,
    MatMenuModule,
    MatBadgeModule
  ],
  template: `
    <div class="app-container">
      <mat-toolbar color="primary" class="app-toolbar">
        <div class="toolbar-content">
          <div class="logo-section">
            <button 
              mat-icon-button 
              (click)="sidenav.toggle()" 
              *ngIf="currentUser$ | async"
              class="menu-button">
              <mat-icon>menu</mat-icon>
            </button>
            <h1 class="app-title" routerLink="/">
              <mat-icon class="logo-icon">school</mat-icon>
              EduPlatform
            </h1>
          </div>

          <div class="toolbar-actions" *ngIf="currentUser$ | async as user">
            <button mat-icon-button [matMenuTriggerFor]="notificationMenu">
              <mat-icon matBadge="3" matBadgeColor="accent">notifications</mat-icon>
            </button>
            
            <button mat-icon-button [matMenuTriggerFor]="userMenu">
              <mat-icon>account_circle</mat-icon>
            </button>

            <!-- Notification Menu -->
            <mat-menu #notificationMenu="matMenu">
              <button mat-menu-item>
                <mat-icon>assignment</mat-icon>
                <span>New assignment due tomorrow</span>
              </button>
              <button mat-menu-item>
                <mat-icon>quiz</mat-icon>
                <span>Quiz results available</span>
              </button>
              <button mat-menu-item>
                <mat-icon>announcement</mat-icon>
                <span>Course announcement</span>
              </button>
              <mat-divider></mat-divider>
              <button mat-menu-item>
                <span>View all notifications</span>
              </button>
            </mat-menu>

            <!-- User Menu -->
            <mat-menu #userMenu="matMenu">
              <div class="user-info">
                <p class="user-name">{{ user.firstName }} {{ user.lastName }}</p>
                <p class="user-role">{{ user.roles[0] | titlecase }}</p>
              </div>
              <mat-divider></mat-divider>
              <button mat-menu-item routerLink="/profile">
                <mat-icon>person</mat-icon>
                <span>Profile</span>
              </button>
              <button mat-menu-item routerLink="/settings">
                <mat-icon>settings</mat-icon>
                <span>Settings</span>
              </button>
              <mat-divider></mat-divider>
              <button mat-menu-item (click)="logout()">
                <mat-icon>logout</mat-icon>
                <span>Logout</span>
              </button>
            </mat-menu>
          </div>

          <!-- Login/Register buttons for guests -->
          <div class="auth-buttons" *ngIf="!(currentUser$ | async)">
            <button mat-button routerLink="/auth/login">Login</button>
            <button mat-raised-button color="accent" routerLink="/auth/register">
              Register
            </button>
          </div>
        </div>
      </mat-toolbar>

      <div class="app-content">
        <mat-sidenav-container class="sidenav-container" *ngIf="currentUser$ | async as user">
          <mat-sidenav 
            #sidenav 
            mode="side" 
            opened="true" 
            class="app-sidenav">
            <mat-nav-list>
              <!-- Student Navigation -->
              <ng-container *ngIf="user.roles.includes('STUDENT')">
                <a mat-list-item routerLink="/dashboard" routerLinkActive="active">
                  <mat-icon matListItemIcon>dashboard</mat-icon>
                  <span matListItemTitle>Dashboard</span>
                </a>
                <a mat-list-item routerLink="/courses" routerLinkActive="active">
                  <mat-icon matListItemIcon>book</mat-icon>
                  <span matListItemTitle>My Courses</span>
                </a>
                <a mat-list-item routerLink="/catalog" routerLinkActive="active">
                  <mat-icon matListItemIcon>search</mat-icon>
                  <span matListItemTitle>Course Catalog</span>
                </a>
                <a mat-list-item routerLink="/assignments" routerLinkActive="active">
                  <mat-icon matListItemIcon>assignment</mat-icon>
                  <span matListItemTitle>Assignments</span>
                </a>
                <a mat-list-item routerLink="/grades" routerLinkActive="active">
                  <mat-icon matListItemIcon>grade</mat-icon>
                  <span matListItemTitle>Grades</span>
                </a>
              </ng-container>

              <!-- Instructor Navigation -->
              <ng-container *ngIf="user.roles.includes('INSTRUCTOR')">
                <a mat-list-item routerLink="/instructor/dashboard" routerLinkActive="active">
                  <mat-icon matListItemIcon>dashboard</mat-icon>
                  <span matListItemTitle>Dashboard</span>
                </a>
                <a mat-list-item routerLink="/instructor/courses" routerLinkActive="active">
                  <mat-icon matListItemIcon>school</mat-icon>
                  <span matListItemTitle>My Courses</span>
                </a>
                <a mat-list-item routerLink="/instructor/create-course" routerLinkActive="active">
                  <mat-icon matListItemIcon>add_circle</mat-icon>
                  <span matListItemTitle>Create Course</span>
                </a>
                <a mat-list-item routerLink="/instructor/students" routerLinkActive="active">
                  <mat-icon matListItemIcon>people</mat-icon>
                  <span matListItemTitle>Students</span>
                </a>
                <a mat-list-item routerLink="/instructor/analytics" routerLinkActive="active">
                  <mat-icon matListItemIcon>analytics</mat-icon>
                  <span matListItemTitle>Analytics</span>
                </a>
              </ng-container>

              <!-- Admin Navigation -->
              <ng-container *ngIf="user.roles.includes('ADMIN')">
                <a mat-list-item routerLink="/admin/dashboard" routerLinkActive="active">
                  <mat-icon matListItemIcon>admin_panel_settings</mat-icon>
                  <span matListItemTitle>Admin Dashboard</span>
                </a>
                <a mat-list-item routerLink="/admin/users" routerLinkActive="active">
                  <mat-icon matListItemIcon>supervisor_account</mat-icon>
                  <span matListItemTitle>User Management</span>
                </a>
                <a mat-list-item routerLink="/admin/courses" routerLinkActive="active">
                  <mat-icon matListItemIcon>library_books</mat-icon>
                  <span matListItemTitle>Course Management</span>
                </a>
                <a mat-list-item routerLink="/admin/reports" routerLinkActive="active">
                  <mat-icon matListItemIcon>assessment</mat-icon>
                  <span matListItemTitle>Reports</span>
                </a>
                <a mat-list-item routerLink="/admin/settings" routerLinkActive="active">
                  <mat-icon matListItemIcon>settings</mat-icon>
                  <span matListItemTitle>System Settings</span>
                </a>
              </ng-container>

              <mat-divider></mat-divider>
              
              <!-- Common Navigation -->
              <a mat-list-item routerLink="/help" routerLinkActive="active">
                <mat-icon matListItemIcon>help</mat-icon>
                <span matListItemTitle>Help & Support</span>
              </a>
            </mat-nav-list>
          </mat-sidenav>

          <mat-sidenav-content class="main-content">
            <router-outlet></router-outlet>
          </mat-sidenav-content>
        </mat-sidenav-container>

        <!-- Content for non-authenticated users -->
        <div class="guest-content" *ngIf="!(currentUser$ | async)">
          <router-outlet></router-outlet>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .app-container {
      height: 100vh;
      display: flex;
      flex-direction: column;
    }

    .app-toolbar {
      position: sticky;
      top: 0;
      z-index: 1000;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

    .toolbar-content {
      width: 100%;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .logo-section {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .app-title {
      font-size: 1.5rem;
      font-weight: 500;
      cursor: pointer;
      text-decoration: none;
      color: inherit;
      display: flex;
      align-items: center;
      gap: 8px;
      margin: 0;
    }

    .logo-icon {
      font-size: 1.8rem;
    }

    .menu-button {
      margin-right: 8px;
    }

    .toolbar-actions {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .auth-buttons {
      display: flex;
      gap: 8px;
    }

    .app-content {
      flex: 1;
      display: flex;
      overflow: hidden;
    }

    .sidenav-container {
      flex: 1;
    }

    .app-sidenav {
      width: 280px;
      background: #fafafa;
      border-right: 1px solid #e0e0e0;
    }

    .main-content {
      padding: 24px;
      background: #f5f5f5;
      overflow-y: auto;
    }

    .guest-content {
      flex: 1;
      overflow-y: auto;
    }

    .user-info {
      padding: 12px 16px;
      border-bottom: 1px solid #e0e0e0;
      margin-bottom: 8px;
    }

    .user-name {
      font-weight: 500;
      margin: 0 0 4px 0;
    }

    .user-role {
      font-size: 0.875rem;
      color: #666;
      margin: 0;
    }

    mat-nav-list a.active {
      background: rgba(63, 81, 181, 0.1);
      color: #3f51b5;
    }

    mat-nav-list a.active mat-icon {
      color: #3f51b5;
    }

    @media (max-width: 768px) {
      .app-sidenav {
        width: 100%;
      }
      
      .main-content {
        padding: 16px;
      }
      
      .app-title {
        font-size: 1.25rem;
      }
    }
  `]
})
export class AppComponent {
  title = 'Educational Platform';
  currentUser$: Observable<User | null>;
  
  @ViewChild('sidenav') sidenav!: MatSidenav;

  constructor(private authService: AuthService) {
    this.currentUser$ = this.authService.currentUser$;
  }

  logout(): void {
    this.authService.logout();
  }
}
