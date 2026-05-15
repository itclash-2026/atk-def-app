<script>
	import { onMount } from 'svelte';
	import { API_BASE } from '$lib/config';
	
	let title = '';
	let description = '';
	let content = '';
	let loading = false;
	let errorMsg = '';
	let successMsg = '';

	onMount(() => {
		const token = localStorage.getItem('token');
		if (!token) {
			window.location.href = '/login';
		}
	});

	async function handleSubmit(event) {
		event.preventDefault();
		loading = true;
		errorMsg = '';
		successMsg = '';

		const token = localStorage.getItem('token');
		
		try {
			const res = await fetch(`${API_BASE}/lessons`, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
					'Authorization': `Bearer ${token}`
				},
				body: JSON.stringify({ title, description, content })
			});

			if (res.status === 401) {
				localStorage.removeItem('token');
				localStorage.removeItem('username');
				window.location.href = '/login';
				return;
			}

			if (!res.ok) {
				const data = await res.json();
				throw new Error(data.error || 'Failed to create lesson');
			}

			successMsg = 'Lesson created successfully!';
			title = '';
			description = '';
			content = '';
		} catch (err) {
			errorMsg = err.message || 'Server connection error';
		} finally {
			loading = false;
		}
	}
</script>

<svelte:head>
	<title>Admin - Create Lesson | Fundamental Web Programming</title>
</svelte:head>

<div class="container py-5">
	<div class="row justify-content-center">
		<div class="col-md-10 col-lg-10">
			<div class="card border-0 shadow-lg rounded-4">
				<div class="card-body p-5">
					<div class="mb-4 text-center">
						<h2 class="fw-bold tracking-tight">Create New Lesson</h2>
						<p class="text-muted">Add a new module to the curriculum</p>
					</div>

					{#if errorMsg}
						<div class="alert alert-danger" role="alert">
							<i class="bi bi-exclamation-triangle me-2"></i> {errorMsg}
						</div>
					{/if}

					{#if successMsg}
						<div class="alert alert-success" role="alert">
							<i class="bi bi-check-circle me-2"></i> {successMsg}
						</div>
					{/if}

					<form on:submit={handleSubmit}>
						<div class="mb-4">
							<label for="title" class="form-label fw-semibold">Lesson Title</label>
							<input type="text" class="form-control form-control-lg bg-light border-0" id="title" bind:value={title} placeholder="Enter lesson title..." required />
						</div>

						<div class="mb-4">
							<label for="description" class="form-label fw-semibold">Short Description</label>
							<textarea class="form-control form-control-lg bg-light border-0" id="description" bind:value={description} rows="2" placeholder="Briefly summarize what students will learn..." required></textarea>
						</div>

						<div class="mb-4">
							<label for="content" class="form-label fw-semibold">Lesson Content (Markdown)</label>
							<textarea class="form-control form-control-lg bg-light border-0 font-monospace" id="content" bind:value={content} rows="8" placeholder="Write your full lesson content here... Use Markdown for formatting (## for headers, ** for bold, etc.)" style="font-size: 0.95rem;" required></textarea>
						</div>

						<div class="d-grid mt-5">
							<button type="submit" class="btn btn-dark btn-lg rounded-pill" disabled={loading}>
								{#if loading}
									<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
									Creating...
								{:else}
									<i class="bi bi-plus-circle me-2"></i> Create Lesson
								{/if}
							</button>
						</div>
					</form>
					
					<div class="text-center mt-4">
						<a href="/lessons" class="text-decoration-none text-muted">
							<i class="bi bi-arrow-left me-1"></i> Back to Lessons
						</a>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<style>
	.tracking-tight {
		letter-spacing: -0.5px;
	}
	
	.form-control:focus {
		box-shadow: 0 0 0 0.25rem rgba(0,0,0,0.05);
		border: 1px solid rgba(0,0,0,0.1) !important;
		background-color: #fff !important;
	}
</style>
