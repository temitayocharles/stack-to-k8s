import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-settings',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="p-6">
      <h2 class="text-2xl font-bold mb-6">Settings</h2>
      
      <div class="space-y-6">
        <!-- Notifications -->
        <div class="bg-white rounded-lg shadow-md p-6">
          <h3 class="text-lg font-semibold mb-4">Notifications</h3>
          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <div>
                <p class="font-medium">Email notifications</p>
                <p class="text-sm text-gray-500">Receive notifications via email</p>
              </div>
              <input
                type="checkbox"
                [(ngModel)]="settings.emailNotifications"
                class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              >
            </div>
            
            <div class="flex items-center justify-between">
              <div>
                <p class="font-medium">Push notifications</p>
                <p class="text-sm text-gray-500">Receive push notifications in browser</p>
              </div>
              <input
                type="checkbox"
                [(ngModel)]="settings.pushNotifications"
                class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              >
            </div>
          </div>
        </div>

        <!-- Privacy -->
        <div class="bg-white rounded-lg shadow-md p-6">
          <h3 class="text-lg font-semibold mb-4">Privacy</h3>
          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <div>
                <p class="font-medium">Profile visibility</p>
                <p class="text-sm text-gray-500">Make your profile visible to other students</p>
              </div>
              <input
                type="checkbox"
                [(ngModel)]="settings.profileVisible"
                class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              >
            </div>
            
            <div class="flex items-center justify-between">
              <div>
                <p class="font-medium">Show online status</p>
                <p class="text-sm text-gray-500">Let others see when you're online</p>
              </div>
              <input
                type="checkbox"
                [(ngModel)]="settings.showOnlineStatus"
                class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              >
            </div>
          </div>
        </div>

        <!-- Appearance -->
        <div class="bg-white rounded-lg shadow-md p-6">
          <h3 class="text-lg font-semibold mb-4">Appearance</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Theme</label>
              <select
                [(ngModel)]="settings.theme"
                class="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="light">Light</option>
                <option value="dark">Dark</option>
                <option value="auto">Auto</option>
              </select>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Language</label>
              <select
                [(ngModel)]="settings.language"
                class="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="en">English</option>
                <option value="es">Español</option>
                <option value="fr">Français</option>
              </select>
            </div>
          </div>
        </div>

        <div class="flex justify-end">
          <button
            type="button"
            class="bg-blue-500 text-white px-6 py-2 rounded hover:bg-blue-600"
            (click)="saveSettings()"
          >
            Save Settings
          </button>
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
export class SettingsComponent {
  settings = {
    emailNotifications: true,
    pushNotifications: false,
    profileVisible: true,
    showOnlineStatus: true,
    theme: 'light',
    language: 'en'
  };

  saveSettings() {
    console.log('Settings saved:', this.settings);
  }
}