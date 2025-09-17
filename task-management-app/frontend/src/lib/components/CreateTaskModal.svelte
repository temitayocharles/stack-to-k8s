<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { user } from '../stores/user';
  import { toast } from '../stores/toast';
  import LoadingSpinner from './LoadingSpinner.svelte';
  
  export let projectId: string | null = null;
  
  let isOpen = false;
  let isLoading = false;
  let formData = {
    title: '',
    description: '',
    priority: 'medium',
    status: 'pending',
    projectId: projectId || '',
    assigneeId: '',
    dueDate: ''
  };
  
  let projects = [];
  let users = [];

  $: if (projectId) {
    formData.projectId = projectId;
  }

  function openModal() {
    isOpen = true;
    resetForm();
  }

  function closeModal() {
    isOpen = false;
    resetForm();
  }

  function resetForm() {
    formData = {
      title: '',
      description: '',
      priority: 'medium',
      status: 'pending',
      projectId: projectId || '',
      assigneeId: '',
      dueDate: ''
    };
  }

  async function handleSubmit() {
    if (!formData.title.trim()) {
      toast.show('Task title is required', 'error');
      return;
    }

    isLoading = true;
    
    try {
      const response = await fetch('/api/tasks', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${$user.token}`
        },
        body: JSON.stringify({
          ...formData,
          assigneeId: formData.assigneeId || null,
          dueDate: formData.dueDate || null
        })
      });

      if (!response.ok) {
        throw new Error('Failed to create task');
      }

      const task = await response.json();
      toast.show('Task created successfully', 'success');
      closeModal();
      
      // Dispatch event to refresh task list
      window.dispatchEvent(new CustomEvent('taskCreated', { detail: task }));
    } catch (error) {
      console.error('Error creating task:', error);
      toast.show('Failed to create task', 'error');
    } finally {
      isLoading = false;
    }
  }

  async function loadProjects() {
    try {
      const response = await fetch('/api/projects', {
        headers: {
          'Authorization': `Bearer ${$user.token}`
        }
      });
      
      if (response.ok) {
        projects = await response.json();
      }
    } catch (error) {
      console.error('Error loading projects:', error);
    }
  }

  async function loadUsers() {
    try {
      const response = await fetch('/api/users', {
        headers: {
          'Authorization': `Bearer ${$user.token}`
        }
      });
      
      if (response.ok) {
        users = await response.json();
      }
    } catch (error) {
      console.error('Error loading users:', error);
    }
  }

  function handleKeydown(event) {
    if (event.key === 'Escape') {
      closeModal();
    }
  }

  onMount(() => {
    loadProjects();
    loadUsers();
    document.addEventListener('keydown', handleKeydown);
  });

  onDestroy(() => {
    document.removeEventListener('keydown', handleKeydown);
  });
</script>

<button class="create-task-btn" on:click={openModal}>
  <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
    <path fill-rule="evenodd" d="M8 2a1 1 0 011 1v4h4a1 1 0 110 2H9v4a1 1 0 11-2 0V9H3a1 1 0 110-2h4V3a1 1 0 011-1z" clip-rule="evenodd" />
  </svg>
  Create Task
</button>

{#if isOpen}
  <div class="modal-overlay" on:click={closeModal}>
    <div class="modal" on:click|stopPropagation>
      <div class="modal-header">
        <h2>Create New Task</h2>
        <button class="close-btn" on:click={closeModal}>
          <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
          </svg>
        </button>
      </div>
      
      <form on:submit|preventDefault={handleSubmit} class="task-form">
        <div class="form-group">
          <label for="title">Task Title *</label>
          <input
            id="title"
            type="text"
            bind:value={formData.title}
            placeholder="Enter task title"
            required
          />
        </div>

        <div class="form-group">
          <label for="description">Description</label>
          <textarea
            id="description"
            bind:value={formData.description}
            placeholder="Enter task description"
            rows="3"
          ></textarea>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="priority">Priority</label>
            <select id="priority" bind:value={formData.priority}>
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
              <option value="urgent">Urgent</option>
            </select>
          </div>

          <div class="form-group">
            <label for="status">Status</label>
            <select id="status" bind:value={formData.status}>
              <option value="pending">Pending</option>
              <option value="in_progress">In Progress</option>
              <option value="review">Review</option>
              <option value="completed">Completed</option>
            </select>
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="project">Project</label>
            <select id="project" bind:value={formData.projectId}>
              <option value="">No Project</option>
              {#each projects as project}
                <option value={project.id}>{project.name}</option>
              {/each}
            </select>
          </div>

          <div class="form-group">
            <label for="assignee">Assignee</label>
            <select id="assignee" bind:value={formData.assigneeId}>
              <option value="">Unassigned</option>
              {#each users as user_item}
                <option value={user_item.id}>{user_item.name}</option>
              {/each}
            </select>
          </div>
        </div>

        <div class="form-group">
          <label for="dueDate">Due Date</label>
          <input
            id="dueDate"
            type="date"
            bind:value={formData.dueDate}
          />
        </div>

        <div class="form-actions">
          <button type="button" class="cancel-btn" on:click={closeModal}>Cancel</button>
          <button type="submit" class="submit-btn" disabled={isLoading}>
            {#if isLoading}
              <LoadingSpinner size="small" />
              Creating...
            {:else}
              Create Task
            {/if}
          </button>
        </div>
      </form>
    </div>
  </div>
{/if}

<style>
  .create-task-btn {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem 1rem;
    background: #3b82f6;
    color: white;
    border: none;
    border-radius: 0.5rem;
    font-size: 0.875rem;
    font-weight: 500;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .create-task-btn:hover {
    background: #2563eb;
  }

  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    padding: 1rem;
  }

  .modal {
    background: white;
    border-radius: 0.75rem;
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    width: 100%;
    max-width: 600px;
    max-height: 90vh;
    overflow-y: auto;
  }

  .modal-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 1.5rem 1.5rem 0 1.5rem;
    border-bottom: 1px solid #e5e7eb;
    margin-bottom: 1.5rem;
    padding-bottom: 1rem;
  }

  .modal-header h2 {
    margin: 0;
    font-size: 1.25rem;
    font-weight: 600;
    color: #111827;
  }

  .close-btn {
    background: none;
    border: none;
    color: #6b7280;
    cursor: pointer;
    padding: 0.25rem;
    border-radius: 0.25rem;
    transition: color 0.2s;
  }

  .close-btn:hover {
    color: #374151;
  }

  .task-form {
    padding: 0 1.5rem 1.5rem 1.5rem;
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .form-group {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
  }

  .form-group label {
    font-size: 0.875rem;
    font-weight: 500;
    color: #374151;
  }

  .form-group input,
  .form-group textarea,
  .form-group select {
    padding: 0.75rem;
    border: 1px solid #d1d5db;
    border-radius: 0.5rem;
    font-size: 0.875rem;
    transition: border-color 0.2s, box-shadow 0.2s;
  }

  .form-group input:focus,
  .form-group textarea:focus,
  .form-group select:focus {
    outline: none;
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  }

  .form-group textarea {
    resize: vertical;
    min-height: 80px;
  }

  .form-actions {
    display: flex;
    gap: 0.75rem;
    justify-content: flex-end;
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 1px solid #e5e7eb;
  }

  .cancel-btn {
    padding: 0.75rem 1rem;
    background: white;
    color: #374151;
    border: 1px solid #d1d5db;
    border-radius: 0.5rem;
    font-size: 0.875rem;
    font-weight: 500;
    cursor: pointer;
    transition: background-color 0.2s, border-color 0.2s;
  }

  .cancel-btn:hover {
    background: #f9fafb;
    border-color: #9ca3af;
  }

  .submit-btn {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem 1rem;
    background: #3b82f6;
    color: white;
    border: none;
    border-radius: 0.5rem;
    font-size: 0.875rem;
    font-weight: 500;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .submit-btn:hover:not(:disabled) {
    background: #2563eb;
  }

  .submit-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  @media (max-width: 640px) {
    .modal {
      margin: 1rem;
      max-width: calc(100vw - 2rem);
    }

    .form-row {
      grid-template-columns: 1fr;
    }

    .form-actions {
      flex-direction: column-reverse;
    }

    .cancel-btn,
    .submit-btn {
      width: 100%;
      justify-content: center;
    }
  }
</style>
