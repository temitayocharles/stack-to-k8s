<script lang="ts">
	import { createEventDispatcher } from 'svelte';

	export let users: any[] = [];

	const dispatch = createEventDispatcher();

	function deleteUser(user: any) {
		if (confirm(`Are you sure you want to delete user "${user.name}"?`)) {
			dispatch('deleteUser', user.id);
		}
	}
</script>

<div class="user-list">
	{#if users.length === 0}
		<div class="empty-state">
			<h3>No users yet</h3>
			<p>Create your first user to get started!</p>
		</div>
	{:else}
		<div class="user-grid">
			{#each users as user (user.id)}
				<div class="user-card">
					<div class="user-header">
						<div class="user-avatar">
							{user.name.charAt(0).toUpperCase()}
						</div>
						<div class="user-info">
							<h4>{user.name}</h4>
							<p class="user-email">{user.email}</p>
						</div>
						<button
							class="delete-btn"
							on:click={() => deleteUser(user)}
							aria-label="Delete user"
						>
							✕
						</button>
					</div>

					<div class="user-details">
						<div class="detail-item">
							<span class="label">ID:</span>
							<span class="value">{user.id}</span>
						</div>
						<div class="detail-item">
							<span class="label">Created:</span>
							<span class="value">{new Date(user.created_at).toLocaleDateString()}</span>
						</div>
					</div>
				</div>
			{/each}
		</div>
	{/if}
</div>

<style>
	.user-list {
		width: 100%;
	}

	.empty-state {
		text-align: center;
		padding: 3rem;
		color: #6c757d;
	}

	.empty-state h3 {
		margin-bottom: 0.5rem;
		color: #495057;
	}

	.user-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
		gap: 1rem;
	}

	.user-card {
		background: white;
		border-radius: 12px;
		padding: 1.5rem;
		box-shadow: 0 2px 10px rgba(0,0,0,0.1);
		border: 1px solid #e9ecef;
		transition: all 0.2s;
	}

	.user-card:hover {
		box-shadow: 0 4px 20px rgba(0,0,0,0.15);
		transform: translateY(-2px);
	}

	.user-header {
		display: flex;
		align-items: center;
		margin-bottom: 1rem;
	}

	.user-avatar {
		width: 50px;
		height: 50px;
		border-radius: 50%;
		background: #007bff;
		color: white;
		display: flex;
		align-items: center;
		justify-content: center;
		font-weight: bold;
		font-size: 1.2rem;
		margin-right: 1rem;
		flex-shrink: 0;
	}

	.user-info {
		flex: 1;
	}

	.user-info h4 {
		margin: 0 0 0.25rem 0;
		color: #495057;
	}

	.user-email {
		margin: 0;
		color: #6c757d;
		font-size: 0.875rem;
	}

	.delete-btn {
		background: #dc3545;
		color: white;
		border: none;
		border-radius: 4px;
		width: 32px;
		height: 32px;
		display: flex;
		align-items: center;
		justify-content: center;
		cursor: pointer;
		font-size: 16px;
		transition: background-color 0.2s;
		flex-shrink: 0;
	}

	.delete-btn:hover {
		background: #c82333;
	}

	.user-details {
		border-top: 1px solid #e9ecef;
		padding-top: 1rem;
	}

	.detail-item {
		display: flex;
		justify-content: space-between;
		margin-bottom: 0.5rem;
	}

	.detail-item:last-child {
		margin-bottom: 0;
	}

	.label {
		font-weight: 500;
		color: #495057;
	}

	.value {
		color: #6c757d;
		font-size: 0.875rem;
	}
</style>
