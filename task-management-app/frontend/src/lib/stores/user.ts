import { writable } from 'svelte/store';
import type { User } from './data';

export const userStore = writable<User | null>(null);

// Authentication helpers
export function loginUser(user: User) {
  userStore.set(user);
  localStorage.setItem('user', JSON.stringify(user));
}

export function logoutUser() {
  userStore.set(null);
  localStorage.removeItem('user');
}

export function updateUser(updatedUser: User) {
  userStore.set(updatedUser);
  localStorage.setItem('user', JSON.stringify(updatedUser));
}
