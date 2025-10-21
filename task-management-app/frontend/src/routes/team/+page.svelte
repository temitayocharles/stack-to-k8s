<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { userStore } from '../../lib/stores/user';
  import { toast } from '../../lib/stores/toast';
  import LoadingSpinner from '../../lib/components/LoadingSpinner.svelte';
  
  let isLoading = true;
  let users = [];
  let isModalOpen = false;
  let editingUser = null;
  let formData = {
    name: '',
    email: '',
    role: 'member'
  };

  async function loadUsers() {
    if (!$userStore.isAuthenticated) {
      isLoading = false;
      return;
    }

    try {
      const response = await fetch('/api/users', {
        headers: { 'Authorization': `Bearer ${$userStore.token}` }
      });

      if (!response.ok) throw new Error('Failed to load users');

      users = await response.json();
    } catch (error) {
      console.error('Error loading users:', error);
      toast.show('Failed to load team members', 'error');
    } finally {
      isLoading = false;
    }
  }

  function openCreateModal() {
    editingUser = null;
    formData = { name: '', email: '', role: 'member' };
    isModalOpen = true;
  }

  function openEditModal(userItem) {
    editingUser = userItem;
    formData = { ...userItem };
    isModalOpen = true;
  }

  function closeModal() {
    isModalOpen = false;
    editingUser = null;
    formData = { name: '', email: '', role: 'member' };
  }

  async function handleSubmit() {
    if (!formData.name.trim() || !formData.email.trim()) {
      toast.show('Name and email are required', 'error');
      return;
    }

    try {
      const url = editingUser ? `/api/users/${editingUser.id}` : '/api/users';
      const method = editingUser ? 'PUT' : 'POST';

      const response = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${$userStore.token}`
        },
        body: JSON.stringify(formData)
      });

      if (!response.ok) throw new Error(`Failed to ${editingUser ? 'update' : 'create'} user`);

      const savedUser = await response.json();
      
      if (editingUser) {
        users = users.map(u => u.id === savedUser.id ? savedUser : u);
        toast.show('Team member updated successfully', 'success');
      } else {
        users = [...users, savedUser];
        toast.show('Team member added successfully', 'success');
      }

      closeModal();
    } catch (error) {
      console.error('Error saving user:', error);
      toast.show(`Failed to ${editingUser ? 'update' : 'add'} team member`, 'error');
    }
  }

  async function deleteUser(userId: string) {
    if (!confirm('Are you sure you want to remove this team member?')) return;

    try {
      const response = await fetch(`/api/users/${userId}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${$userStore.token}` }
      });

      if (!response.ok) throw new Error('Failed to delete user');

      users = users.filter(u => u.id !== userId);
      toast.show('Team member removed successfully', 'success');
    } catch (error) {
      console.error('Error deleting user:', error);
      toast.show('Failed to remove team member', 'error');
    }
  }

  function getRoleColor(role: string) {
    switch (role) {
      case 'admin': return '#dc2626';
      case 'manager': return '#d97706';
      case 'member': return '#059669';
      default: return '#6b7280';
    }
  }

  function getRoleBadgeStyle(role: string) {
    switch (role) {
      case 'admin': return 'background: #fecaca; color: #991b1b;';
      case 'manager': return 'background: #fed7aa; color: #9a3412;';
      case 'member': return 'background: #dcfce7; color: #166534;';
      default: return 'background: #f3f4f6; color: #374151;';
    }
  }

  function formatDate(dateString: string) {
    return new Date(dateString).toLocaleDateString();
  }

  function getInitials(name: string) {
    return name.split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  }

  function handleKeydown(event) {
    if (event.key === 'Escape') {
      closeModal();
    }
  }

  onMount(() => {
    loadUsers();
    document.addEventListener('keydown', handleKeydown);
  });

  onDestroy(() => {
    document.removeEventListener('keydown', handleKeydown);
  });
</script>

<svelte:head>
  <title>Team - Task Management</title>
</svelte:head>

<div class="team-page">
  <div class="page-header">
    <div class="header-content">
      <h1>Team</h1>
      <p>Manage your team members and their roles</p>
    </div>
    <div class="header-actions">
      <button class="create-btn" on:click={openCreateModal}>
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
          <path d="M8 8a3 3 0 100-6 3 3 0 000 6zM12.735 14c.618 0 1.093-.561.872-1.139a6.002 6.002 0 00-11.215 0c-.22.578.254 1.139.872 1.139h9.47z"/>
          <path d="M13.5 8a.5.5 0 01.5.5v2a.5.5 0 01-.5.5h-2a.5.5 0 010-1h1.5V8.5a.5.5 0 01.5-.5z"/>
          <path d="M13 8.5a.5.5 0 01-.5.5h-2a.5.5 0 010-1h1.5V6.5a.5.5 0 011 0v2z"/>
        </svg>
        Add Team Member
      </button>
    </div>
  </div>

  {#if isLoading}
    <div class="loading-container">
      <LoadingSpinner />
      <p>Loading team members...</p>
    </div>
  {:else if !$userStore.isAuthenticated}
    <div class="auth-required">
      <h2>Please Log In</h2>
      <p>You need to log in to view your team.</p>
      <a href="/login" class="login-link">Go to Login</a>
    </div>
  {:else}
    <div class="team-content">
      {#if users.length === 0}
        <div class="empty-state">
          <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
            <circle cx="32" cy="20" r="8" stroke="#d1d5db" stroke-width="2" fill="none"/>
            <path d="M16 44c0-8.837 7.163-16 16-16s16 7.163 16 16" stroke="#d1d5db" stroke-width="2" fill="none"/>
          </svg>
          <h3>No team members yet</h3>
          <p>Add your first team member to start collaborating.</p>
          <button class="create-first-btn" on:click={openCreateModal}>
            Add Your First Team Member
          </button>
        </div>
      {:else}
        <div class="team-stats">
          <div class="stat-card">
            <h3>{users.length}</h3>
            <p>Total Members</p>
          </div>
          <div class="stat-card">
            <h3>{users.filter(u => u.role === 'admin').length}</h3>
            <p>Admins</p>
          </div>
          <div class="stat-card">
            <h3>{users.filter(u => u.role === 'manager').length}</h3>
            <p>Managers</p>
          </div>
          <div class="stat-card">
            <h3>{users.filter(u => u.role === 'member').length}</h3>
            <p>Members</p>
          </div>
        </div>

        <div class="team-grid">
          {#each users as userItem}
            <div class="member-card">
              <div class="member-header">
                <div class="member-avatar">
                  {getInitials(userItem.name)}
                </div>
                <div class="member-actions">
                  <button class="action-btn" on:click={() => openEditModal(userItem)}>
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                      <path d="M12.146.146a.5.5 0 01.708 0l3 3a.5.5 0 010 .708L4.707 15H1v-3.707L12.146.146zM11 2.207L2 11.207V14h2.793L14 5.793 11 2.207z"/>
                    </svg>
                  </button>
                  {#if userItem.id !== $userStore.id}
                    <button class="action-btn delete-btn" on:click={() => deleteUser(userItem.id)}>
                      <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                        <path fill-rule="evenodd" d="M5.5 5.5A.5.5 0 016 6v6a.5.5 0 01-1 0V6a.5.5 0 01.5-.5zm2.5 0a.5.5 0 01.5.5v6a.5.5 0 01-1 0V6a.5.5 0 01.5-.5zm3 .5a.5.5 0 00-1 0v6a.5.5 0 001 0V6z" clip-rule="evenodd"/>
                        <path fill-rule="evenodd" d="M14.5 3a1 1 0 01-1 1H13v9a2 2 0 01-2 2H5a2 2 0 01-2-2V4h-.5a1 1 0 01-1-1V2a1 1 0 011-1H6a1 1 0 011-1h2a1 1 0 011 1h3.5a1 1 0 011 1v1zM4.118 4L4 4.059V13a1 1 0 001 1h6a1 1 0 001-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z" clip-rule="evenodd"/>
                      </svg>
                    </button>
                  {/if}
                </div>
              </div>

              <div class="member-info">
                <h3>{userItem.name}</h3>
                <p class="member-email">{userItem.email}</p>
                <span class="role-badge" style="{getRoleBadgeStyle(userItem.role)}">
                  {userItem.role}
                </span>
              </div>

              <div class="member-meta">
                <div class="meta-item">
                  <span class="meta-label">Joined:</span>
                  <span class="meta-value">{formatDate(userItem.created_at)}</span>
                </div>
                {#if userItem.last_active}
                  <div class="meta-item">
                    <span class="meta-label">Last Active:</span>
                    <span class="meta-value">{formatDate(userItem.last_active)}</span>
                  </div>
                {/if}
              </div>

              {#if userItem.id === $userStore.id}
                <div class="current-user-badge">
                  <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                    <path d="M8 8a3 3 0 100-6 3 3 0 000 6zM12.735 14c.618 0 1.093-.561.872-1.139a6.002 6.002 0 00-11.215 0c-.22.578.254 1.139.872 1.139h9.47z"/>
                  </svg>
                  You
                </div>
              {/if}
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
        <h2>{editingUser ? 'Edit Team Member' : 'Add New Team Member'}</h2>
        <button class="close-btn" on:click={closeModal}>
          <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
          </svg>
        </button>
      </div>

      <form on:submit|preventDefault={handleSubmit} class="user-form">
        <div class="form-group">
          <label for="name">Full Name *</label>
          <input
            id="name"
            type="text"
            bind:value={formData.name}
            placeholder="Enter full name"
            required
          />
        </div>

        <div class="form-group">
          <label for="email">Email Address *</label>
          <input
            id="email"
            type="email"
            bind:value={formData.email}
            placeholder="Enter email address"
            required
          />
        </div>

        <div class="form-group">
          <label for="role">Role</label>
          <select id="role" bind:value={formData.role}>
            <option value="member">Member</option>
            <option value="manager">Manager</option>
            <option value="admin">Admin</option>
          </select>
        </div>

        <div class="role-descriptions">
          <h4>Role Descriptions:</h4>
          <ul>
            <li><strong>Member:</strong> Can view and manage assigned tasks</li>
            <li><strong>Manager:</strong> Can create projects and assign tasks to team members</li>
            <li><strong>Admin:</strong> Full access to all features and settings</li>
          </ul>
        </div>

        <div class="form-actions">
          <button type="button" class="cancel-btn" on:click={closeModal}>Cancel</button>
          <button type="submit" class="submit-btn">
            {editingUser ? 'Update Member' : 'Add Member'}
          </button>
        </div>
      </form>
    </div>
  </div>
{/if}

<style>
  .team-page {
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

  .team-stats {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 1rem;
    margin-bottom: 2rem;
  }

  .stat-card {
    background: white;
    padding: 1.5rem;
    border-radius: 1rem;
    border: 1px solid #e5e7eb;
    text-align: center;
  }

  .stat-card h3 {
    margin: 0 0 0.5rem 0;
    font-size: 2rem;
    font-weight: 700;
    color: #3b82f6;
  }

  .stat-card p {
    margin: 0;
    color: #6b7280;
    font-size: 0.875rem;
  }

  .team-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 1.5rem;
  }

  .member-card {
    background: white;
    border-radius: 1rem;
    padding: 1.5rem;
    border: 1px solid #e5e7eb;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    transition: box-shadow 0.2s;
    position: relative;
  }

  .member-card:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  .member-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 1rem;
  }

  .member-avatar {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 3rem;
    height: 3rem;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border-radius: 50%;
    font-weight: 600;
    font-size: 1.125rem;
  }

  .member-actions {
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

  .member-info {
    margin-bottom: 1.5rem;
  }

  .member-info h3 {
    margin: 0 0 0.25rem 0;
    font-size: 1.125rem;
    font-weight: 600;
    color: #111827;
  }

  .member-email {
    margin: 0 0 0.75rem 0;
    color: #6b7280;
    font-size: 0.875rem;
  }

  .role-badge {
    display: inline-block;
    padding: 0.25rem 0.75rem;
    border-radius: 9999px;
    font-size: 0.75rem;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .member-meta {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    padding: 1rem;
    background: #f8fafc;
    border-radius: 0.5rem;
    margin-bottom: 1rem;
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

  .current-user-badge {
    position: absolute;
    top: 1rem;
    right: 1rem;
    display: flex;
    align-items: center;
    gap: 0.25rem;
    padding: 0.25rem 0.5rem;
    background: #059669;
    color: white;
    border-radius: 0.375rem;
    font-size: 0.75rem;
    font-weight: 500;
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

  .user-form {
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
  .form-group select {
    padding: 0.75rem;
    border: 1px solid #d1d5db;
    border-radius: 0.5rem;
    font-size: 0.875rem;
    transition: border-color 0.2s, box-shadow 0.2s;
  }

  .form-group input:focus,
  .form-group select:focus {
    outline: none;
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  }

  .role-descriptions {
    background: #f8fafc;
    padding: 1rem;
    border-radius: 0.5rem;
    border: 1px solid #e5e7eb;
  }

  .role-descriptions h4 {
    margin: 0 0 0.5rem 0;
    font-size: 0.875rem;
    color: #374151;
  }

  .role-descriptions ul {
    margin: 0;
    padding-left: 1rem;
  }

  .role-descriptions li {
    font-size: 0.75rem;
    color: #6b7280;
    margin-bottom: 0.25rem;
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
    .team-page {
      padding: 1rem;
    }

    .page-header {
      flex-direction: column;
      gap: 1rem;
    }

    .team-grid {
      grid-template-columns: 1fr;
    }

    .current-user-badge {
      position: static;
      align-self: flex-start;
      margin-top: 0.5rem;
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
