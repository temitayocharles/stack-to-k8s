<script lang="ts">
	import { createEventDispatcher } from 'svelte';

	export let tasks: any[] = [];

	const dispatch = createEventDispatcher();

	function getStatusColor(status: string) {
		switch (status) {
			case 'completed': return '#28a745';
			case 'in_progress': return '#ffc107';
			case 'pending': return '#6c757d';
			default: return '#6c757d';
		}
	}

	function getPriorityColor(priority: string) {
		switch (priority) {
			case 'urgent': return '#dc3545';
			case 'high': return '#fd7e14';
			case 'medium': return '#ffc107';
			case 'low': return '#28a745';
			default: return '#6c757d';
		}
	}

	function updateTaskStatus(task: any, newStatus: string) {
		const updatedTask = { ...task, status: newStatus };
		dispatch('updateTask', updatedTask);
	}

	function deleteTask(task: any) {
		if (confirm('Are you sure you want to delete this task?')) {
			dispatch('deleteTask', task.id);
		}
	}
</script>

<div class="task-list">
	{#if tasks.length === 0}
		<div class="empty-state">
			<h3>No tasks yet</h3>
			<p>Create your first task to get started!</p>
		</div>
	{:else}
		<div class="task-grid">
			{#each tasks as task (task.id)}
				<div class="task-card" class:completed={task.status === 'completed'}>
					<div class="task-header">
						<h4>{task.title}</h4>
						<div class="task-actions">
							<select
								value={task.status}
								on:change={(e) => updateTaskStatus(task, e.target.value)}
								class="status-select"
							>
								<option value="pending">Pending</option>
								<option value="in_progress">In Progress</option>
								<option value="completed">Completed</option>
							</select>
							<button
								class="delete-btn"
								on:click={() => deleteTask(task)}
								aria-label="Delete task"
							>
								✕
							</button>
						</div>
					</div>

					{#if task.description}
						<p class="task-description">{task.description}</p>
					{/if}

					<div class="task-meta">
						<span
							class="priority-badge"
							style="background-color: {getPriorityColor(task.priority)}"
						>
							{task.priority}
						</span>
						<span
							class="status-badge"
							style="background-color: {getStatusColor(task.status)}"
						>
							{task.status.replace('_', ' ')}
						</span>
					</div>

					{#if task.assignee_id}
						<div class="assignee">
							Assigned to: User {task.assignee_id}
						</div>
					{/if}

					<div class="task-dates">
						<small>Created: {new Date(task.created_at).toLocaleDateString()}</small>
					</div>
				</div>
			{/each}
		</div>
	{/if}
</div>

<style>
	.task-list {
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

	.task-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
		gap: 1.5rem;
	}

	.task-card {
		background: white;
		border-radius: 12px;
		padding: 1.5rem;
		box-shadow: 0 2px 10px rgba(0,0,0,0.1);
		border: 1px solid #e9ecef;
		transition: all 0.2s;
	}

	.task-card:hover {
		box-shadow: 0 4px 20px rgba(0,0,0,0.15);
		transform: translateY(-2px);
	}

	.task-card.completed {
		opacity: 0.7;
		background: #f8f9fa;
	}

	.task-header {
		display: flex;
		justify-content: space-between;
		align-items: flex-start;
		margin-bottom: 1rem;
	}

	.task-header h4 {
		margin: 0;
		color: #495057;
		flex: 1;
		margin-right: 1rem;
	}

	.task-actions {
		display: flex;
		gap: 0.5rem;
		align-items: center;
	}

	.status-select {
		padding: 0.25rem 0.5rem;
		border: 1px solid #ced4da;
		border-radius: 4px;
		background: white;
		font-size: 0.875rem;
	}

	.delete-btn {
		background: #dc3545;
		color: white;
		border: none;
		border-radius: 4px;
		width: 24px;
		height: 24px;
		display: flex;
		align-items: center;
		justify-content: center;
		cursor: pointer;
		font-size: 14px;
		transition: background-color 0.2s;
	}

	.delete-btn:hover {
		background: #c82333;
	}

	.task-description {
		color: #6c757d;
		margin-bottom: 1rem;
		line-height: 1.5;
	}

	.task-meta {
		display: flex;
		gap: 0.5rem;
		margin-bottom: 1rem;
	}

	.priority-badge,
	.status-badge {
		padding: 0.25rem 0.5rem;
		border-radius: 12px;
		color: white;
		font-size: 0.75rem;
		font-weight: 500;
		text-transform: uppercase;
	}

	.assignee {
		font-size: 0.875rem;
		color: #6c757d;
		margin-bottom: 0.5rem;
	}

	.task-dates {
		border-top: 1px solid #e9ecef;
		padding-top: 0.5rem;
	}

	.task-dates small {
		color: #6c757d;
	}
</style>
