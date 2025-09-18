import { Routes } from '@angular/router';

export const coursesRoutes: Routes = [
  {
    path: '',
    loadComponent: () => import('./courses.component').then(m => m.CoursesComponent)
  }
];