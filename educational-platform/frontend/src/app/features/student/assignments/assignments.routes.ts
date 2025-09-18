import { Routes } from '@angular/router';

export const assignmentsRoutes: Routes = [
  {
    path: '',
    loadComponent: () => import('./assignments.component').then(m => m.AssignmentsComponent)
  }
];