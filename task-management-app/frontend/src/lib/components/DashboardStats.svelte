<script lang="ts">
  import { onMount } from 'svelte';
  import { taskService } from '$lib/services/taskService';
  
  let stats = {
    total_tasks: 0,
    total_users: 0,
    total_projects: 0,
    task_breakdown: { todo: 0, in_progress: 0, done: 0 },
    priority_breakdown: { low: 0, medium: 0, high: 0, urgent: 0 }
  };

  onMount(async () => {
    try {
      stats = await taskService.getDashboardStats();
    } catch (error) {
      console.error('Failed to load dashboard stats:', error);
    }
  });
</script>

<div class="stats-grid">
  <div class="stat-card primary">
    <div class="stat-icon">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
        <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
      </svg>
    </div>
    <div class="stat-content">
      <div class="stat-number">{stats.total_tasks}</div>
      <div class="stat-label">Total Tasks</div>
    </div>
  </div>

  <div class="stat-card success">
    <div class="stat-icon">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
        <path d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20a3 3 0 01-3-3v-2a3 3 0 013-3h10a3 3 0 013 3v2a3 3 0 01-3 3zM12 12a3 3 0 110-6 3 3 0 010 6z"/>
      </svg>
    </div>
    <div class="stat-content">
      <div class="stat-number">{stats.total_users}</div>
      <div class="stat-label">Team Members</div>
    </div>
  </div>

  <div class="stat-card warning">
    <div class="stat-icon">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
        <path d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
      </svg>
    </div>
    <div class="stat-content">
      <div class="stat-number">{stats.total_projects}</div>
      <div class="stat-label">Active Projects</div>
    </div>
  </div>

  <div class="stat-card info">
    <div class="stat-icon">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
        <path d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
      </svg>
    </div>
    <div class="stat-content">
      <div class="stat-number">{stats.task_breakdown.in_progress}</div>
      <div class="stat-label">In Progress</div>
    </div>
  </div>
</div>

<style>
  .stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
    margin-bottom: 2rem;
  }

  .stat-card {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 1.5rem;
    background: white;
    border-radius: 0.75rem;
    border: 1px solid #e5e7eb;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  }

  .stat-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 3rem;
    height: 3rem;
    border-radius: 0.75rem;
  }

  .stat-card.primary .stat-icon {
    background: #dbeafe;
    color: #2563eb;
  }

  .stat-card.success .stat-icon {
    background: #dcfce7;
    color: #16a34a;
  }

  .stat-card.warning .stat-icon {
    background: #fef3c7;
    color: #d97706;
  }

  .stat-card.info .stat-icon {
    background: #f0f9ff;
    color: #0284c7;
  }

  .stat-content {
    flex: 1;
  }

  .stat-number {
    font-size: 2rem;
    font-weight: 700;
    color: #1f2937;
    line-height: 1;
  }

  .stat-label {
    color: #6b7280;
    font-size: 0.875rem;
    font-weight: 500;
    margin-top: 0.25rem;
  }

  @media (max-width: 640px) {
    .stats-grid {
      grid-template-columns: 1fr;
    }
    
    .stat-card {
      padding: 1rem;
    }
    
    .stat-number {
      font-size: 1.5rem;
    }
  }
</style>
