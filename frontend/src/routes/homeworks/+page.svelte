<script>
	import { onMount } from 'svelte';
	import { API_BASE } from '$lib/config';
	
	let homeworks = [];
	let loading = true;
	let errorMsg = '';

	onMount(async () => {
		const token = localStorage.getItem('token');
		if (!token) {
			window.location.href = '/login';
			return;
		}

		try {
			const res = await fetch(`${API_BASE}/homeworks`, {
				headers: {
					'Authorization': `Bearer ${token}`
				}
			});
			
			if (res.status === 401) {
				localStorage.removeItem('token');
				localStorage.removeItem('username');
				window.location.href = '/login';
				return;
			}
			
			if (!res.ok) throw new Error('Failed to fetch homeworks');
			
			homeworks = await res.json();
		} catch (err) {
			errorMsg = err.message || 'Server connection error';
		} finally {
			loading = false;
		}
	});

	function formatDate(dateString) {
		if (!dateString) return 'No due date';
		const options = { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' };
		return new Date(dateString).toLocaleDateString('th-TH', options);
	}
</script>

<svelte:head>
	<title>Homeworks | Fundamental Web Programming</title>
</svelte:head>

<div class="container py-5">
	<div class="row mb-5">
		<div class="col-12 border-bottom pb-4">
			<h2 class="fw-bold tracking-tight">การบ้าน (Homework)</h2>
			<p class="text-muted mb-0">รายการการบ้านที่ได้รับมอบหมาย</p>
		</div>
	</div>

	{#if loading}
		<div class="text-center py-5">
			<div class="spinner-border text-dark" role="status">
				<span class="visually-hidden">Loading...</span>
			</div>
		</div>
	{:else if errorMsg}
		<div class="alert alert-danger" role="alert">
			<i class="bi bi-exclamation-triangle me-2"></i> {errorMsg}
		</div>
	{:else}
		<div class="row g-4">
			{#if homeworks.length === 0}
				<div class="col-12 text-center text-muted py-5">
					<p>ยังไม่มีการบ้านในขณะนี้</p>
				</div>
			{:else}
				{#each homeworks as homework}
					<div class="col-md-6 col-lg-4">
						<a href="/homeworks/{homework.id}" class="text-decoration-none text-dark d-block h-100">
							<div class="card h-100 border-0 shadow-sm lesson-card">
								<div class="card-body p-4 d-flex flex-column">
									<div class="mb-3">
										<h5 class="card-title fw-bold mb-0">{homework.title}</h5>
									</div>
									<p class="card-text text-muted flex-grow-1" style="display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;">{homework.description}</p>
									<div class="mt-4 pt-3 border-top d-flex flex-column gap-2">
										<div class="text-danger small fw-medium">
											<i class="bi bi-calendar-x"></i> กำหนดส่ง: {formatDate(homework.due_date)}
										</div>
										<div class="d-flex justify-content-end mt-2">
											<span class="btn btn-outline-premium btn-sm rounded-pill px-3 text-decoration-none">ดูรายละเอียด →</span>
										</div>
									</div>
								</div>
							</div>
						</a>
					</div>
				{/each}
			{/if}
		</div>
	{/if}
</div>

<style>
	.tracking-tight {
		letter-spacing: -0.5px;
	}

	.lesson-card {
		border-radius: 12px;
		transition: all 0.3s ease;
		background-color: #fff;
		border: 1px solid rgba(0,0,0,0.05) !important;
	}

	.lesson-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 12px 24px rgba(0,0,0,0.06) !important;
		border-color: rgba(0,0,0,0.1) !important;
	}
</style>
