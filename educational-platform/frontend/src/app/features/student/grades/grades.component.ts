import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-grades',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="p-6">
      <h2 class="text-2xl font-bold mb-6">Grades</h2>
      <div class="bg-white rounded-lg shadow-md overflow-hidden">
        <table class="w-full">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Course</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Assignment</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Grade</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">Mathematics 101</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">Quiz 2</td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="inline-flex px-2 py-1 text-xs font-semibold bg-green-100 text-green-800 rounded-full">A-</span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">Mar 10, 2024</td>
            </tr>
            <tr>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">Physics 201</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">Lab Report 1</td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="inline-flex px-2 py-1 text-xs font-semibold bg-blue-100 text-blue-800 rounded-full">B+</span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">Mar 8, 2024</td>
            </tr>
            <tr>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">History 150</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">Essay 1</td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="inline-flex px-2 py-1 text-xs font-semibold bg-green-100 text-green-800 rounded-full">A</span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">Mar 5, 2024</td>
            </tr>
          </tbody>
        </table>
      </div>
      
      <div class="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="bg-white p-4 rounded-lg shadow-md">
          <h3 class="text-lg font-semibold text-gray-900">Overall GPA</h3>
          <p class="text-3xl font-bold text-blue-600">3.7</p>
        </div>
        <div class="bg-white p-4 rounded-lg shadow-md">
          <h3 class="text-lg font-semibold text-gray-900">Credits Completed</h3>
          <p class="text-3xl font-bold text-green-600">45</p>
        </div>
        <div class="bg-white p-4 rounded-lg shadow-md">
          <h3 class="text-lg font-semibold text-gray-900">Credits Remaining</h3>
          <p class="text-3xl font-bold text-orange-600">75</p>
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
export class GradesComponent {
}