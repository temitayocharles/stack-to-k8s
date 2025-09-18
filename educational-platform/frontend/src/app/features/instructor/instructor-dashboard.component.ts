import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-instructor-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="p-6">
      <h2 class="text-2xl font-bold mb-6">Instructor Dashboard</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div class="bg-white rounded-lg shadow-md p-6">
          <h3 class="text-lg font-semibold mb-2">My Courses</h3>
          <p class="text-3xl font-bold text-blue-600">5</p>
          <p class="text-sm text-gray-500">Active courses</p>
        </div>
        <div class="bg-white rounded-lg shadow-md p-6">
          <h3 class="text-lg font-semibold mb-2">Students</h3>
          <p class="text-3xl font-bold text-green-600">127</p>
          <p class="text-sm text-gray-500">Total enrolled</p>
        </div>
        <div class="bg-white rounded-lg shadow-md p-6">
          <h3 class="text-lg font-semibold mb-2">Assignments</h3>
          <p class="text-3xl font-bold text-orange-600">23</p>
          <p class="text-sm text-gray-500">Pending review</p>
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
export class InstructorDashboardComponent {
}