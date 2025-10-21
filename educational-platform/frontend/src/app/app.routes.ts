import { Routes } from '@angular/router';
import { AuthGuard } from './core/guards/auth.guard';
import { RoleGuard } from './core/guards/role.guard';

export const routes: Routes = [
  // Public routes
  {
    path: '',
    loadComponent: () => import('./features/landing/landing.component').then(m => m.LandingComponent)
  },
  {
    path: 'auth',
    loadChildren: () => import('./features/auth/auth.routes').then(m => m.authRoutes)
  },

  // Student routes
  {
    path: 'dashboard',
    loadComponent: () => import('./features/student/dashboard/dashboard.component').then(m => m.DashboardComponent),
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['STUDENT'] }
  },
  {
    path: 'courses',
    loadChildren: () => import('./features/student/courses/courses.routes').then(m => m.coursesRoutes),
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['STUDENT'] }
  },
  {
    path: 'catalog',
    loadComponent: () => import('./features/student/course-catalog/course-catalog.component').then(m => m.CourseCatalogComponent),
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['STUDENT'] }
  },
  {
    path: 'assignments',
    loadChildren: () => import('./features/student/assignments/assignments.routes').then(m => m.assignmentsRoutes),
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['STUDENT'] }
  },
  {
    path: 'grades',
    loadComponent: () => import('./features/student/grades/grades.component').then(m => m.GradesComponent),
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['STUDENT'] }
  },

  // Instructor routes
  {
    path: 'instructor',
    loadChildren: () => import('./features/instructor/instructor.routes').then(m => m.instructorRoutes),
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['INSTRUCTOR'] }
  },

  // Admin routes
  {
    path: 'admin',
    loadChildren: () => import('./features/admin/admin.routes').then(m => m.adminRoutes),
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['ADMIN'] }
  },

  // Shared authenticated routes
  {
    path: 'profile',
    loadComponent: () => import('./features/profile/profile.component').then(m => m.ProfileComponent),
    canActivate: [AuthGuard]
  },
  {
    path: 'settings',
    loadComponent: () => import('./features/settings/settings.component').then(m => m.SettingsComponent),
    canActivate: [AuthGuard]
  },
  {
    path: 'help',
    loadComponent: () => import('./features/help/help.component').then(m => m.HelpComponent)
  },

  // Fallback routes
  {
    path: '**',
    loadComponent: () => import('./shared/components/not-found/not-found.component').then(m => m.NotFoundComponent)
  }
];
