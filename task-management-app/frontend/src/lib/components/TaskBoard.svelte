<script lang="ts">
  export let projectId = '';
  
  import { tasksStore } from '$lib/stores/data';
  import { derived } from 'svelte/store';
  
  // Filter tasks by project if specified
  const filteredTasks = derived(tasksStore, ($tasks) => {
    if (!projectId) return $tasks;
    return $tasks.filter(task => task.project_id === projectId);
  });
  
  // Group tasks by status
  const taskColumns = derived(filteredTasks, ($tasks) => {
    const columns = {
      todo: $tasks.filter(task => task.status === 'todo'),
      in_progress: $tasks.filter(task => task.status === 'in_progress'),
      done: $tasks.filter(task => task.status === 'done')
    };
    return columns;
  });

  function getPriorityColor(priority: string) {
    switch (priority) {
      case 'urgent': return '#ef4444';
      case 'high': return '#f97316';
      case 'medium': return '#eab308';
      case 'low': return '#22c55e';
      default: return '#6b7280';
    }
  }

  function formatDate(dateString: string) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  }
</script>

<div class="task-board">
  <h2>Task Board</h2>
  
  <div class="board-columns">
    <!-- To Do Column -->
    <div class="board-column">
      <div class="column-header todo">
        <h3>To Do</h3>
        <span class="task-count">{$taskColumns.todo.length}</span>
      </div>
      <div class="task-list">
        {#each $taskColumns.todo as task}
          <div class="task-card">
            <div class="task-header">
              <div class="task-priority" style="background-color: {getPriorityColor(task.priority)}"></div>
              <h4 class="task-title">{task.title}</h4>
            </div>
            {#if task.description}
              <p class="task-description">{task.description}</p>
            {/if}
            <div class="task-meta">
              {#if task.due_date}
                <span class="task-due-date">Due: {formatDate(task.due_date)}</span>
              {/if}
              {#if task.tags && task.tags.length > 0}
                <div class="task-tags">
                  {#each task.tags as tag}
                    <span class="task-tag">{tag}</span>
                  {/each}
                </div>
              {/if}
            </div>
          </div>
        {/each}
      </div>
    </div>

    <!-- In Progress Column -->
    <div class="board-column">
      <div class="column-header in-progress">
        <h3>In Progress</h3>
        <span class="task-count">{$taskColumns.in_progress.length}</span>
      </div>
      <div class="task-list">
        {#each $taskColumns.in_progress as task}
          <div class="task-card">
            <div class="task-header">
              <div class="task-priority" style="background-color: {getPriorityColor(task.priority)}"></div>
              <h4 class="task-title">{task.title}</h4>
            </div>
            {#if task.description}
              <p class="task-description">{task.description}</p>
            {/if}
            <div class="task-meta">
              {#if task.due_date}
                <span class="task-due-date">Due: {formatDate(task.due_date)}</span>
              {/if}
              {#if task.tags && task.tags.length > 0}
                <div class="task-tags">
                  {#each task.tags as tag}
                    <span class="task-tag">{tag}</span>
                  {/each}
                </div>
              {/if}
            </div>
          </div>
        {/each}
      </div>
    </div>

    <!-- Done Column -->
    <div class="board-column">
      <div class="column-header done">
        <h3>Done</h3>
        <span class="task-count">{$taskColumns.done.length}</span>
      </div>
      <div class="task-list">
        {#each $taskColumns.done as task}
          <div class="task-card">
            <div class="task-header">
              <div class="task-priority" style="background-color: {getPriorityColor(task.priority)}"></div>
              <h4 class="task-title">{task.title}</h4>
            </div>
            {#if task.description}
              <p class="task-description">{task.description}</p>
            {/if}
            <div class="task-meta">
              {#if task.due_date}
                <span class="task-due-date">Due: {formatDate(task.due_date)}</span>
              {/if}
              {#if task.tags && task.tags.length > 0}
                <div class="task-tags">
                  {#each task.tags as tag}
                    <span class="task-tag">{tag}</span>
                  {/each}
                </div>
              {/if}
            </div>
          </div>
        {/each}
      </div>
    </div>
  </div>
</div>

<style>
  .task-board h2 {
    margin: 0 0 1.5rem 0;
    font-size: 1.5rem;
    font-weight: 600;
    color: #1f2937;
  }

  .board-columns {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 1rem;
    height: 500px;
  }

  .board-column {
    display: flex;
    flex-direction: column;
    background: #f8fafc;
    border-radius: 0.5rem;
    overflow: hidden;
  }

  .column-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 1rem;
    font-weight: 600;
    color: white;
  }

  .column-header.todo {
    background: #64748b;
  }

  .column-header.in-progress {
    background: #3b82f6;
  }

  .column-header.done {
    background: #10b981;
  }

  .column-header h3 {
    margin: 0;
    font-size: 1rem;
  }

  .task-count {
    background: rgba(255, 255, 255, 0.2);
    padding: 0.25rem 0.5rem;
    border-radius: 0.25rem;
    font-size: 0.875rem;
  }

  .task-list {
    flex: 1;
    padding: 1rem;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .task-card {
    background: white;
    border-radius: 0.5rem;
    padding: 1rem;
    border: 1px solid #e5e7eb;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    cursor: pointer;
    transition: all 0.2s;
  }

  .task-card:hover {
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    transform: translateY(-1px);
  }

  .task-header {
    display: flex;
    align-items: flex-start;
    gap: 0.5rem;
    margin-bottom: 0.5rem;
  }

  .task-priority {
    width: 0.25rem;
    height: 1rem;
    border-radius: 0.125rem;
    flex-shrink: 0;
    margin-top: 0.125rem;
  }

  .task-title {
    margin: 0;
    font-size: 0.875rem;
    font-weight: 600;
    color: #1f2937;
    line-height: 1.25;
  }

  .task-description {
    margin: 0 0 0.75rem 0;
    font-size: 0.75rem;
    color: #6b7280;
    line-height: 1.4;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  .task-meta {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .task-due-date {
    font-size: 0.75rem;
    color: #6b7280;
  }

  .task-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 0.25rem;
  }

  .task-tag {
    background: #f3f4f6;
    color: #374151;
    padding: 0.125rem 0.375rem;
    border-radius: 0.25rem;
    font-size: 0.625rem;
    font-weight: 500;
  }

  @media (max-width: 768px) {
    .board-columns {
      grid-template-columns: 1fr;
      height: auto;
    }

    .board-column {
      height: 300px;
    }
  }
</style>
