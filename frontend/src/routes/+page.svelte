<svelte:head>
	<title>Fundamental Web Programming | IT KMITL</title>
</svelte:head>

<div class="hero-section text-center d-flex flex-column justify-content-center align-items-center">
	<div class="ocean">
		<div class="wave"></div>
		<div class="wave"></div>
		<div class="wave"></div>
	</div>
	<div class="container px-4 hero-content">
		<span class="badge rounded-pill bg-light text-dark border border-light-subtle mb-3 px-3 py-2 fw-medium hint-badge">
			Welcome to the Fall 2026 Semester
		</span>
		<h1 class="display-3 fw-bold mb-4 hero-title">Master the Art of <br><span class="text-gradient">Web Engineering</span></h1>
		<p class="lead text-muted mb-5 mx-auto" style="max-width: 600px;">
			Fundamental Web Programming at IT KMITL. Learn the core principles, design patterns, and modern stacks required to build scalable web applications.
		</p>
		<div class="d-flex flex-column flex-sm-row justify-content-center gap-3">
			<a href="/register" class="btn btn-premium btn-lg px-5">Start Learning</a>
			<a href="#curriculum" class="btn btn-outline-premium btn-lg px-5">View Curriculum</a>
		</div>
	</div>
</div>

<section id="curriculum" class="py-5 bg-white">
	<div class="container py-5">
		<div class="row text-center mb-5">
			<div class="col">
				<h2 class="fw-bold">What you'll learn</h2>
				<p class="text-muted">A comprehensive journey from basics to advanced concepts.</p>
			</div>
		</div>
		<div class="row g-4">
			<div class="col-md-4">
				<div class="feature-card h-100 p-4 border rounded-4 bg-light text-center transition-all">
					<div class="icon-circle mx-auto mb-3">
						<i class="bi bi-code-slash fs-4"></i>
					</div>
					<h4 class="fw-semibold">Core Technologies</h4>
					<p class="text-muted mb-0">Deep dive into semantic HTML5, modern CSS3 styling, and ES6+ JavaScript.</p>
				</div>
			</div>
			<div class="col-md-4">
				<div class="feature-card h-100 p-4 border rounded-4 bg-light text-center transition-all">
					<div class="icon-circle mx-auto mb-3">
						<i class="bi bi-braces fs-4"></i>
					</div>
					<h4 class="fw-semibold">Modern Frameworks</h4>
					<p class="text-muted mb-0">Explore state-of-the-art libraries like SvelteKit and Bootstrap to build SPAs.</p>
				</div>
			</div>
			<div class="col-md-4">
				<div class="feature-card h-100 p-4 border rounded-4 bg-light text-center transition-all">
					<div class="icon-circle mx-auto mb-3">
						<i class="bi bi-server fs-4"></i>
					</div>
					<h4 class="fw-semibold">Backend Integration</h4>
					<p class="text-muted mb-0">Connect your interfaces with powerful Go backends and PostgreSQL databases.</p>
				</div>
			</div>
		</div>
	</div>
</section>

<style>
	.hero-section {
		min-height: 80vh;
		background: radial-gradient(circle at center, #ffffff 0%, #fcfcfc 100%);
		position: relative;
		overflow: hidden;
	}

	.hero-content {
		position: relative;
		z-index: 10;
	}

	.ocean {
		position: absolute;
		bottom: 0;
		left: 0;
		width: 100%;
		height: 15vw;
		min-height: 120px;
		overflow: hidden;
		z-index: 1;
	}

	.wave {
		background: url('data:image/svg+xml;utf8,%3Csvg viewBox="0 0 1000 100" xmlns="http://www.w3.org/2000/svg"%3E%3Cpath d="M 0 50 Q 250 100 500 50 T 1000 50 L 1000 100 L 0 100 Z" fill="%23f1f3f5" opacity="0.8" /%3E%3C/svg%3E') repeat-x;
		position: absolute;
		bottom: 0;
		width: calc(100vw + 2000px);
		height: 120px;
		background-size: 1000px 120px;
		animation: wave-animation 15s linear infinite;
	}

	.wave:nth-of-type(2) {
		background: url('data:image/svg+xml;utf8,%3Csvg viewBox="0 0 1000 100" xmlns="http://www.w3.org/2000/svg"%3E%3Cpath d="M 0 50 Q 250 100 500 50 T 1000 50 L 1000 100 L 0 100 Z" fill="%23e9ecef" opacity="0.6" /%3E%3C/svg%3E') repeat-x;
		bottom: -15px;
		animation: wave-animation 22s linear infinite reverse;
	}

	.wave:nth-of-type(3) {
		background: url('data:image/svg+xml;utf8,%3Csvg viewBox="0 0 1000 100" xmlns="http://www.w3.org/2000/svg"%3E%3Cpath d="M 0 50 Q 250 100 500 50 T 1000 50 L 1000 100 L 0 100 Z" fill="%23e2e8f0" opacity="0.4" /%3E%3C/svg%3E') repeat-x;
		bottom: -25px;
		animation: wave-animation 18s linear infinite;
	}

	@keyframes wave-animation {
		0% {
			transform: translateX(0);
		}
		100% {
			transform: translateX(-1000px);
		}
	}

	.hero-title {
		letter-spacing: -1.5px;
		line-height: 1.1;
		color: #111;
	}

	.text-gradient {
		background: linear-gradient(135deg, #111 0%, #666 100%);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	.hint-badge {
		font-size: 0.85rem;
		box-shadow: 0 2px 10px rgba(0,0,0,0.03);
	}

	.feature-card:hover {
		transform: translateY(-5px);
		box-shadow: 0 10px 30px rgba(0,0,0,0.05);
		background-color: #fff !important;
	}

	.icon-circle {
		width: 60px;
		height: 60px;
		background-color: #fff;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		box-shadow: 0 4px 15px rgba(0,0,0,0.04);
		color: #222;
	}
	
	.transition-all {
		transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
	}
</style>
