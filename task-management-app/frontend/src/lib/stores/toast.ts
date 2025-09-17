import { writable } from 'svelte/store';

export interface Toast {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  title: string;
  message?: string;
  duration?: number;
}

export const toastStore = writable<Toast[]>([]);

let toastId = 0;

export function addToast(toast: Omit<Toast, 'id'>) {
  const id = `toast-${++toastId}`;
  const newToast: Toast = {
    id,
    duration: 5000,
    ...toast
  };

  toastStore.update(toasts => [...toasts, newToast]);

  // Auto remove after duration
  if (newToast.duration && newToast.duration > 0) {
    setTimeout(() => {
      removeToast(id);
    }, newToast.duration);
  }

  return id;
}

export function removeToast(id: string) {
  toastStore.update(toasts => toasts.filter(toast => toast.id !== id));
}

// Convenience functions
export function showSuccess(title: string, message?: string) {
  return addToast({ type: 'success', title, message });
}

export function showError(title: string, message?: string) {
  return addToast({ type: 'error', title, message });
}

export function showWarning(title: string, message?: string) {
  return addToast({ type: 'warning', title, message });
}

export function showInfo(title: string, message?: string) {
  return addToast({ type: 'info', title, message });
}
