import { Injectable } from '@angular/core';
import { CanActivate, Router, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';
import { Observable, map, take } from 'rxjs';
import { AuthService } from '../services/auth.service';

@Injectable({
  providedIn: 'root'
})
export class RoleGuard implements CanActivate {
  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): Observable<boolean> | Promise<boolean> | boolean {
    return this.authService.currentUser$.pipe(
      take(1),
      map(user => {
        if (!user || !this.authService.isAuthenticated) {
          this.router.navigate(['/auth/login'], {
            queryParams: { returnUrl: state.url }
          });
          return false;
        }

        // Get required roles from route data
        const requiredRoles = route.data?.['roles'] as string[];
        
        if (!requiredRoles || requiredRoles.length === 0) {
          return true; // No specific roles required
        }

        // Check if user has any of the required roles
        const hasRequiredRole = requiredRoles.some(role => 
          user.roles.includes(role)
        );

        if (!hasRequiredRole) {
          // User doesn't have required role, redirect to appropriate dashboard
          this.redirectToUserDashboard(user.roles);
          return false;
        }

        return true;
      })
    );
  }

  private redirectToUserDashboard(roles: string[]): void {
    if (roles.includes('ADMIN')) {
      this.router.navigate(['/admin/dashboard']);
    } else if (roles.includes('INSTRUCTOR')) {
      this.router.navigate(['/instructor/dashboard']);
    } else if (roles.includes('STUDENT')) {
      this.router.navigate(['/dashboard']);
    } else {
      this.router.navigate(['/']);
    }
  }
}
