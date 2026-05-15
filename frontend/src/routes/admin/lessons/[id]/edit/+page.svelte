<script>
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { API_BASE } from '$lib/config';
	
	let title = '';
	let description = '';
	let content = '';
	let loading = true;
	let errorMsg = '';
	let successMsg = '';
	let lessonId = '';

	onMount(async () => {
		const token = localStorage.getItem('token');
		if (!token) {
			window.location.href = '/login';
			return;
		}
		
		lessonId = $page.params.id;

		try {
			const res = await fetch(`${API_BASE}/lessons/${lessonId}`, {
				headers: {
					'Authorization': `Bearer ${token}`
				}
			});

			if (res.status === 401) {
				window.location.href = '/login';
				return;
			}

			if (!res.ok) {
				throw new Error('Failed to load lesson for editing');
			}

			const lessonData = await res.json();
			title = lessonData.title;
			description = lessonData.description;
			content = lessonData.content;
		} catch (err) {
			errorMsg = err.message || 'Server connection error';
		} finally {
			loading = false;
		}
	});

	async function handleSubmit(event) {
		event.preventDefault();
		loading = true;
		errorMsg = '';
		successMsg = '';

		const token = localStorage.getItem('token');
		
		try {
			const res = await fetch(`${API_BASE}/lessons/${lessonId}`, {
				method: 'PUT',
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
				throw new Error(data.error || 'Failed to update lesson');
			}

			successMsg = 'Lesson updated successfully!';
			setTimeout(() => {
				window.location.href = `/lessons/${lessonId}`;
			}, 1500);
		} catch (err) {
			errorMsg = err.message || 'Server connection error';
		} finally {
			loading = false;
		}
	}
</script>

<svelte:head>
	<title>Admin - Edit Lesson | Fundamental Web Programming</title>
</svelte:head>

<div class="container py-5">
	<div class="row justify-content-center">
		<div class="col-md-10 col-lg-10">
			<div class="card border-0 shadow-lg rounded-4">
				<div class="card-body p-5">
					<div class="mb-4 text-center">
						<h2 class="fw-bold tracking-tight">Edit Lesson Module</h2>
						<p class="text-muted">Modify existing curriculum module</p>
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
							<textarea class="form-control form-control-lg bg-light border-0 font-monospace" id="content" bind:value={content} rows="15" placeholder="Write your full lesson content here... Use Markdown for formatting" style="font-size: 0.95rem; white-space: pre;" required></textarea>
						</div>

						<div class="d-grid mt-5">
							<button type="submit" class="btn btn-warning btn-lg rounded-pill" disabled={loading}>
								{#if loading}
									<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
									Updating...
								{:else}
									<i class="bi bi-cloud-arrow-up-fill me-2"></i> Save Changes
								{/if}
							</button>
						</div>
					</form>
					
					<div class="text-center mt-4 border-top pt-4">
						<a href="/lessons/{lessonId}" class="text-decoration-none text-muted me-4">
							<i class="bi bi-arrow-left me-1"></i> Back to Lesson
						</a>
						<a href="/admin/lessons" class="text-decoration-none text-muted">
							<i class="bi bi-plus-square me-1"></i> Create New
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
		box-shadow: 0 0 0 0.25rem rgba(255, 193, 7, 0.25);
		border: 1px solid rgba(255, 193, 7, 0.5) !important;
		background-color: #fff !important;
	}
</style>
