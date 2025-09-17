<script lang="ts">
  import { onMount } from 'svelte';
  import { user } from '../lib/stores/user';
  import { toast } from '../lib/stores/toast';
  import DashboardStats from '../lib/components/DashboardStats.svelte';
  import QuickActions from '../lib/components/QuickActions.svelte';
  import TaskBoard from '../lib/components/TaskBoard.svelte';
  import RecentActivity from '../lib/components/RecentActivity.svelte';
  import LoadingSpinner from '../lib/components/LoadingSpinner.svelte';
  
  let isLoading = true;
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

  async function loadDashboardData() {
    if (!$user.isAuthenticated) {
      isLoading = false;
      return;
    }

    try {
      const response = await fetch('/api/dashboard', {
        headers: {
          'Authorization': `Bearer ${$user.token}`
        }
      });

      if (!response.ok) {
        throw new Error('Failed to load dashboard data');
      }

      dashboardData = await response.json();
    } catch (error) {
      console.error('Error loading dashboard:', error);
      toast.show('Failed to load dashboard data', 'error');
    } finally {
      isLoading = false;
    }
  }

  onMount(() => {
    loadDashboardData();
    
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
    };
  });
</script>

<svelte:head>
  <title>Dashboard - Task Management</title>
</svelte:head>

<div class="dashboard">
  <div class="dashboard-header">
    <h1>Dashboard</h1>
    <p class="welcome-text">
      Welcome back, {$user.name || 'User'}! Here's what's happening with your tasks.
    </p>
  </div>

  {#if isLoading}
    <div class="loading-container">
      <LoadingSpinner />
      <p>Loading dashboard...</p>
    </div>
  {:else if !$user.isAuthenticated}
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
