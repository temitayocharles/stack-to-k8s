import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="p-6">
      <h2 class="text-2xl font-bold mb-6">Admin Dashboard</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div class="bg-white rounded-lg shadow-md p-6">
          <h3 class="text-lg font-semibold mb-2">Total Users</h3>
          <p class="text-3xl font-bold text-blue-600">1,247</p>
          <p class="text-sm text-gray-500">+12% from last month</p>
        </div>
        <div class="bg-white rounded-lg shadow-md p-6">
          <h3 class="text-lg font-semibold mb-2">Active Courses</h3>
          <p class="text-3xl font-bold text-green-600">89</p>
          <p class="text-sm text-gray-500">+5% from last month</p>
        </div>
        <div class="bg-white rounded-lg shadow-md p-6">
          <h3 class="text-lg font-semibold mb-2">Revenue</h3>
          <p class="text-3xl font-bold text-purple-600">$47,892</p>
          <p class="text-sm text-gray-500">+8% from last month</p>
        </div>
        <div class="bg-white rounded-lg shadow-md p-6">
          <h3 class="text-lg font-semibold mb-2">Support Tickets</h3>
          <p class="text-3xl font-bold text-orange-600">23</p>
          <p class="text-sm text-gray-500">-15% from last month</p>
        </div>
      </div>
    </div>
  `,
  styles: [`
    :host {
      display: block;
    }
  `]
})
export class AdminDashboardComponent {
}