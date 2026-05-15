<script>
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { API_BASE } from '$lib/config';

	let lesson = null;
	let loading = true;
	let errorMsg = '';
	let role = null;

	function renderMarkdown(md) {
		if (!md) return '';
		let html = md;

		html = html.replace(/</g, '&lt;').replace(/>/g, '&gt;');
		html = html.replace(/```(python|php|go|bash|sh)\n([\s\S]*?)```/g, (_, lang, code) => {
			const rawCode = code.replace(/&lt;/g, '<').replace(/&gt;/g, '>');
			const encodedCode = btoa(unescape(encodeURIComponent(rawCode.trim())));
			const runId = 'run-' + Math.random().toString(36).substr(2, 9);
			return `<div class="interactive-code-container mb-4 mt-2">
					<span class="auto-execute-payload d-none" data-lang="${lang}" data-code="${encodedCode}" data-runid="${runId}"></span>
					<div id="${runId}-container" class="output-container d-none">
						<pre id="${runId}" class="p-3 m-0 font-monospace small whitespace-pre-wrap" style="white-space: pre-wrap; word-break: break-all; min-height: 60px;"></pre>
					</div>
				</div>`;
		});

		html = html.replace(/```(\w*)\n([\s\S]*?)```/g, (_, lang, code) => {
			if (['python', 'php', 'go', 'bash', 'sh'].includes(lang)) return _;
			return `<pre class="code-block"><code class="language-${lang}">${code.trim()}</code></pre>`;
		});

		html = html.replace(/^(\|.+\|)\n(\|[-| :]+\|)\n((?:\|.+\|\n?)+)/gm, (_, header, sep, body) => {
			const ths = header.split('|').filter(c => c.trim()).map(c => `<th>${c.trim()}</th>`).join('');
			const rows = body.trim().split('\n').map(row => {
				const tds = row.split('|').filter(c => c.trim()).map(c => `<td>${c.trim()}</td>`).join('');
				return `<tr>${tds}</tr>`;
			}).join('');
			return `<div class="table-responsive"><table class="table table-bordered table-sm mt-3 mb-3"><thead><tr>${ths}</tr></thead><tbody>${rows}</tbody></table></div>`;
		});

		html = html.replace(/^### (.+)$/gm, '<h4 class="mt-4 mb-2 fw-semibold">$1</h4>');
		html = html.replace(/^## (.+)$/gm, '<h3 class="mt-4 mb-3 fw-bold">$1</h3>');
		html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
		html = html.replace(/`([^`]+)`/g, '<code class="inline-code">$1</code>');
		html = html.replace(/^\d+\.\s+(.+)$/gm, '<li class="mb-1">$1</li>');
		html = html.replace(/^- (.+)$/gm, '<li class="mb-1">$1</li>');
		html = html.replace(/((?:<li[^>]*>.*<\/li>\n?)+)/g, '<ul class="lesson-list mb-3">$1</ul>');
		html = html.replace(/^(?!<[a-z/])((?!^\s*$).+)$/gm, '<p>$1</p>');
		html = html.replace(/\n{3,}/g, '\n\n');

		return html;
	}

	onMount(async () => {
		const token = localStorage.getItem('token');
		if (!token) {
			window.location.href = '/login';
			return;
		}

		role = localStorage.getItem('role') ? localStorage.getItem('role').replace(/^["']|["']$/g, '').trim() : null;

		const id = $page.params.id;

		try {
			const res = await fetch(`${API_BASE}/lessons/${id}`, {
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

			if (res.status === 404) {
				errorMsg = 'Lesson not found.';
				loading = false;
				return;
			}

			if (!res.ok) throw new Error('Failed to fetch lesson');

			lesson = await res.json();
		} catch (err) {
			errorMsg = err.message || 'Server connection error';
		} finally {
			loading = false;
		}
	});

	onMount(() => {
		window.runCode = async (lang, b64code, targetId) => {
			const token = localStorage.getItem('token');
			if (!token) return;

			const code = decodeURIComponent(escape(atob(b64code)));
			
			const outputContainer = document.getElementById(targetId + '-container');
			const outputEl = document.getElementById(targetId);
			if (!outputEl || !outputContainer) return;
			
			outputContainer.classList.remove('d-none');
			outputEl.textContent = "Processing payload...";
			outputEl.className = "p-3 bg-light border rounded font-monospace small text-dark mb-0";

			try {
				const res = await fetch(`${API_BASE}/execute`, {
					method: 'POST',
					headers: {
						'Content-Type': 'application/json',
						'Authorization': `Bearer ${token}`
					},
					body: JSON.stringify({ language: lang, code: code })
				});

				const data = await res.json();
				
				if (!res.ok) {
					outputEl.textContent = `Error: ${data.error || 'Execution failed'}`;
					outputEl.classList.add('text-danger', 'border-danger');
				} else if (data.error) {
					outputEl.textContent = data.output + "\n\nError details: " + data.error;
					outputEl.classList.add('text-danger', 'border-danger');
				} else {
					outputEl.textContent = data.output || '(No output)';
				}
			} catch (err) {
				outputEl.textContent = "Connection failed: " + err.message;
				outputEl.classList.add('text-danger', 'border-danger');
			}
		};

		setTimeout(() => {
			const payloads = document.querySelectorAll('.auto-execute-payload');
			payloads.forEach(node => {
				const lang = node.getAttribute('data-lang');
				const code = node.getAttribute('data-code');
				const runId = node.getAttribute('data-runid');
				
				if (lang && code && runId) {
					window.runCode(lang, code, runId);
				}
			});
		}, 600);
	});
</script>

<svelte:head>
	<title>{lesson ? lesson.title : 'Loading...'} | Fundamental Web Programming</title>
</svelte:head>

<div class="container py-5">
	{#if loading}
		<div class="text-center py-5">
			<div class="spinner-border text-dark" role="status">
				<span class="visually-hidden">Loading...</span>
			</div>
		</div>
	{:else if errorMsg}
		<div class="text-center py-5">
			<div class="alert alert-danger d-inline-block" role="alert">
				<i class="bi bi-exclamation-triangle me-2"></i> {errorMsg}
			</div>
			<div class="mt-3">
				<a href="/lessons" class="btn btn-outline-dark rounded-pill px-4">← Back to Lessons</a>
			</div>
		</div>
	{:else if lesson}
		<div class="row mb-4">
			<div class="col-12">
				<a href="/lessons" class="text-decoration-none text-muted d-inline-flex align-items-center back-link mb-3">
					<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="me-1"><polyline points="15 18 9 12 15 6"></polyline></svg>
					Back to Lessons
				</a>
			</div>
		</div>

		<div class="row justify-content-center">
			<div class="col-lg-9">
				<div class="lesson-header mb-5 pb-4 border-bottom">
					<span class="badge bg-dark rounded-pill px-3 py-2 mb-3">Module {lesson.id.toString().padStart(2, '0')}</span>
					<h1 class="fw-bold display-6 tracking-tight">{lesson.title}</h1>
					<p class="lead text-muted">{lesson.description}</p>
				</div>

				<article class="lesson-content">
					{@html renderMarkdown(lesson.content)}
				</article>

				<div class="mt-5 pt-4 border-top d-flex justify-content-between align-items-center">
					<a href="/lessons" class="btn btn-outline-dark rounded-pill px-4">← All Modules</a>
					<div>
						{#if role === 'admin'}
							<a href="/admin/lessons/{lesson.id}/edit" class="btn btn-warning rounded-pill px-4 me-2"><i class="bi bi-pencil-square"></i> Edit Lesson</a>
						{/if}
						{#if lesson.id}
							<a href="/lessons/{lesson.id + 1}" class="btn btn-dark rounded-pill px-4">Next Module →</a>
						{/if}
					</div>
				</div>
			</div>
		</div>
	{/if}
</div>

<style>
	.tracking-tight {
		letter-spacing: -0.5px;
	}

	.back-link {
		transition: color 0.2s ease;
	}

	.back-link:hover {
		color: #000 !important;
	}

	.lesson-header {
		animation: fadeInUp 0.5s ease-out;
	}

	@keyframes fadeInUp {
		from {
			opacity: 0;
			transform: translateY(16px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	@keyframes spin {
		100% {
			transform: rotate(360deg);
		}
	}

	@keyframes blink {
		0%, 100% { opacity: 1; box-shadow: 0 0 8px #f9e2af; }
		50% { opacity: 0.4; box-shadow: 0 0 2px #f9e2af; }
	}

	:global(.lesson-content h3) {
		font-size: 1.5rem;
		margin-top: 2rem;
	}

	:global(.lesson-content h4) {
		font-size: 1.15rem;
		color: #333;
	}

	:global(.lesson-content p) {
		line-height: 1.8;
		color: #444;
	}

	:global(.lesson-content .code-block) {
		background-color: #1e1e2e !important;
		color: #cdd6f4;
		border-radius: 10px;
		padding: 1.25rem 1.5rem;
		overflow-x: auto;
		font-size: 0.875rem;
		line-height: 1.6;
		margin: 1rem 0 1.5rem 0;
		border: 1px solid rgba(255,255,255,0.05);
	}

	:global(.btn-run-premium) {
		background: linear-gradient(135deg, #a6e3a1 0%, #94e2d5 100%);
		border: none !important;
		border-radius: 8px !important;
		box-shadow: 0 4px 12px rgba(166, 227, 161, 0.4);
		transition: all 0.2s ease-in-out;
	}

	:global(.btn-run-premium:hover) {
		transform: translateY(-2px);
		box-shadow: 0 6px 16px rgba(166, 227, 161, 0.6);
		background: linear-gradient(135deg, #b4f1af 0%, #a2eee1 100%);
	}

	:global(.btn-run-premium:active) {
		transform: translateY(1px);
		box-shadow: 0 2px 8px rgba(166, 227, 161, 0.4);
	}

	:global(.lesson-content .code-block code) {
		background: none;
		color: inherit;
		padding: 0;
		font-family: 'JetBrains Mono', 'Fira Code', monospace;
	}

	:global(.lesson-content .inline-code) {
		background-color: #f0f0f0;
		color: #d63384;
		padding: 2px 6px;
		border-radius: 4px;
		font-size: 0.875em;
		font-family: 'JetBrains Mono', 'Fira Code', monospace;
	}

	:global(.lesson-content .lesson-list) {
		padding-left: 1.5rem;
		list-style: none;
	}

	:global(.lesson-content .lesson-list li) {
		position: relative;
		padding-left: 1rem;
		line-height: 1.8;
		color: #444;
	}

	:global(.lesson-content .lesson-list li::before) {
		content: '▸';
		position: absolute;
		left: -0.25rem;
		color: #888;
	}

	:global(.lesson-content .table) {
		font-size: 0.9rem;
	}

	:global(.lesson-content .table th) {
		background-color: #f8f9fa;
		font-weight: 600;
	}
</style>
