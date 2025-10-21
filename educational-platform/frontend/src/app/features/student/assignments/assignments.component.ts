import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-assignments',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="p-6">
      <h2 class="text-2xl font-bold mb-6">Assignments</h2>
      <div class="space-y-4">
        <div class="bg-white rounded-lg shadow-md p-4 border-l-4 border-red-500">
          <div class="flex justify-between items-start">
            <div>
              <h3 class="text-lg font-semibold">Mathematics Quiz 3</h3>
              <p class="text-gray-600">Algebra and quadratic equations</p>
              <p class="text-sm text-gray-500 mt-2">Due: March 15, 2024</p>
            </div>
            <span class="bg-red-100 text-red-800 px-3 py-1 rounded-full text-sm">Overdue</span>
          </div>
        </div>
        
        <div class="bg-white rounded-lg shadow-md p-4 border-l-4 border-yellow-500">
          <div class="flex justify-between items-start">
            <div>
              <h3 class="text-lg font-semibold">Physics Lab Report</h3>
              <p class="text-gray-600">Experiment on pendulum motion</p>
              <p class="text-sm text-gray-500 mt-2">Due: March 20, 2024</p>
            </div>
            <span class="bg-yellow-100 text-yellow-800 px-3 py-1 rounded-full text-sm">Due Soon</span>
          </div>
        </div>
        
        <div class="bg-white rounded-lg shadow-md p-4 border-l-4 border-green-500">
          <div class="flex justify-between items-start">
            <div>
              <h3 class="text-lg font-semibold">History Essay</h3>
              <p class="text-gray-600">World War II impact analysis</p>
              <p class="text-sm text-gray-500 mt-2">Due: March 25, 2024</p>
            </div>
            <span class="bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm">Submitted</span>
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
export class AssignmentsComponent {
}