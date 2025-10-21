<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { userStore } from '$lib/stores/user';
  import { connectionStatusStore } from '$lib/stores/websocket';
  
  const dispatch = createEventDispatcher();
  
  function toggleSidebar() {
    dispatch('toggle-sidebar');
  }
</script>

<nav class="navigation">
  <div class="nav-left">
    <button class="sidebar-toggle" on:click={toggleSidebar} aria-label="Toggle sidebar">
      <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M3 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 10a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 15a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd" />
      </svg>
    </button>
    
    <div class="logo">
      <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
        <rect width="32" height="32" rx="8" fill="#3b82f6"/>
        <path d="M8 10h16M8 16h16M8 22h16" stroke="white" stroke-width="2" stroke-linecap="round"/>
      </svg>
      <span class="logo-text">TaskFlow</span>
    </div>
  </div>

  <div class="nav-center">
    <div class="connection-status" class:connected={$connectionStatusStore === 'connected'} class:connecting={$connectionStatusStore === 'connecting'} class:disconnected={$connectionStatusStore === 'disconnected'}>
      <div class="status-indicator"></div>
      <span class="status-text">
        {#if $connectionStatusStore === 'connected'}
          Live
        {:else if $connectionStatusStore === 'connecting'}
          Connecting...
        {:else}
          Offline
        {/if}
      </span>
    </div>
  </div>

  <div class="nav-right">
    {#if $userStore}
      <div class="user-info">
        <div class="user-avatar">
          {#if $userStore.avatar}
            <img src={$userStore.avatar} alt={$userStore.full_name} />
          {:else}
            <div class="avatar-placeholder">
              {$userStore.full_name.charAt(0).toUpperCase()}
            </div>
          {/if}
        </div>
        <div class="user-details">
          <span class="user-name">{$userStore.full_name}</span>
          <span class="user-role">{$userStore.role}</span>
        </div>
      </div>
    {:else}
      <button class="login-btn">Sign In</button>
    {/if}
  </div>
</nav>

<style>
  .navigation {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 1.5rem;
    height: 4rem;
    background: white;
    border-bottom: 1px solid #e2e8f0;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  }

  .nav-left {
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .sidebar-toggle {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 2.5rem;
    height: 2.5rem;
    border: none;
    background: none;
    color: #64748b;
    border-radius: 0.375rem;
    cursor: pointer;
    transition: all 0.2s;
  }

  .sidebar-toggle:hover {
    background: #f1f5f9;
    color: #334155;
  }

  .logo {
    display: flex;
    align-items: center;
    gap: 0.75rem;
  }

  .logo-text {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1e293b;
  }

  .nav-center {
    flex: 1;
    display: flex;
    justify-content: center;
  }

  .connection-status {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.375rem 0.75rem;
    border-radius: 1rem;
    font-size: 0.875rem;
    font-weight: 500;
  }

  .connection-status.connected {
    background: #dcfce7;
    color: #166534;
  }

  .connection-status.connecting {
    background: #fef3c7;
    color: #92400e;
  }

  .connection-status.disconnected {
    background: #fee2e2;
    color: #991b1b;
  }

  .status-indicator {
    width: 0.5rem;
    height: 0.5rem;
    border-radius: 50%;
    background: currentColor;
  }

  .connection-status.connecting .status-indicator {
    animation: pulse 2s infinite;
  }

  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
  }

  .nav-right {
    display: flex;
    align-items: center;
  }

  .user-info {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.5rem;
    border-radius: 0.5rem;
    transition: background 0.2s;
  }

  .user-info:hover {
    background: #f8fafc;
  }

  .user-avatar {
    width: 2rem;
    height: 2rem;
    border-radius: 50%;
    overflow: hidden;
    background: #e2e8f0;
  }

  .user-avatar img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .avatar-placeholder {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    font-weight: 600;
    font-size: 0.875rem;
  }

  .user-details {
    display: flex;
    flex-direction: column;
  }

  .user-name {
    font-weight: 500;
    color: #1e293b;
    font-size: 0.875rem;
  }

  .user-role {
    font-size: 0.75rem;
    color: #64748b;
    text-transform: capitalize;
  }

  .login-btn {
    padding: 0.5rem 1rem;
    background: #3b82f6;
    color: white;
    border: none;
    border-radius: 0.375rem;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;
  }

  .login-btn:hover {
    background: #2563eb;
  }

  @media (max-width: 768px) {
    .navigation {
      padding: 0 1rem;
    }

    .logo-text {
      display: none;
    }

    .user-details {
      display: none;
    }

    .connection-status .status-text {
      display: none;
    }
  }
</style>
