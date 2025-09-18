import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-help',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="p-6">
      <h2 class="text-2xl font-bold mb-6">Help & Support</h2>
      
      <div class="space-y-6">
        <!-- FAQ Section -->
        <div class="bg-white rounded-lg shadow-md p-6">
          <h3 class="text-lg font-semibold mb-4">Frequently Asked Questions</h3>
          <div class="space-y-4">
            <div class="border-b pb-4">
              <h4 class="font-medium mb-2">How do I reset my password?</h4>
              <p class="text-gray-600">Go to the login page and click "Forgot Password". Enter your email address and we'll send you a reset link.</p>
            </div>
            
            <div class="border-b pb-4">
              <h4 class="font-medium mb-2">How do I access my courses?</h4>
              <p class="text-gray-600">Once logged in, navigate to the "Courses" section in the main menu to view all your enrolled courses.</p>
            </div>
            
            <div class="border-b pb-4">
              <h4 class="font-medium mb-2">Where can I view my grades?</h4>
              <p class="text-gray-600">Your grades are available in the "Grades" section of the student dashboard.</p>
            </div>
            
            <div>
              <h4 class="font-medium mb-2">How do I contact my instructor?</h4>
              <p class="text-gray-600">You can contact instructors through the messaging system in each course or via the contact information provided in the course syllabus.</p>
            </div>
          </div>
        </div>

        <!-- Contact Support -->
        <div class="bg-white rounded-lg shadow-md p-6">
          <h3 class="text-lg font-semibold mb-4">Contact Support</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="flex items-center space-x-3">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                  <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 7.89a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                  </svg>
                </div>
              </div>
              <div>
                <p class="font-medium">Email Support</p>
                <p class="text-sm text-gray-500">support&#64;educationalplatform.com</p>
              </div>
            </div>
            
            <div class="flex items-center space-x-3">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                  <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"></path>
                  </svg>
                </div>
              </div>
              <div>
                <p class="font-medium">Phone Support</p>
                <p class="text-sm text-gray-500">1-800-EDU-HELP</p>
                <p class="text-xs text-gray-400">Mon-Fri, 9am-5pm EST</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Resources -->
        <div class="bg-white rounded-lg shadow-md p-6">
          <h3 class="text-lg font-semibold mb-4">Resources</h3>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <a href="#" class="block p-4 border border-gray-200 rounded-lg hover:bg-gray-50">
              <h4 class="font-medium mb-2">User Guide</h4>
              <p class="text-sm text-gray-600">Complete guide to using the platform</p>
            </a>
            
            <a href="#" class="block p-4 border border-gray-200 rounded-lg hover:bg-gray-50">
              <h4 class="font-medium mb-2">Video Tutorials</h4>
              <p class="text-sm text-gray-600">Step-by-step video instructions</p>
            </a>
            
            <a href="#" class="block p-4 border border-gray-200 rounded-lg hover:bg-gray-50">
              <h4 class="font-medium mb-2">System Status</h4>
              <p class="text-sm text-gray-600">Check platform status and updates</p>
            </a>
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
export class HelpComponent {
}