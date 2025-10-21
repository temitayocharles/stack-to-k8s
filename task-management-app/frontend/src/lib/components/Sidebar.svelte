<script lang="ts">
  export let open = false;
  
  import { page } from '$app/stores';
  
  const menuItems = [
    { name: 'Dashboard', href: '/', icon: 'dashboard' },
    { name: 'Tasks', href: '/tasks', icon: 'tasks' },
    { name: 'Projects', href: '/projects', icon: 'projects' },
    { name: 'Team', href: '/team', icon: 'team' },
    { name: 'Analytics', href: '/analytics', icon: 'analytics' },
  ];
  
  function isActive(href: string) {
    if (href === '/') {
      return $page.url.pathname === '/';
    }
    return $page.url.pathname.startsWith(href);
  }
</script>

<aside class="sidebar" class:open>
  <div class="sidebar-content">
    <nav class="sidebar-nav">
      <div class="nav-section">
        <h3 class="nav-title">Main</h3>
        <ul class="nav-list">
          {#each menuItems as item}
            <li>
              <a 
                href={item.href} 
                class="nav-link" 
                class:active={isActive(item.href)}
                on:click={() => open = false}
              >
                <span class="nav-icon">
                  {#if item.icon === 'dashboard'}
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                      <path d="M3 4a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1H4a1 1 0 01-1-1V4zM3 12a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1H4a1 1 0 01-1-1v-4zM11 4a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1V4zM11 12a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1v-4z" />
                    </svg>
                  {:else if item.icon === 'tasks'}
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                      <path fill-rule="evenodd" d="M3 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd" />
                    </svg>
                  {:else if item.icon === 'projects'}
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                      <path d="M9 2a1 1 0 000 2h2a1 1 0 100-2H9z" />
                      <path fill-rule="evenodd" d="M4 5a2 2 0 012-2v1a1 1 0 001 1h6a1 1 0 001-1V3a2 2 0 012 2v6a2 2 0 01-2 2H6a2 2 0 01-2-2V5zm3 4a1 1 0 000 2h.01a1 1 0 100-2H7zm3 0a1 1 0 000 2h3a1 1 0 100-2h-3z" clip-rule="evenodd" />
                    </svg>
                  {:else if item.icon === 'team'}
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                      <path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z" />
                    </svg>
                  {:else if item.icon === 'analytics'}
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                      <path d="M2 11a1 1 0 011-1h2a1 1 0 011 1v5a1 1 0 01-1 1H3a1 1 0 01-1-1v-5zM8 7a1 1 0 011-1h2a1 1 0 011 1v9a1 1 0 01-1 1H9a1 1 0 01-1-1V7zM14 4a1 1 0 011-1h2a1 1 0 011 1v12a1 1 0 01-1 1h-2a1 1 0 01-1-1V4z" />
                    </svg>
                  {/if}
                </span>
                <span class="nav-text">{item.name}</span>
              </a>
            </li>
          {/each}
        </ul>
      </div>
    </nav>
  </div>
</aside>

{#if open}
  <div class="sidebar-overlay" on:click={() => open = false}></div>
{/if}

<style>
  .sidebar {
    position: fixed;
    left: 0;
    top: 4rem;
    bottom: 0;
    width: 16rem;
    background: white;
    border-right: 1px solid #e2e8f0;
    transform: translateX(-100%);
    transition: transform 0.3s ease;
    z-index: 40;
    overflow-y: auto;
  }

  .sidebar.open {
    transform: translateX(0);
  }

  .sidebar-content {
    padding: 1.5rem 0;
  }

  .nav-section {
    margin-bottom: 2rem;
  }

  .nav-title {
    margin: 0 0 1rem 1.5rem;
    font-size: 0.75rem;
    font-weight: 600;
    color: #64748b;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .nav-list {
    list-style: none;
    margin: 0;
    padding: 0;
  }

  .nav-link {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.75rem 1.5rem;
    color: #64748b;
    text-decoration: none;
    font-weight: 500;
    transition: all 0.2s;
    border-right: 3px solid transparent;
  }

  .nav-link:hover {
    background: #f8fafc;
    color: #334155;
  }

  .nav-link.active {
    background: #eff6ff;
    color: #3b82f6;
    border-right-color: #3b82f6;
  }

  .nav-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .nav-text {
    flex: 1;
  }

  .sidebar-overlay {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    z-index: 30;
  }

  @media (min-width: 1024px) {
    .sidebar {
      position: static;
      transform: none;
      top: auto;
      bottom: auto;
      z-index: auto;
    }

    .sidebar.open {
      transform: none;
    }

    .sidebar-overlay {
      display: none;
    }
  }
</style>
