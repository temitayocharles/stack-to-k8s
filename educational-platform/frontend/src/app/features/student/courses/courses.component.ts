import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-courses',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="p-6">
      <h2 class="text-2xl font-bold mb-6">My Courses</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div class="bg-white rounded-lg shadow-md p-4">
          <h3 class="text-lg font-semibold mb-2">Mathematics 101</h3>
          <p class="text-gray-600 mb-4">Basic algebra and calculus concepts</p>
          <div class="flex justify-between items-center">
            <span class="text-sm text-gray-500">Progress: 75%</span>
            <button class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
              Continue
            </button>
          </div>
        </div>
        <div class="bg-white rounded-lg shadow-md p-4">
          <h3 class="text-lg font-semibold mb-2">Physics 201</h3>
          <p class="text-gray-600 mb-4">Classical mechanics and thermodynamics</p>
          <div class="flex justify-between items-center">
            <span class="text-sm text-gray-500">Progress: 45%</span>
            <button class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
              Continue
            </button>
          </div>
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
export class CoursesComponent {
}