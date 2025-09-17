<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { user } from '../../lib/stores/user';
  import { toast } from '../../lib/stores/toast';
  import TaskBoard from '../../lib/components/TaskBoard.svelte';
  import CreateTaskModal from '../../lib/components/CreateTaskModal.svelte';
  import LoadingSpinner from '../../lib/components/LoadingSpinner.svelte';
  
  let isLoading = true;
  let tasks = [];
  let projects = [];
  let users = [];
  let selectedProject = '';
  let selectedStatus = '';
  let selectedAssignee = '';
  let searchQuery = '';
  let sortBy = 'created_at';
  let sortOrder = 'desc';
  let viewMode = 'board'; // 'board' or 'list'

  $: filteredTasks = tasks.filter(task => {
    let matches = true;
    
    if (selectedProject && task.projectId !== selectedProject) matches = false;
    if (selectedStatus && task.status !== selectedStatus) matches = false;
    if (selectedAssignee && task.assigneeId !== selectedAssignee) matches = false;
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      matches = matches && (
        task.title.toLowerCase().includes(query) ||
        task.description.toLowerCase().includes(query)
      );
    }
    
    return matches;
  }).sort((a, b) => {
    let aVal = a[sortBy];
    let bVal = b[sortBy];
    
    if (sortBy === 'created_at' || sortBy === 'updated_at' || sortBy === 'dueDate') {
      aVal = new Date(aVal);
      bVal = new Date(bVal);
    }
    
    if (sortOrder === 'asc') {
      return aVal > bVal ? 1 : -1;
    } else {
      return aVal < bVal ? 1 : -1;
    }
  });

  async function loadData() {
    if (!$user.isAuthenticated) {
      isLoading = false;
      return;
    }

    try {
      const [tasksRes, projectsRes, usersRes] = await Promise.all([
        fetch('/api/tasks', {
          headers: { 'Authorization': `Bearer ${$user.token}` }
        }),
        fetch('/api/projects', {
          headers: { 'Authorization': `Bearer ${$user.token}` }
        }),
        fetch('/api/users', {
          headers: { 'Authorization': `Bearer ${$user.token}` }
        })
      ]);

      if (tasksRes.ok) tasks = await tasksRes.json();
      if (projectsRes.ok) projects = await projectsRes.json();
      if (usersRes.ok) users = await usersRes.json();
    } catch (error) {
      console.error('Error loading data:', error);
      toast.show('Failed to load tasks', 'error');
    } finally {
      isLoading = false;
    }
  }

  async function deleteTask(taskId: string) {
    if (!confirm('Are you sure you want to delete this task?')) return;

    try {
      const response = await fetch(`/api/tasks/${taskId}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${$user.token}` }
      });

      if (!response.ok) throw new Error('Failed to delete task');

      tasks = tasks.filter(t => t.id !== taskId);
      toast.show('Task deleted successfully', 'success');
    } catch (error) {
      console.error('Error deleting task:', error);
      toast.show('Failed to delete task', 'error');
    }
  }

  async function updateTaskStatus(taskId: string, newStatus: string) {
    try {
      const response = await fetch(`/api/tasks/${taskId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${$user.token}`
        },
        body: JSON.stringify({ status: newStatus })
      });

      if (!response.ok) throw new Error('Failed to update task');

      const updatedTask = await response.json();
      tasks = tasks.map(t => t.id === taskId ? updatedTask : t);
      toast.show('Task status updated', 'success');
    } catch (error) {
      console.error('Error updating task:', error);
      toast.show('Failed to update task', 'error');
    }
  }

  function getProjectName(projectId: string) {
    const project = projects.find(p => p.id === projectId);
    return project ? project.name : 'No Project';
  }

  function getUserName(userId: string) {
    const user = users.find(u => u.id === userId);
    return user ? user.name : 'Unassigned';
  }

  function getPriorityColor(priority: string) {
    switch (priority) {
      case 'urgent': return '#dc2626';
      case 'high': return '#ea580c';
      case 'medium': return '#d97706';
      case 'low': return '#65a30d';
      default: return '#6b7280';
    }
  }

  function getStatusColor(status: string) {
    switch (status) {
      case 'completed': return '#059669';
      case 'in_progress': return '#0284c7';
      case 'review': return '#7c3aed';
      case 'pending': return '#6b7280';
      default: return '#6b7280';
    }
  }

  function handleTaskCreated() {
    loadData();
  }

  onMount(() => {
    loadData();
    
    window.addEventListener('taskCreated', handleTaskCreated);
    window.addEventListener('taskUpdated', handleTaskCreated);
    window.addEventListener('taskDeleted', handleTaskCreated);
  });

  onDestroy(() => {
    window.removeEventListener('taskCreated', handleTaskCreated);
    window.removeEventListener('taskUpdated', handleTaskCreated);
    window.removeEventListener('taskDeleted', handleTaskCreated);
  });
</script>

<svelte:head>
  <title>Tasks - Task Management</title>
</svelte:head>

<div class="tasks-page">
  <div class="page-header">
    <div class="header-content">
      <h1>Tasks</h1>
      <p>Manage and track your tasks across all projects</p>
    </div>
    <div class="header-actions">
      <CreateTaskModal />
    </div>
  </div>

  {#if isLoading}
    <div class="loading-container">
      <LoadingSpinner />
      <p>Loading tasks...</p>
    </div>
  {:else if !$user.isAuthenticated}
    <div class="auth-required">
      <h2>Please Log In</h2>
      <p>You need to log in to view your tasks.</p>
      <a href="/login" class="login-link">Go to Login</a>
    </div>
  {:else}
    <!-- Filters and Controls -->
    <div class="controls-section">
      <div class="filters">
        <div class="filter-group">
          <label for="search">Search</label>
          <input
            id="search"
            type="text"
            placeholder="Search tasks..."
            bind:value={searchQuery}
          />
        </div>

        <div class="filter-group">
          <label for="project-filter">Project</label>
          <select id="project-filter" bind:value={selectedProject}>
            <option value="">All Projects</option>
            {#each projects as project}
              <option value={project.id}>{project.name}</option>
            {/each}
          </select>
        </div>

        <div class="filter-group">
          <label for="status-filter">Status</label>
          <select id="status-filter" bind:value={selectedStatus}>
            <option value="">All Statuses</option>
            <option value="pending">Pending</option>
            <option value="in_progress">In Progress</option>
            <option value="review">Review</option>
            <option value="completed">Completed</option>
          </select>
        </div>

        <div class="filter-group">
          <label for="assignee-filter">Assignee</label>
          <select id="assignee-filter" bind:value={selectedAssignee}>
            <option value="">All Assignees</option>
            {#each users as user_item}
              <option value={user_item.id}>{user_item.name}</option>
            {/each}
          </select>
        </div>
      </div>

      <div class="view-controls">
        <div class="sort-controls">
          <select bind:value={sortBy}>
            <option value="created_at">Created Date</option>
            <option value="updated_at">Updated Date</option>
            <option value="dueDate">Due Date</option>
            <option value="priority">Priority</option>
            <option value="title">Title</option>
          </select>
          <button 
            class="sort-order-btn"
            class:active={sortOrder === 'desc'}
            on:click={() => sortOrder = sortOrder === 'asc' ? 'desc' : 'asc'}
          >
            <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
              {#if sortOrder === 'asc'}
                <path d="M8 3L4 7h8l-4-4z"/>
              {:else}
                <path d="M8 13l4-4H4l4 4z"/>
              {/if}
            </svg>
          </button>
        </div>

        <div class="view-mode-toggle">
          <button
            class="view-btn"
            class:active={viewMode === 'board'}
            on:click={() => viewMode = 'board'}
          >
            <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
              <path d="M2 3a1 1 0 011-1h2a1 1 0 011 1v10a1 1 0 01-1 1H3a1 1 0 01-1-1V3zM7 3a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 01-1 1H8a1 1 0 01-1-1V3zM12 3a1 1 0 011-1h2a1 1 0 011 1v7a1 1 0 01-1 1h-2a1 1 0 01-1-1V3z"/>
            </svg>
            Board
          </button>
          <button
            class="view-btn"
            class:active={viewMode === 'list'}
            on:click={() => viewMode = 'list'}
          >
            <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
              <path d="M2 3a1 1 0 000 2h12a1 1 0 100-2H2zM2 7a1 1 0 000 2h12a1 1 0 100-2H2zM2 11a1 1 0 100 2h12a1 1 0 100-2H2z"/>
            </svg>
            List
          </button>
        </div>
      </div>
    </div>

    <!-- Tasks Content -->
    <div class="tasks-content">
      {#if viewMode === 'board'}
        <TaskBoard />
      {:else}
        <div class="tasks-list">
          {#if filteredTasks.length === 0}
            <div class="empty-state">
              <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
                <path d="M32 8L8 20v24c0 16 11 22 24 22s24-6 24-22V20L32 8z" stroke="#d1d5db" stroke-width="2" fill="none"/>
              </svg>
              <h3>No tasks found</h3>
              <p>Try adjusting your filters or create a new task.</p>
            </div>
          {:else}
            <div class="list-header">
              <div class="task-count">
                {filteredTasks.length} task{filteredTasks.length !== 1 ? 's' : ''}
              </div>
            </div>

            <div class="task-items">
              {#each filteredTasks as task}
                <div class="task-item">
                  <div class="task-main">
                    <div class="task-priority" style="background-color: {getPriorityColor(task.priority)}"></div>
                    <div class="task-content">
                      <h3>{task.title}</h3>
                      <p>{task.description || 'No description'}</p>
                      <div class="task-meta">
                        <span class="project">{getProjectName(task.projectId)}</span>
                        <span class="assignee">{getUserName(task.assigneeId)}</span>
                        {#if task.dueDate}
                          <span class="due-date" class:overdue={new Date(task.dueDate) < new Date()}>
                            Due: {new Date(task.dueDate).toLocaleDateString()}
                          </span>
                        {/if}
                      </div>
                    </div>
                  </div>
                  <div class="task-actions">
                    <select
                      value={task.status}
                      on:change={(e) => updateTaskStatus(task.id, e.target.value)}
                      style="color: {getStatusColor(task.status)}"
                    >
                      <option value="pending">Pending</option>
                      <option value="in_progress">In Progress</option>
                      <option value="review">Review</option>
                      <option value="completed">Completed</option>
                    </select>
                    <button class="delete-btn" on:click={() => deleteTask(task.id)}>
                      <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                        <path fill-rule="evenodd" d="M5.5 5.5A.5.5 0 016 6v6a.5.5 0 01-1 0V6a.5.5 0 01.5-.5zm2.5 0a.5.5 0 01.5.5v6a.5.5 0 01-1 0V6a.5.5 0 01.5-.5zm3 .5a.5.5 0 00-1 0v6a.5.5 0 001 0V6z" clip-rule="evenodd"/>
                        <path fill-rule="evenodd" d="M14.5 3a1 1 0 01-1 1H13v9a2 2 0 01-2 2H5a2 2 0 01-2-2V4h-.5a1 1 0 01-1-1V2a1 1 0 011-1H6a1 1 0 011-1h2a1 1 0 011 1h3.5a1 1 0 011 1v1zM4.118 4L4 4.059V13a1 1 0 001 1h6a1 1 0 001-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z" clip-rule="evenodd"/>
                      </svg>
                    </button>
                  </div>
                </div>
              {/each}
            </div>
          {/if}
        </div>
      {/if}
    </div>
  {/if}
</div>

<style>
  .tasks-page {
    padding: 2rem;
    max-width: 1400px;
    margin: 0 auto;
  }

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid #e5e7eb;
  }

  .header-content h1 {
    margin: 0 0 0.5rem 0;
    font-size: 2rem;
    font-weight: 700;
    color: #111827;
  }

  .header-content p {
    margin: 0;
    color: #6b7280;
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

  .controls-section {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    margin-bottom: 2rem;
    background: white;
    padding: 1.5rem;
    border-radius: 1rem;
    border: 1px solid #e5e7eb;
  }

  .filters {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
  }

  .filter-group {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .filter-group label {
    font-size: 0.875rem;
    font-weight: 500;
    color: #374151;
  }

  .filter-group input,
  .filter-group select {
    padding: 0.75rem;
    border: 1px solid #d1d5db;
    border-radius: 0.5rem;
    font-size: 0.875rem;
  }

  .filter-group input:focus,
  .filter-group select:focus {
    outline: none;
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  }

  .view-controls {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 1rem;
    border-top: 1px solid #e5e7eb;
  }

  .sort-controls {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .sort-controls select {
    padding: 0.5rem 0.75rem;
    border: 1px solid #d1d5db;
    border-radius: 0.375rem;
    font-size: 0.875rem;
  }

  .sort-order-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 2rem;
    height: 2rem;
    background: white;
    border: 1px solid #d1d5db;
    border-radius: 0.375rem;
    color: #6b7280;
    cursor: pointer;
    transition: all 0.2s;
  }

  .sort-order-btn:hover,
  .sort-order-btn.active {
    background: #f3f4f6;
    color: #374151;
  }

  .view-mode-toggle {
    display: flex;
    border: 1px solid #d1d5db;
    border-radius: 0.5rem;
    overflow: hidden;
  }

  .view-btn {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 0.75rem;
    background: white;
    border: none;
    color: #6b7280;
    cursor: pointer;
    transition: all 0.2s;
    font-size: 0.875rem;
  }

  .view-btn:hover,
  .view-btn.active {
    background: #3b82f6;
    color: white;
  }

  .tasks-content {
    background: white;
    border-radius: 1rem;
    border: 1px solid #e5e7eb;
    min-height: 600px;
  }

  .tasks-list {
    padding: 1.5rem;
  }

  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 4rem 2rem;
    text-align: center;
  }

  .empty-state h3 {
    margin: 1rem 0 0.5rem 0;
    color: #374151;
  }

  .empty-state p {
    margin: 0;
    color: #6b7280;
  }

  .list-header {
    margin-bottom: 1rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid #e5e7eb;
  }

  .task-count {
    color: #6b7280;
    font-size: 0.875rem;
  }

  .task-items {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .task-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem;
    background: #f8fafc;
    border-radius: 0.5rem;
    border: 1px solid #e5e7eb;
  }

  .task-main {
    display: flex;
    align-items: flex-start;
    gap: 1rem;
    flex: 1;
  }

  .task-priority {
    width: 4px;
    height: 3rem;
    border-radius: 2px;
    flex-shrink: 0;
  }

  .task-content {
    flex: 1;
  }

  .task-content h3 {
    margin: 0 0 0.25rem 0;
    font-size: 1rem;
    font-weight: 600;
    color: #111827;
  }

  .task-content p {
    margin: 0 0 0.5rem 0;
    font-size: 0.875rem;
    color: #6b7280;
    line-height: 1.4;
  }

  .task-meta {
    display: flex;
    gap: 1rem;
    font-size: 0.75rem;
    color: #6b7280;
  }

  .task-meta .project {
    font-weight: 500;
  }

  .task-meta .due-date.overdue {
    color: #dc2626;
    font-weight: 500;
  }

  .task-actions {
    display: flex;
    align-items: center;
    gap: 0.75rem;
  }

  .task-actions select {
    padding: 0.375rem 0.5rem;
    border: 1px solid #d1d5db;
    border-radius: 0.375rem;
    font-size: 0.75rem;
    font-weight: 500;
  }

  .delete-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 2rem;
    height: 2rem;
    background: white;
    border: 1px solid #dc2626;
    border-radius: 0.375rem;
    color: #dc2626;
    cursor: pointer;
    transition: all 0.2s;
  }

  .delete-btn:hover {
    background: #dc2626;
    color: white;
  }

  @media (max-width: 768px) {
    .tasks-page {
      padding: 1rem;
    }

    .page-header {
      flex-direction: column;
      gap: 1rem;
    }

    .view-controls {
      flex-direction: column;
      gap: 1rem;
      align-items: stretch;
    }

    .task-item {
      flex-direction: column;
      align-items: stretch;
      gap: 1rem;
    }

    .task-actions {
      justify-content: flex-end;
    }
  }
</style>
