<script>
	import { onMount } from "svelte";
	import { API_BASE } from '$lib/config';

	let lessons = $state([]);
	let loading = $state(true);
	let errorMsg = $state("");
	let search = $state("");

	async function handleSearch() {
		search = document.getElementById("search-input").value;
		try {
			const res = await fetch(
				`${API_BASE}/lessons/search?search=${search}`,
				{
					headers: {
						Authorization: `Bearer ${localStorage.getItem("token")}`,
					},
				},
			);

			if (res.status === 401) {
				localStorage.removeItem("token");
				localStorage.removeItem("username");
				window.location.href = "/login";
				return;
			}

			if (!res.ok) throw new Error("Failed to fetch lessons");
			lessons = await res.json();
		} catch (err) {
			errorMsg = err.message || "Server connection error";
		}
	}

	onMount(async () => {
		const token = localStorage.getItem("token");
		if (!token) {
			window.location.href = "/login";
			return;
		}

		try {
			const res = await fetch(`${API_BASE}/lessons`, {
				headers: {
					Authorization: `Bearer ${token}`,
				},
			});

			if (res.status === 401) {
				localStorage.removeItem("token");
				localStorage.removeItem("username");
				window.location.href = "/login";
				return;
			}

			if (!res.ok) throw new Error("Failed to fetch lessons");

			lessons = await res.json();
		} catch (err) {
			errorMsg = err.message || "Server connection error";
		} finally {
			loading = false;
		}
	});
</script>

<svelte:head>
	<title>Curriculum | Fundamental Web Programming</title>
</svelte:head>

<div class="container py-5">
	<div class="row mb-5">
		<div class="col-12 border-bottom pb-4">
			<h2 class="fw-bold tracking-tight">Your Learning Path</h2>
			<p class="text-muted mb-0">
				Select a module below to begin learning.
			</p>

			<!-- Search Bar -->
			<div class="row mt-4">
				<div class="col-md-6 col-lg-4">
					<div class="input-group">
						<input
							type="text"
							id="search-input"
							class="form-control"
							placeholder="Search lessons..."
						/>
						<button
							class="input-group-text"
							aria-label="Search"
							onclick={handleSearch}
						>
							<i class="bi bi-search"></i>
						</button>
					</div>
				</div>
			</div>
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
			<i class="bi bi-exclamation-triangle me-2"></i>
			{errorMsg}
		</div>
	{:else}
		<div class="row g-4">
			{#each lessons as lesson, i}
				<div class="col-md-6 col-lg-4">
					<a
						href="/lessons/{lesson.id}"
						class="text-decoration-none text-dark d-block h-100"
					>
						<div class="card h-100 border-0 shadow-sm lesson-card">
							<div class="card-body p-4 d-flex flex-column">
								<div class="d-flex align-items-center mb-3">
									<span class="module-number me-3"
										>{(i + 1)
											.toString()
											.padStart(2, "0")}</span
									>
									<h5 class="card-title fw-bold mb-0">
										{lesson.title}
									</h5>
								</div>
								<p class="card-text text-muted flex-grow-1">
									{lesson.description}
								</p>
								<div
									class="mt-4 pt-3 border-top d-flex justify-content-between align-items-center"
								>
									<span
										class="badge bg-light text-dark fw-normal border"
										>Module {(i + 1)
											.toString()
											.padStart(2, "0")}</span
									>
									<span
										class="btn btn-outline-premium btn-sm rounded-pill px-3 text-decoration-none"
										>Start Module →</span
									>
								</div>
							</div>
						</div>
					</a>
				</div>
			{/each}
		</div>
	{/if}
</div>

<style>
	.tracking-tight {
		letter-spacing: -0.5px;
	}

	.module-number {
		font-family: monospace;
		font-size: 1.5rem;
		font-weight: 700;
		color: #e0e0e0;
	}

	.lesson-card {
		border-radius: 12px;
		transition: all 0.3s ease;
		background-color: #fff;
		border: 1px solid rgba(0, 0, 0, 0.05) !important;
	}

	.lesson-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 12px 24px rgba(0, 0, 0, 0.06) !important;
		border-color: rgba(0, 0, 0, 0.1) !important;
	}
</style>
