<script>
	import { API_BASE } from '$lib/config';
	let email = '';
	let password = '';
	let errorMsg = '';
	let loading = false;

	async function handleLogin() {
		loading = true;
		errorMsg = '';
		
		try {
			const res = await fetch(`${API_BASE}/login`, {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ email, password })
			});
			
			const data = await res.json();
			if (!res.ok) {
				errorMsg = data.error || 'Login failed';
			} else {
				localStorage.setItem('token', data.token);
				localStorage.setItem('username', data.username);
				localStorage.setItem('role', 'student');
				window.location.href = '/lessons';
			}
		} catch (err) {
			errorMsg = 'Server connection error';
		} finally {
			loading = false;
		}
	}
</script>

<svelte:head>
	<title>Sign In | Fundamental Web Programming</title>
</svelte:head>

<div class="auth-container d-flex align-items-center justify-content-center">
	<div class="card auth-card border-0 shadow-sm">
		<div class="card-body p-5">
			<div class="text-center mb-4">
				<div class="logo-circle mx-auto mb-3">
					<i class="bi bi-person fs-3"></i>
				</div>
				<h3 class="fw-bold">Welcome back</h3>
				<p class="text-muted">Enter your details to sign in.</p>
			</div>
			
			{#if errorMsg}
				<div class="alert alert-danger py-2 px-3 small">{errorMsg}</div>
			{/if}
			
			<form on:submit|preventDefault={handleLogin}>
				<div class="mb-3">
					<label class="form-label text-secondary small fw-medium">Email</label>
					<input type="email" class="form-control form-control-lg bg-light border-0" bind:value={email} required placeholder="name@example.com">
				</div>
				<div class="mb-4">
					<label class="form-label text-secondary small fw-medium">Password</label>
					<input type="password" class="form-control form-control-lg bg-light border-0" bind:value={password} required placeholder="••••••••">
				</div>
				<button type="submit" class="btn btn-premium w-100 btn-lg mb-3" disabled={loading}>
					{#if loading}
						<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> Signing in...
					{:else}
						Sign in
					{/if}
				</button>
			</form>
			<div class="text-center">
				<span class="text-muted small">Don't have an account? </span>
				<a href="/register" class="text-dark fw-bold small text-decoration-none hover-underline">Sign up</a>
			</div>
		</div>
	</div>
</div>

<style>
	.auth-container {
		min-height: calc(100vh - 150px);
		background-color: #fcfcfc;
	}
	
	.auth-card {
		width: 100%;
		max-width: 420px;
		border-radius: 16px;
	}

	.logo-circle {
		width: 50px;
		height: 50px;
		background-color: #f5f5f5;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.form-control:focus {
		box-shadow: 0 0 0 0.25rem rgba(0,0,0,0.05);
		background-color: #fff !important;
		border: 1px solid #ddd !important;
	}
	
	.hover-underline:hover {
		text-decoration: underline !important;
	}
</style>
