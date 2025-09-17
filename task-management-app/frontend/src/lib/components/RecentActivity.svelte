<script lang="ts">
  import { onMount } from 'svelte';
  
  let activities = [
    {
      id: 1,
      type: 'task_created',
      message: 'New task "Fix login bug" was created',
      user: 'John Doe',
      time: '2 minutes ago'
    },
    {
      id: 2,
      type: 'task_completed',
      message: 'Task "Update documentation" was completed',
      user: 'Jane Smith',
      time: '5 minutes ago'
    },
    {
      id: 3,
      type: 'project_created',
      message: 'New project "Mobile App" was created',
      user: 'Mike Johnson',
      time: '10 minutes ago'
    },
    {
      id: 4,
      type: 'user_joined',
      message: 'Sarah Wilson joined the team',
      user: 'System',
      time: '15 minutes ago'
    }
  ];

  function getActivityIcon(type: string) {
    switch (type) {
      case 'task_created':
        return `<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
          <path fill-rule="evenodd" d="M8 2a1 1 0 011 1v4h4a1 1 0 110 2H9v4a1 1 0 11-2 0V9H3a1 1 0 110-2h4V3a1 1 0 011-1z" clip-rule="evenodd" />
        </svg>`;
      case 'task_completed':
        return `<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
          <path fill-rule="evenodd" d="M8 15A7 7 0 108 1a7 7 0 000 14zm3.844-8.791a.5.5 0 00-.688-.723L7.5 9.44 6.343 8.284a.5.5 0 10-.686.714l1.5 1.5a.5.5 0 00.714 0l4-4z" clip-rule="evenodd" />
        </svg>`;
      case 'project_created':
        return `<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
          <path d="M4 2.5a.5.5 0 01.5-.5H6a.5.5 0 010 1H4.5v1H6a.5.5 0 010 1H4.5v1H6a.5.5 0 010 1H4.5v1H6a.5.5 0 010 1H4.5v1H6a.5.5 0 010 1H4.5v1H6a.5.5 0 010 1H4.5v1H6a.5.5 0 010 1H4.5v1H6a.5.5 0 010 1H4.5v1h7V2.5H4zm8-.5a.5.5 0 01.5.5v11a.5.5 0 01-.5.5H4a.5.5 0 01-.5-.5V2a.5.5 0 01.5-.5h8z"/>
        </svg>`;
      case 'user_joined':
        return `<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
          <path d="M8 8a3 3 0 100-6 3 3 0 000 6zM12.735 14c.618 0 1.093-.561.872-1.139a6.002 6.002 0 00-11.215 0c-.22.578.254 1.139.872 1.139h9.47z"/>
        </svg>`;
      default:
        return `<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
          <path d="M8 1a7 7 0 110 14A7 7 0 018 1z"/>
        </svg>`;
    }
  }

  function getActivityColor(type: string) {
    switch (type) {
      case 'task_created': return '#3b82f6';
      case 'task_completed': return '#10b981';
      case 'project_created': return '#f59e0b';
      case 'user_joined': return '#8b5cf6';
      default: return '#6b7280';
    }
  }
</script>

<div class="recent-activity">
  <h3>Recent Activity</h3>
  
  <div class="activity-list">
    {#each activities as activity}
      <div class="activity-item">
        <div class="activity-icon" style="color: {getActivityColor(activity.type)}">
          {@html getActivityIcon(activity.type)}
        </div>
        <div class="activity-content">
          <p class="activity-message">{activity.message}</p>
          <div class="activity-meta">
            <span class="activity-user">{activity.user}</span>
            <span class="activity-time">{activity.time}</span>
          </div>
        </div>
      </div>
    {/each}
  </div>
</div>

<style>
  .recent-activity h3 {
    margin: 0 0 1rem 0;
    font-size: 1.125rem;
    font-weight: 600;
    color: #1f2937;
  }

  .activity-list {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .activity-item {
    display: flex;
    gap: 0.75rem;
    padding: 0.75rem;
    background: #f8fafc;
    border-radius: 0.5rem;
    border: 1px solid #e5e7eb;
  }

  .activity-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 2rem;
    height: 2rem;
    background: white;
    border-radius: 0.375rem;
    flex-shrink: 0;
    margin-top: 0.125rem;
  }

  .activity-content {
    flex: 1;
    min-width: 0;
  }

  .activity-message {
    margin: 0 0 0.25rem 0;
    font-size: 0.875rem;
    color: #374151;
    line-height: 1.4;
  }

  .activity-meta {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.75rem;
    color: #6b7280;
  }

  .activity-user {
    font-weight: 500;
  }

  .activity-time {
    opacity: 0.8;
  }

  .activity-meta::before {
    content: '•';
    margin: 0 0.25rem;
  }

  .activity-meta > span:first-child::before {
    display: none;
  }
</style>
