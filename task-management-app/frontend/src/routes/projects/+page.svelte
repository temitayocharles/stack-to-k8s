<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { user } from '../../lib/stores/user';
  import { toast } from '../../lib/stores/toast';
  import LoadingSpinner from '../../lib/components/LoadingSpinner.svelte';
  
  let isLoading = true;
  let projects = [];
  let isModalOpen = false;
  let editingProject = null;
  let formData = {
    name: '',
    description: '',
    status: 'active'
  };

  async function loadProjects() {
    if (!$user.isAuthenticated) {
      isLoading = false;
      return;
    }

    try {
      const response = await fetch('/api/projects', {
        headers: { 'Authorization': `Bearer ${$user.token}` }
      });

      if (!response.ok) throw new Error('Failed to load projects');

      projects = await response.json();
    } catch (error) {
      console.error('Error loading projects:', error);
      toast.show('Failed to load projects', 'error');
    } finally {
      isLoading = false;
    }
  }

  function openCreateModal() {
    editingProject = null;
    formData = { name: '', description: '', status: 'active' };
    isModalOpen = true;
  }

  function openEditModal(project) {
    editingProject = project;
    formData = { ...project };
    isModalOpen = true;
  }

  function closeModal() {
    isModalOpen = false;
    editingProject = null;
    formData = { name: '', description: '', status: 'active' };
  }

  async function handleSubmit() {
    if (!formData.name.trim()) {
      toast.show('Project name is required', 'error');
      return;
    }

    try {
      const url = editingProject ? `/api/projects/${editingProject.id}` : '/api/projects';
      const method = editingProject ? 'PUT' : 'POST';

      const response = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${$user.token}`
        },
        body: JSON.stringify(formData)
      });

      if (!response.ok) throw new Error(`Failed to ${editingProject ? 'update' : 'create'} project`);

      const project = await response.json();
      
      if (editingProject) {
        projects = projects.map(p => p.id === project.id ? project : p);
        toast.show('Project updated successfully', 'success');
      } else {
        projects = [...projects, project];
        toast.show('Project created successfully', 'success');
      }

      closeModal();
    } catch (error) {
      console.error('Error saving project:', error);
      toast.show(`Failed to ${editingProject ? 'update' : 'create'} project`, 'error');
    }
  }

  async function deleteProject(projectId: string) {
    if (!confirm('Are you sure you want to delete this project? This action cannot be undone.')) return;

    try {
      const response = await fetch(`/api/projects/${projectId}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${$user.token}` }
      });

      if (!response.ok) throw new Error('Failed to delete project');

      projects = projects.filter(p => p.id !== projectId);
      toast.show('Project deleted successfully', 'success');
    } catch (error) {
      console.error('Error deleting project:', error);
      toast.show('Failed to delete project', 'error');
    }
  }

  function getStatusColor(status: string) {
    switch (status) {
      case 'active': return '#059669';
      case 'completed': return '#0284c7';
      case 'on_hold': return '#d97706';
      case 'cancelled': return '#dc2626';
      default: return '#6b7280';
    }
  }

  function formatDate(dateString: string) {
    return new Date(dateString).toLocaleDateString();
  }

  function handleKeydown(event) {
    if (event.key === 'Escape') {
      closeModal();
    }
  }

  onMount(() => {
    loadProjects();
    document.addEventListener('keydown', handleKeydown);
  });

  onDestroy(() => {
    document.removeEventListener('keydown', handleKeydown);
  });
</script>

<svelte:head>
  <title>Projects - Task Management</title>
</svelte:head>

<div class="projects-page">
  <div class="page-header">
    <div class="header-content">
      <h1>Projects</h1>
      <p>Organize your work into manageable projects</p>
    </div>
    <div class="header-actions">
      <button class="create-btn" on:click={openCreateModal}>
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
          <path fill-rule="evenodd" d="M8 2a1 1 0 011 1v4h4a1 1 0 110 2H9v4a1 1 0 11-2 0V9H3a1 1 0 110-2h4V3a1 1 0 011-1z" clip-rule="evenodd" />
        </svg>
        Create Project
      </button>
    </div>
  </div>

  {#if isLoading}
    <div class="loading-container">
      <LoadingSpinner />
      <p>Loading projects...</p>
    </div>
  {:else if !$user.isAuthenticated}
    <div class="auth-required">
      <h2>Please Log In</h2>
      <p>You need to log in to view your projects.</p>
      <a href="/login" class="login-link">Go to Login</a>
    </div>
  {:else}
    <div class="projects-content">
      {#if projects.length === 0}
        <div class="empty-state">
          <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
            <rect x="8" y="16" width="48" height="32" rx="4" stroke="#d1d5db" stroke-width="2" fill="none"/>
            <path d="M16 24h32M16 32h24M16 40h16" stroke="#d1d5db" stroke-width="2"/>
          </svg>
          <h3>No projects yet</h3>
          <p>Create your first project to get started organizing your tasks.</p>
          <button class="create-first-btn" on:click={openCreateModal}>
            Create Your First Project
          </button>
        </div>
      {:else}
        <div class="projects-grid">
          {#each projects as project}
            <div class="project-card">
              <div class="project-header">
                <div class="project-info">
                  <h3>{project.name}</h3>
                  <span class="project-status" style="color: {getStatusColor(project.status)}">
                    {project.status.replace('_', ' ')}
                  </span>
                </div>
                <div class="project-actions">
                  <button class="action-btn" on:click={() => openEditModal(project)}>
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                      <path d="M12.146.146a.5.5 0 01.708 0l3 3a.5.5 0 010 .708L4.707 15H1v-3.707L12.146.146zM11 2.207L2 11.207V14h2.793L14 5.793 11 2.207z"/>
                    </svg>
                  </button>
                  <button class="action-btn delete-btn" on:click={() => deleteProject(project.id)}>
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                      <path fill-rule="evenodd" d="M5.5 5.5A.5.5 0 016 6v6a.5.5 0 01-1 0V6a.5.5 0 01.5-.5zm2.5 0a.5.5 0 01.5.5v6a.5.5 0 01-1 0V6a.5.5 0 01.5-.5zm3 .5a.5.5 0 00-1 0v6a.5.5 0 001 0V6z" clip-rule="evenodd"/>
                      <path fill-rule="evenodd" d="M14.5 3a1 1 0 01-1 1H13v9a2 2 0 01-2 2H5a2 2 0 01-2-2V4h-.5a1 1 0 01-1-1V2a1 1 0 011-1H6a1 1 0 011-1h2a1 1 0 011 1h3.5a1 1 0 011 1v1zM4.118 4L4 4.059V13a1 1 0 001 1h6a1 1 0 001-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z" clip-rule="evenodd"/>
                    </svg>
                  </button>
                </div>
              </div>

              <div class="project-description">
                <p>{project.description || 'No description available'}</p>
              </div>

              <div class="project-meta">
                <div class="meta-item">
                  <span class="meta-label">Created:</span>
                  <span class="meta-value">{formatDate(project.created_at)}</span>
                </div>
                {#if project.updated_at !== project.created_at}
                  <div class="meta-item">
                    <span class="meta-label">Updated:</span>
                    <span class="meta-value">{formatDate(project.updated_at)}</span>
                  </div>
                {/if}
              </div>

              <div class="project-footer">
                <a href="/projects/{project.id}" class="view-btn">
                  View Details
                  <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                    <path fill-rule="evenodd" d="M1 8a.5.5 0 01.5-.5h11.793l-3.147-3.146a.5.5 0 01.708-.708l4 4a.5.5 0 010 .708l-4 4a.5.5 0 01-.708-.708L13.293 8.5H1.5A.5.5 0 011 8z" clip-rule="evenodd"/>
                  </svg>
                </a>
              </div>
            </div>
          {/each}
        </div>
      {/if}
    </div>
  {/if}
</div>

<!-- Modal -->
{#if isModalOpen}
  <div class="modal-overlay" on:click={closeModal}>
    <div class="modal" on:click|stopPropagation>
      <div class="modal-header">
        <h2>{editingProject ? 'Edit Project' : 'Create New Project'}</h2>
        <button class="close-btn" on:click={closeModal}>
          <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
          </svg>
        </button>
      </div>

      <form on:submit|preventDefault={handleSubmit} class="project-form">
        <div class="form-group">
          <label for="name">Project Name *</label>
          <input
            id="name"
            type="text"
            bind:value={formData.name}
            placeholder="Enter project name"
            required
          />
        </div>

        <div class="form-group">
          <label for="description">Description</label>
          <textarea
            id="description"
            bind:value={formData.description}
            placeholder="Enter project description"
            rows="4"
          ></textarea>
        </div>

        <div class="form-group">
          <label for="status">Status</label>
          <select id="status" bind:value={formData.status}>
            <option value="active">Active</option>
            <option value="completed">Completed</option>
            <option value="on_hold">On Hold</option>
            <option value="cancelled">Cancelled</option>
          </select>
        </div>

        <div class="form-actions">
          <button type="button" class="cancel-btn" on:click={closeModal}>Cancel</button>
          <button type="submit" class="submit-btn">
            {editingProject ? 'Update Project' : 'Create Project'}
          </button>
        </div>
      </form>
    </div>
  </div>
{/if}

<style>
  .projects-page {
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

  .create-btn {
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

  .create-btn:hover {
    background: #2563eb;
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

  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 4rem 2rem;
    text-align: center;
    background: white;
    border-radius: 1rem;
    border: 2px dashed #d1d5db;
  }

  .empty-state h3 {
    margin: 1rem 0 0.5rem 0;
    color: #374151;
  }

  .empty-state p {
    margin: 0 0 2rem 0;
    color: #6b7280;
  }

  .create-first-btn {
    padding: 0.75rem 1.5rem;
    background: #3b82f6;
    color: white;
    border: none;
    border-radius: 0.5rem;
    font-weight: 500;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .create-first-btn:hover {
    background: #2563eb;
  }

  .projects-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
    gap: 1.5rem;
  }

  .project-card {
    background: white;
    border-radius: 1rem;
    padding: 1.5rem;
    border: 1px solid #e5e7eb;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    transition: box-shadow 0.2s;
  }

  .project-card:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  .project-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 1rem;
  }

  .project-info h3 {
    margin: 0 0 0.25rem 0;
    font-size: 1.25rem;
    font-weight: 600;
    color: #111827;
  }

  .project-status {
    font-size: 0.75rem;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .project-actions {
    display: flex;
    gap: 0.5rem;
  }

  .action-btn {
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

  .action-btn:hover {
    background: #f3f4f6;
    color: #374151;
  }

  .action-btn.delete-btn {
    border-color: #dc2626;
    color: #dc2626;
  }

  .action-btn.delete-btn:hover {
    background: #dc2626;
    color: white;
  }

  .project-description {
    margin-bottom: 1.5rem;
  }

  .project-description p {
    margin: 0;
    color: #6b7280;
    line-height: 1.5;
  }

  .project-meta {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    margin-bottom: 1.5rem;
    padding: 1rem;
    background: #f8fafc;
    border-radius: 0.5rem;
  }

  .meta-item {
    display: flex;
    justify-content: space-between;
    font-size: 0.875rem;
  }

  .meta-label {
    color: #6b7280;
  }

  .meta-value {
    color: #374151;
    font-weight: 500;
  }

  .project-footer {
    border-top: 1px solid #e5e7eb;
    padding-top: 1rem;
  }

  .view-btn {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    color: #3b82f6;
    text-decoration: none;
    font-weight: 500;
    transition: color 0.2s;
  }

  .view-btn:hover {
    color: #2563eb;
  }

  /* Modal Styles */
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
    max-width: 500px;
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

  .project-form {
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
    min-height: 100px;
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

  .submit-btn:hover {
    background: #2563eb;
  }

  @media (max-width: 640px) {
    .projects-page {
      padding: 1rem;
    }

    .page-header {
      flex-direction: column;
      gap: 1rem;
    }

    .projects-grid {
      grid-template-columns: 1fr;
    }

    .modal {
      margin: 1rem;
      max-width: calc(100vw - 2rem);
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
