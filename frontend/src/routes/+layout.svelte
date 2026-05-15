<script>
	import 'bootstrap/dist/css/bootstrap.min.css';
	import { browser } from '$app/environment';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { fade, fly } from 'svelte/transition';
	
	let user = null;
	let role = null;

	$: {
		if (browser) {
			const rawRole = localStorage.getItem('role') || 'guest';
			const currentRole = rawRole.replace(/^["']|["']$/g, '').trim();
			const path = $page.url.pathname;

			if (path.startsWith('/admin') && currentRole !== 'admin') {
				alert('Access Denied: Admins only!');
				window.location.href = '/lessons';
			}
		}
	}

	onMount(() => {
		import('bootstrap/dist/js/bootstrap.bundle.min.js');
		
		const updateState = () => {
			const token = localStorage.getItem('token');
			const username = localStorage.getItem('username');
			const rawRole = localStorage.getItem('role');
			if (token && username) {
				user = username;
				role = rawRole ? rawRole.replace(/^["']|["']$/g, '').trim() : null;
			} else {
				user = null;
				role = null;
			}
		};
		
		updateState();
		window.addEventListener('storage', updateState);
		
		return () => {
			window.removeEventListener('storage', updateState);
		};
	});

	function logout() {
		localStorage.removeItem('token');
		localStorage.removeItem('username');
		localStorage.removeItem('role');
		user = null;
		role = null;
		window.location.href = '/';
	}
</script>

<style>
	:global(body) {
		background-color: #fcfcfc;
		color: #333;
		font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
	}
	
	/* Minimalist overrides */
	.navbar {
		background-color: rgba(255, 255, 255, 0.95);
		backdrop-filter: blur(10px);
		border-bottom: 1px solid #f0f0f0;
	}
	
	.navbar-brand {
		font-weight: 600;
		letter-spacing: 0.5px;
	}

	.nav-link {
		font-weight: 500;
		color: #555 !important;
		transition: color 0.2s ease;
	}
	
	.nav-link:hover {
		color: #000 !important;
	}

	.btn-premium {
		background-color: #222;
		color: #fff;
		border: 1px solid #222;
		border-radius: 6px;
		font-weight: 500;
		padding: 0.5rem 1.5rem;
		transition: all 0.3s ease;
	}
	
	.btn-premium:hover {
		background-color: #000;
		border-color: #000;
		color: #fff;
		box-shadow: 0 4px 12px rgba(0,0,0,0.1);
	}

	.btn-outline-premium {
		background-color: transparent;
		color: #222;
		border: 1px solid #ddd;
		border-radius: 6px;
		font-weight: 500;
		padding: 0.5rem 1.5rem;
		transition: all 0.3s ease;
	}

	.btn-outline-premium:hover {
		background-color: #f9f9f9;
		border-color: #ccc;
		color: #000;
	}

	main {
		min-height: calc(100vh - 140px); /* 140px for navbar + footer approx */
	}
</style>

<svelte:head>
	<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</svelte:head>

<nav class="navbar navbar-expand-lg sticky-top py-3">
	<div class="container">
		<a class="navbar-brand text-dark" href="/">FWP KMITL</a>
		<button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
			<span class="navbar-toggler-icon"></span>
		</button>
		<div class="collapse navbar-collapse" id="navbarNav">
			<ul class="navbar-nav me-auto">
				<li class="nav-item">
					<a class="nav-link {$page.url.pathname === '/' ? 'text-dark fw-bold' : ''}" href="/">Home</a>
				</li>
				<li class="nav-item">
					<a class="nav-link {$page.url.pathname === '/lessons' ? 'text-dark fw-bold' : ''}" href="/lessons">Lessons</a>
				</li>
				<li class="nav-item">
					<a class="nav-link {$page.url.pathname.startsWith('/homeworks') ? 'text-dark fw-bold' : ''}" href="/homeworks">Homeworks</a>
				</li>
				<li class="nav-item">
					<a class="nav-link {$page.url.pathname.startsWith('/files') ? 'text-dark fw-bold' : ''}" href="/files">Files</a>
				</li>
				<li class="nav-item">
					<a class="nav-link {$page.url.pathname.startsWith('/files') ? 'text-dark fw-bold' : ''}" href="/database">Database</a>
				</li>
			</ul>
			<div class="d-flex align-items-center gap-3 mt-3 mt-lg-0">
				{#if user}
					{#if role === 'admin'}
						<a href="/admin" class="btn btn-danger btn-sm me-2">Admin Panel</a>
					{/if}
					<span class="text-secondary fw-medium">Hello, {user}</span>
					<button class="btn btn-outline-premium btn-sm" on:click={logout}>Log out</button>
				{:else}
					<a href="/login" class="nav-link">Log in</a>
					<a href="/register" class="btn btn-premium btn-sm">Try for free</a>
				{/if}
			</div>
		</div>
	</div>
</nav>

<main style="overflow-x: hidden;">
	{#key $page.url.pathname}
		<div in:fly={{ y: 15, duration: 300, delay: 200 }} out:fade={{ duration: 200 }}>
			<slot />
		</div>
	{/key}
</main>

<footer class="py-4 text-center text-muted" style="border-top: 1px solid #f0f0f0; background-color: #fff; font-size: 0.85rem;">
	<div class="container">
		<p class="mb-0">&copy; {new Date().getFullYear()} Fundamental Web Programming IT KMITL. All rights reserved.</p>
	</div>
</footer>
