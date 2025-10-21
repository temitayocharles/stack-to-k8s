import { Routes } from '@angular/router';

export const instructorRoutes: Routes = [
  {
    path: '',
    loadComponent: () => import('./instructor-dashboard.component').then(m => m.InstructorDashboardComponent)
  }
];