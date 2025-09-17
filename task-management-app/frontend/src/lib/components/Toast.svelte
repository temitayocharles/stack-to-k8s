<script lang="ts">
  import { onMount } from 'svelte';
  import { removeToast, type Toast } from '$lib/stores/toast';

  export let toast: Toast;

  let element: HTMLDivElement;

  onMount(() => {
    // Auto-remove after duration if specified
    if (toast.duration && toast.duration > 0) {
      setTimeout(() => {
        removeToast(toast.id);
      }, toast.duration);
    }
  });

  function handleClose() {
    removeToast(toast.id);
  }

  function getIcon(type: string) {
    switch (type) {
      case 'success':
        return `<svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
        </svg>`;
      case 'error':
        return `<svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
        </svg>`;
      case 'warning':
        return `<svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
        </svg>`;
      case 'info':
      default:
        return `<svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
        </svg>`;
    }
  }
</script>

<div 
  bind:this={element}
  class="toast toast-{toast.type}"
  role="alert"
>
  <div class="toast-content">
    <div class="toast-icon">
      {@html getIcon(toast.type)}
    </div>
    
    <div class="toast-body">
      <div class="toast-title">{toast.title}</div>
      {#if toast.message}
        <div class="toast-message">{toast.message}</div>
      {/if}
    </div>
    
    <button class="toast-close" on:click={handleClose} aria-label="Close notification">
      <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
        <path d="M12.854 4.854a.5.5 0 00-.708-.708L8 8.293 3.854 4.146a.5.5 0 10-.708.708L7.293 9l-4.147 4.146a.5.5 0 00.708.708L8 9.707l4.146 4.147a.5.5 0 00.708-.708L8.707 9l4.147-4.146z"/>
      </svg>
    </button>
  </div>
</div>

<style>
  .toast {
    max-width: 24rem;
    background: white;
    border-radius: 0.5rem;
    padding: 1rem;
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
    border-left: 4px solid;
    animation: slideIn 0.3s ease-out;
  }

  @keyframes slideIn {
    from {
      transform: translateX(100%);
      opacity: 0;
    }
    to {
      transform: translateX(0);
      opacity: 1;
    }
  }

  .toast-success {
    border-left-color: #10b981;
  }

  .toast-error {
    border-left-color: #ef4444;
  }

  .toast-warning {
    border-left-color: #f59e0b;
  }

  .toast-info {
    border-left-color: #3b82f6;
  }

  .toast-content {
    display: flex;
    align-items: flex-start;
    gap: 0.75rem;
  }

  .toast-icon {
    flex-shrink: 0;
    margin-top: 0.125rem;
  }

  .toast-success .toast-icon {
    color: #10b981;
  }

  .toast-error .toast-icon {
    color: #ef4444;
  }

  .toast-warning .toast-icon {
    color: #f59e0b;
  }

  .toast-info .toast-icon {
    color: #3b82f6;
  }

  .toast-body {
    flex: 1;
    min-width: 0;
  }

  .toast-title {
    font-weight: 600;
    color: #1f2937;
    margin-bottom: 0.25rem;
  }

  .toast-message {
    color: #6b7280;
    font-size: 0.875rem;
    line-height: 1.4;
  }

  .toast-close {
    flex-shrink: 0;
    background: none;
    border: none;
    color: #9ca3af;
    cursor: pointer;
    padding: 0.25rem;
    border-radius: 0.25rem;
    transition: color 0.2s;
  }

  .toast-close:hover {
    color: #6b7280;
    background: #f3f4f6;
  }
</style>
