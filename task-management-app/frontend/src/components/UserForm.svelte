<script lang="ts">
	import { createEventDispatcher } from 'svelte';

	export let user: any = null; // null for new user, object for editing
	export let isOpen: boolean = false;

	const dispatch = createEventDispatcher();

	let formData = {
		name: '',
		email: ''
	};

	$: if (user && isOpen) {
		formData = {
			name: user.name || '',
			email: user.email || ''
		};
	} else if (!user && isOpen) {
		formData = {
			name: '',
			email: ''
		};
	}

	function closeModal() {
		dispatch('close');
	}

	function handleSubmit() {
		if (!formData.name.trim()) {
			alert('User name is required');
			return;
		}

		if (!formData.email.trim()) {
			alert('User email is required');
			return;
		}

		// Basic email validation
		const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
		if (!emailRegex.test(formData.email)) {
			alert('Please enter a valid email address');
			return;
		}

		if (task) {
			dispatch('updateUser', { ...user, ...formData });
		} else {
			dispatch('createUser', formData);
		}

		closeModal();
	}

	function handleKeydown(event: KeyboardEvent) {
		if (event.key === 'Escape') {
			closeModal();
		}
	}
</script>

<svelte:window on:keydown={handleKeydown} />

{#if isOpen}
	<div class="modal-overlay" on:click={closeModal}>
		<div class="modal-content" on:click|stopPropagation>
			<div class="modal-header">
				<h3>{user ? 'Edit User' : 'Create New User'}</h3>
				<button class="close-btn" on:click={closeModal} aria-label="Close modal">×</button>
			</div>

			<form on:submit|preventDefault={handleSubmit}>
				<div class="form-group">
					<label for="name">Full Name *</label>
					<input
						type="text"
						id="name"
						bind:value={formData.name}
						placeholder="Enter full name"
						required
					/>
				</div>

				<div class="form-group">
					<label for="email">Email Address *</label>
					<input
						type="email"
						id="email"
						bind:value={formData.email}
						placeholder="Enter email address"
						required
					/>
				</div>

				<div class="form-actions">
					<button type="button" class="cancel-btn" on:click={closeModal}>
						Cancel
					</button>
					<button type="submit" class="submit-btn">
						{user ? 'Update User' : 'Create User'}
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<style>
	.modal-overlay {
		position: fixed;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		background: rgba(0, 0, 0, 0.5);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 1000;
	}

	.modal-content {
		background: white;
		border-radius: 12px;
		padding: 0;
		max-width: 500px;
		width: 90%;
		max-height: 90vh;
		overflow-y: auto;
		box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
	}

	.modal-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 1.5rem;
		border-bottom: 1px solid #e9ecef;
	}

	.modal-header h3 {
		margin: 0;
		color: #495057;
	}

	.close-btn {
		background: none;
		border: none;
		font-size: 24px;
		cursor: pointer;
		color: #6c757d;
		padding: 0;
		width: 32px;
		height: 32px;
		display: flex;
		align-items: center;
		justify-content: center;
		border-radius: 4px;
		transition: background-color 0.2s;
	}

	.close-btn:hover {
		background: #f8f9fa;
		color: #495057;
	}

	form {
		padding: 1.5rem;
	}

	.form-group {
		margin-bottom: 1.5rem;
	}

	label {
		display: block;
		margin-bottom: 0.5rem;
		font-weight: 500;
		color: #495057;
	}

	input {
		width: 100%;
		padding: 0.75rem;
		border: 1px solid #ced4da;
		border-radius: 6px;
		font-size: 1rem;
		transition: border-color 0.2s, box-shadow 0.2s;
		box-sizing: border-box;
	}

	input:focus {
		outline: none;
		border-color: #007bff;
		box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
	}

	.form-actions {
		display: flex;
		gap: 1rem;
		justify-content: flex-end;
		margin-top: 2rem;
		padding-top: 1rem;
		border-top: 1px solid #e9ecef;
	}

	.cancel-btn,
	.submit-btn {
		padding: 0.75rem 1.5rem;
		border: none;
		border-radius: 6px;
		font-size: 1rem;
		cursor: pointer;
		transition: all 0.2s;
		font-weight: 500;
	}

	.cancel-btn {
		background: #6c757d;
		color: white;
	}

	.cancel-btn:hover {
		background: #5a6268;
	}

	.submit-btn {
		background: #007bff;
		color: white;
	}

	.submit-btn:hover {
		background: #0056b3;
	}
</style>
