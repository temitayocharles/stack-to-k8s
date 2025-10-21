<script lang="ts">
  import { onMount } from 'svelte';
  import { userStore } from '../lib/stores/user';
  import { showError } from '../lib/stores/toast';
  import { connectWebSocket, connectionStatusStore } from '../lib/stores/websocket';
  import DashboardStats from '../lib/components/DashboardStats.svelte';
  import QuickActions from '../lib/components/QuickActions.svelte';
  import TaskBoard from '../lib/components/TaskBoard.svelte';
  import RecentActivity from '../lib/components/RecentActivity.svelte';
  import LoadingSpinner from '../lib/components/LoadingSpinner.svelte';
  
  let isLoading = true;
  let connectionStatus = 'disconnected';
  let dashboardData = {
    stats: {
      totalTasks: 0,
      completedTasks: 0,
      pendingTasks: 0,
      overdueTasks: 0
    },
    recentTasks: [],
    upcomingDeadlines: []
  };

  // Subscribe to connection status
  const unsubscribe = connectionStatusStore.subscribe(status => {
    connectionStatus = status;
  });

  async function loadDashboardData() {
    if (!$userStore) {
      isLoading = false;
      return;
    }

    try {
      const response = await fetch('http://localhost:8080/api/v1/dashboard/stats');

      if (!response.ok) {
        throw new Error('Failed to load dashboard data');
      }

      const stats = await response.json();
      dashboardData.stats = {
        totalTasks: stats.total_tasks || 0,
        completedTasks: stats.completed_tasks || 0,
        pendingTasks: (stats.total_tasks || 0) - (stats.completed_tasks || 0),
        overdueTasks: 0 // We'll calculate this from task data
      };
    } catch (error) {
      console.error('Error loading dashboard:', error);
      showError('Failed to load dashboard data', 'Please try again later');
    } finally {
      isLoading = false;
    }
  }

  onMount(() => {
    loadDashboardData();
    
    // Connect to WebSocket for real-time updates
    connectWebSocket();
    
    // Listen for task updates to refresh dashboard
    const handleTaskUpdate = () => {
      loadDashboardData();
    };

    window.addEventListener('taskCreated', handleTaskUpdate);
    window.addEventListener('taskUpdated', handleTaskUpdate);
    window.addEventListener('taskDeleted', handleTaskUpdate);

    return () => {
      window.removeEventListener('taskCreated', handleTaskUpdate);
      window.removeEventListener('taskUpdated', handleTaskUpdate);
      window.removeEventListener('taskDeleted', handleTaskUpdate);
      unsubscribe();
    };
  });
</script>

<svelte:head>
  <title>Dashboard - Task Management</title>
</svelte:head>

<div class="dashboard">
  <div class="dashboard-header">
    <div class="header-content">
      <div>
        <h1>Dashboard</h1>
        <p class="welcome-text">
          Welcome back, {$userStore?.name || 'User'}! Here's what's happening with your tasks.
        </p>
      </div>
      <div class="connection-status">
        <div class="status-indicator status-{connectionStatus}">
          <span class="status-dot"></span>
          <span class="status-text">
            {#if connectionStatus === 'connected'}
              Real-time Connected
            {:else if connectionStatus === 'connecting'}
              Connecting...
            {:else}
              Offline
            {/if}
          </span>
        </div>
      </div>
    </div>
  </div>

  {#if isLoading}
    <div class="loading-container">
      <LoadingSpinner />
      <p>Loading dashboard...</p>
    </div>
  {:else if !$userStore}
    <div class="auth-required">
      <h2>Please Log In</h2>
      <p>You need to log in to view your dashboard.</p>
      <a href="/login" class="login-link">Go to Login</a>
    </div>
  {:else}
    <div class="dashboard-content">
      <!-- Stats Overview -->
      <section class="stats-section">
        <DashboardStats stats={dashboardData.stats} />
      </section>

      <!-- Quick Actions -->
      <section class="actions-section">
        <QuickActions />
      </section>

      <!-- Task Board Preview -->
      <section class="board-section">
        <h2>Task Board</h2>
        <TaskBoard />
      </section>

      <!-- Recent Activity -->
      <section class="activity-section">
        <RecentActivity />
      </section>

      <!-- Upcoming Deadlines -->
      <section class="deadlines-section">
        <h2>Upcoming Deadlines</h2>
        {#if dashboardData.upcomingDeadlines.length > 0}
          <div class="deadlines-list">
            {#each dashboardData.upcomingDeadlines as task}
              <div class="deadline-item">
                <div class="task-info">
                  <h3>{task.title}</h3>
                  <p>{task.description || 'No description'}</p>
                </div>
                <div class="deadline-info">
                  <span class="due-date" class:overdue={new Date(task.dueDate) < new Date()}>
                    {new Date(task.dueDate).toLocaleDateString()}
                  </span>
                  <span class="priority priority-{task.priority}">{task.priority}</span>
                </div>
              </div>
            {/each}
          </div>
        {:else}
          <div class="empty-state">
            <p>No upcoming deadlines</p>
          </div>
        {/if}
      </section>
    </div>
  {/if}
</div>

<style>
  .dashboard {
    padding: 2rem;
    max-width: 1200px;
    margin: 0 auto;
  }

  .dashboard-header {
    margin-bottom: 2rem;
  }

  .header-content {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
  }

  .dashboard-header h1 {
    margin: 0 0 0.5rem 0;
    font-size: 2rem;
    font-weight: 700;
    color: #111827;
  }

  .welcome-text {
    margin: 0;
    color: #6b7280;
    font-size: 1rem;
  }

  .connection-status {
    display: flex;
    align-items: center;
  }

  .status-indicator {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    border-radius: 0.5rem;
    font-size: 0.875rem;
    font-weight: 500;
  }

  .status-connected {
    background: #dcfce7;
    color: #166534;
  }

  .status-connecting {
    background: #fef3c7;
    color: #92400e;
  }

  .status-disconnected {
    background: #fee2e2;
    color: #991b1b;
  }

  .status-dot {
    width: 0.5rem;
    height: 0.5rem;
    border-radius: 50%;
    background: currentColor;
    animation: pulse 2s infinite;
  }

  .status-connected .status-dot {
    animation: none;
  }

  @keyframes pulse {
    0%, 100% {
      opacity: 1;
    }
    50% {
      opacity: 0.5;
    }
  }

  .loading-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 4rem;
    gap: 1rem;
  }

  .loading-container p {
    color: #6b7280;
    margin: 0;
  }

  .auth-required {
    text-align: center;
    padding: 4rem 2rem;
    background: #f9fafb;
    border-radius: 1rem;
    border: 2px dashed #d1d5db;
  }

  .auth-required h2 {
    margin: 0 0 1rem 0;
    color: #374151;
  }

  .auth-required p {
    margin: 0 0 2rem 0;
    color: #6b7280;
  }

  .login-link {
    display: inline-flex;
    align-items: center;
    padding: 0.75rem 1.5rem;
    background: #3b82f6;
    color: white;
    text-decoration: none;
    border-radius: 0.5rem;
    font-weight: 500;
    transition: background-color 0.2s;
  }

  .login-link:hover {
    background: #2563eb;
  }

  .dashboard-content {
    display: grid;
    grid-template-columns: 1fr;
    gap: 2rem;
  }

  .stats-section {
    grid-column: 1 / -1;
  }

  .actions-section {
    grid-column: 1 / -1;
  }

  .board-section,
  .activity-section,
  .deadlines-section {
    background: white;
    border-radius: 1rem;
    padding: 1.5rem;
    border: 1px solid #e5e7eb;
  }

  .board-section h2,
  .deadlines-section h2 {
    margin: 0 0 1.5rem 0;
    font-size: 1.25rem;
    font-weight: 600;
    color: #111827;
  }

  .deadlines-list {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .deadline-item {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    padding: 1rem;
    background: #f8fafc;
    border-radius: 0.5rem;
    border: 1px solid #e5e7eb;
  }

  .task-info h3 {
    margin: 0 0 0.25rem 0;
    font-size: 0.875rem;
    font-weight: 600;
    color: #111827;
  }

  .task-info p {
    margin: 0;
    font-size: 0.75rem;
    color: #6b7280;
    line-height: 1.4;
  }

  .deadline-info {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 0.25rem;
  }

  .due-date {
    font-size: 0.75rem;
    font-weight: 500;
    color: #374151;
  }

  .due-date.overdue {
    color: #dc2626;
  }

  .priority {
    font-size: 0.625rem;
    padding: 0.125rem 0.5rem;
    border-radius: 9999px;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .priority-low {
    background: #dcfce7;
    color: #166534;
  }

  .priority-medium {
    background: #fef3c7;
    color: #92400e;
  }

  .priority-high {
    background: #fed7aa;
    color: #9a3412;
  }

  .priority-urgent {
    background: #fecaca;
    color: #991b1b;
  }

  .empty-state {
    text-align: center;
    padding: 2rem;
    color: #6b7280;
  }

  .empty-state p {
    margin: 0;
  }

  /* Responsive Grid Layout */
  @media (min-width: 768px) {
    .dashboard-content {
      grid-template-columns: 2fr 1fr;
    }

    .board-section {
      grid-column: 1;
      grid-row: 3;
    }

    .activity-section {
      grid-column: 2;
      grid-row: 3;
    }

    .deadlines-section {
      grid-column: 1 / -1;
      grid-row: 4;
    }
  }

  @media (min-width: 1024px) {
    .dashboard-content {
      grid-template-columns: 2fr 1fr 1fr;
    }

    .stats-section {
      grid-column: 1 / -1;
    }

    .actions-section {
      grid-column: 1 / -1;
    }

    .board-section {
      grid-column: 1 / 3;
      grid-row: 3;
    }

    .activity-section {
      grid-column: 3;
      grid-row: 3;
    }

    .deadlines-section {
      grid-column: 1 / -1;
      grid-row: 4;
    }
  }

  @media (max-width: 640px) {
    .dashboard {
      padding: 1rem;
    }

    .deadline-item {
      flex-direction: column;
      gap: 0.75rem;
    }

    .deadline-info {
      align-items: flex-start;
      flex-direction: row;
      gap: 0.5rem;
    }
  }
</style>
