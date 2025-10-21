<script lang="ts">
  import '../app.css';
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { websocketStore, connectWebSocket } from '$lib/stores/websocket';
  import { userStore } from '$lib/stores/user';
  import Navigation from '$lib/components/Navigation.svelte';
  import Sidebar from '$lib/components/Sidebar.svelte';
  import Toast from '$lib/components/Toast.svelte';
  import { toastStore } from '$lib/stores/toast';

  let sidebarOpen = false;

  onMount(() => {
    // Initialize WebSocket connection
    connectWebSocket();
    
    // Initialize user from localStorage
    const savedUser = localStorage.getItem('user');
    if (savedUser) {
      userStore.set(JSON.parse(savedUser));
    }
  });

  function toggleSidebar() {
    sidebarOpen = !sidebarOpen;
  }
</script>

<svelte:head>
  <title>TaskFlow - Professional Task Management</title>
  <meta name="description" content="Professional task management application built with Svelte and CouchDB">
</svelte:head>

<div class="app">
  <!-- Navigation -->
  <Navigation on:toggle-sidebar={toggleSidebar} />
  
  <div class="main-container">
    <!-- Sidebar -->
    <Sidebar bind:open={sidebarOpen} />
    
    <!-- Main Content -->
    <main class="main-content" class:with-sidebar={sidebarOpen}>
      <slot />
    </main>
  </div>
</div>

<!-- Toast Notifications -->
{#if $toastStore.length > 0}
  <div class="toast-container">
    {#each $toastStore as toast (toast.id)}
      <Toast {toast} />
    {/each}
  </div>
{/if}

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background-color: #f8fafc;
    color: #334155;
  }

  .app {
    height: 100vh;
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }

  .main-container {
    display: flex;
    flex: 1;
    overflow: hidden;
  }

  .main-content {
    flex: 1;
    padding: 1.5rem;
    overflow-y: auto;
    transition: margin-left 0.3s ease;
  }

  .main-content.with-sidebar {
    margin-left: 0;
  }

  .toast-container {
    position: fixed;
    top: 1rem;
    right: 1rem;
    z-index: 1000;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  @media (max-width: 768px) {
    .main-content {
      padding: 1rem;
    }
  }
</style>
