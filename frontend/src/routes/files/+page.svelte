<script>
	import { onMount } from 'svelte';
	import { fly, fade, slide } from 'svelte/transition';
	import { API_BASE } from '$lib/config';

	let files = [];
	let loading = true;
	let errorMsg = '';
	let searchQuery = '';

	let fileToUpload = null;
	let isUploading = false;
	let uploadResult = null;
	let execLog = '';

	let deleteConfirm = null;
	let showNewFileModal = false;
	let newFileName = '';
	let newFileContent = '';
	let isCreatingFile = false;

	let viewMode = 'grid';

	onMount(() => {
		const token = localStorage.getItem('token');
		if (!token) {
			window.location.href = '/login';
			return;
		}
		fetchFiles();
	});

	async function fetchFiles() {
		loading = true;
		errorMsg = '';
		const token = localStorage.getItem('token');
		try {
			const res = await fetch(`${API_BASE}/files`, {
				headers: { 'Authorization': `Bearer ${token}` }
			});
			if (res.status === 401) {
				localStorage.removeItem('token');
				localStorage.removeItem('username');
				window.location.href = '/login';
				return;
			}
			if (!res.ok) throw new Error('Failed to fetch files');
			files = await res.json();
		} catch (err) {
			errorMsg = err.message;
		} finally {
			loading = false;
		}
	}

	async function uploadFile() {
		if (!fileToUpload) return;
		isUploading = true;
		uploadResult = null;
		execLog = '';
		const token = localStorage.getItem('token');
		const formData = new FormData();
		formData.append('file', fileToUpload);

		try {
			const res = await fetch(`${API_BASE}/files`, {
				method: 'POST',
				headers: { 'Authorization': `Bearer ${token}` },
				body: formData
			});
			const data = await res.json();
			if (!res.ok) throw new Error(data.error || 'Upload failed');

			uploadResult = data.message;
			if (data.exec_log) {
				execLog = data.exec_log;
			}
			fileToUpload = null;
			await fetchFiles();
		} catch (err) {
			errorMsg = err.message;
		} finally {
			isUploading = false;
		}
	}

	async function createNewFile() {
		if (!newFileName.trim()) return;
		isCreatingFile = true;
		const token = localStorage.getItem('token');
		const blob = new Blob([newFileContent], { type: 'text/plain' });
		const formData = new FormData();
		formData.append('file', blob, newFileName);

		try {
			const res = await fetch(`${API_BASE}/files`, {
				method: 'POST',
				headers: { 'Authorization': `Bearer ${token}` },
				body: formData
			});
			const data = await res.json();
			if (!res.ok) throw new Error(data.error || 'Create failed');
			uploadResult = data.message;
			if (data.exec_log) execLog = data.exec_log;
			newFileName = '';
			newFileContent = '';
			showNewFileModal = false;
			await fetchFiles();
		} catch (err) {
			errorMsg = err.message;
		} finally {
			isCreatingFile = false;
		}
	}

	async function deleteFile(fileName) {
		const token = localStorage.getItem('token');
		try {
			const res = await fetch(`${API_BASE}/files/${fileName}`, {
				method: 'DELETE',
				headers: { 'Authorization': `Bearer ${token}` }
			});
			if (!res.ok) throw new Error('Delete failed');
			deleteConfirm = null;
			await fetchFiles();
		} catch (err) {
			errorMsg = err.message;
		}
	}

	function triggerUpload() {
		document.getElementById('hiddenFileInput').click();
	}

	function handleFileSelected(event) {
		fileToUpload = event.target.files.length > 0 ? event.target.files[0] : null;
		if (fileToUpload) uploadFile();
	}

	function formatSize(bytes) {
		if (bytes < 1024) return bytes + ' B';
		if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB';
		return (bytes / 1048576).toFixed(1) + ' MB';
	}

	function formatDate(dateString) {
		const now = new Date();
		const date = new Date(dateString);
		const diff = now - date;
		const mins = Math.floor(diff / 60000);
		const hours = Math.floor(diff / 3600000);
		const days = Math.floor(diff / 86400000);

		if (mins < 1) return 'just now';
		if (mins < 60) return `${mins} minutes ago`;
		if (hours < 24) return `${hours} hours ago`;
		if (days < 30) return `${days} days ago`;
		return date.toLocaleDateString('en-US');
	}

	function getFileIcon(name) {
		const ext = name.split('.').pop().toLowerCase();
		const icons = {
			'py': '🐍', 'js': '📜', 'sh': '⚡', 'go': '🔵',
			'html': '🌐', 'css': '🎨', 'zip': '📦', 'pdf': '📕',
			'png': '🖼️', 'jpg': '🖼️', 'jpeg': '🖼️', 'txt': '📝',
			'md': '📝', 'json': '📋', 'php': '🐘', 'c': '⚙️',
			'cpp': '⚙️', 'java': '☕', 'rs': '🦀', 'rb': '💎'
		};
		return icons[ext] || '📄';
	}

	$: filteredFiles = files.filter(f =>
		f.name.toLowerCase().includes(searchQuery.toLowerCase())
	);
</script>

<svelte:head>
	<title>File Browser | Fundamental Web Programming</title>
</svelte:head>

<!-- Hidden file input -->
<input type="file" id="hiddenFileInput" on:change={handleFileSelected} style="display:none;">

<div class="fb-container">
	<!-- Sidebar -->
	<aside class="fb-sidebar">
		<div class="sidebar-logo">
		</div>

		<nav class="sidebar-nav">
			<a href="/files" class="sidebar-link active">
				<i class="bi bi-folder2-open"></i>
				<span>My files</span>
			</a>
			<button class="sidebar-link" on:click={() => showNewFileModal = true}>
				<i class="bi bi-file-earmark-plus"></i>
				<span>New file</span>
			</button>
			<button class="sidebar-link" on:click={triggerUpload}>
				<i class="bi bi-cloud-arrow-up"></i>
				<span>Upload file</span>
			</button>
		</nav>

	</aside>

	<!-- Main Content -->
	<div class="fb-main">
		<!-- Top Bar -->
		<header class="fb-topbar">
			<div class="search-box">
				<i class="bi bi-search"></i>
				<input type="text" placeholder="Search or execute a command..." bind:value={searchQuery}>
			</div>

			<div class="topbar-actions">
				<button class="topbar-btn {viewMode === 'list' ? 'active' : ''}" on:click={() => viewMode = 'list'} title="List view">
					<i class="bi bi-list-ul"></i>
				</button>
				<button class="topbar-btn {viewMode === 'grid' ? 'active' : ''}" on:click={() => viewMode = 'grid'} title="Grid view">
					<i class="bi bi-grid-3x3-gap"></i>
				</button>
				<button class="topbar-btn" on:click={triggerUpload} title="Upload">
					<i class="bi bi-cloud-arrow-up"></i>
				</button>
				<button class="topbar-btn" on:click={fetchFiles} title="Refresh">
					<i class="bi bi-arrow-clockwise"></i>
				</button>
			</div>
		</header>

		<!-- Breadcrumb -->
		<div class="fb-breadcrumb">
			<i class="bi bi-house-door"></i>
			<span class="bc-sep">/</span>
			<span class="bc-current">My files</span>
		</div>

		<!-- Execution Output -->
		{#if uploadResult}
			<div class="fb-content-section" transition:slide={{ duration: 300 }}>
				<div class="alert alert-success d-flex align-items-center rounded-3 mx-3 mt-2 mb-0">
					<i class="bi bi-check-circle-fill me-2"></i>
					{uploadResult}
					<button class="btn-close ms-auto" on:click={() => { uploadResult = null; execLog = ''; }}></button>
				</div>

				{#if execLog}
					<div class="terminal-container mx-3 mt-3" transition:slide={{ duration: 300 }}>
						<div class="terminal-header d-flex justify-content-between align-items-center px-3 py-2">
							<div class="fw-bold text-light small"><i class="bi bi-terminal me-2"></i>Script Execution Output</div>
							<div class="d-flex gap-2">
								<div class="circle bg-danger rounded-circle"></div>
								<div class="circle bg-warning rounded-circle"></div>
								<div class="circle bg-success rounded-circle"></div>
							</div>
						</div>
						<div class="terminal-body p-3 font-monospace overflow-auto" style="max-height: 250px; white-space: pre-wrap;">
							{execLog}
						</div>
					</div>
				{/if}
			</div>
		{/if}

		<!-- File Content Area -->
		<div class="fb-content">
			{#if loading}
				<div class="text-center py-5">
					<div class="spinner-border text-secondary" role="status">
						<span class="visually-hidden">Loading...</span>
					</div>
				</div>
			{:else if errorMsg}
				<div class="alert alert-danger m-3 rounded-3">
					<i class="bi bi-exclamation-triangle me-2"></i>{errorMsg}
				</div>
			{:else if filteredFiles.length === 0}
				<div class="empty-state" in:fade>
					<i class="bi bi-folder fs-1 text-secondary"></i>
					<p class="text-muted mt-3 mb-0">
						{searchQuery ? 'ไม่พบไฟล์ที่ตรงกับการค้นหา' : 'ยังไม่มีไฟล์ — เริ่มอัปโหลดไฟล์แรกของคุณเลย!'}
					</p>
				</div>
			{:else}
				<div class="section-label">Files</div>

				{#if viewMode === 'grid'}
					<div class="file-grid">
						{#each filteredFiles as file, i}
							<div class="file-card" in:fly={{ y: 10, delay: i * 30, duration: 250 }}>
								<div class="file-card-icon">
									{getFileIcon(file.name)}
								</div>
								<div class="file-card-info">
									<div class="file-card-name" title={file.name}>{file.name}</div>
									<div class="file-card-meta">
										{formatSize(file.size)}
									</div>
									<div class="file-card-meta">
										{formatDate(file.modified)}
									</div>
								</div>
								{#if file.name.endsWith('.sh')}
									<span class="exec-badge">auto-exec</span>
								{/if}
								<div class="file-card-actions">
									{#if deleteConfirm === file.name}
										<button class="btn btn-danger btn-sm" on:click={() => deleteFile(file.name)}>Delete</button>
										<button class="btn btn-outline-secondary btn-sm" on:click={() => deleteConfirm = null}>Cancel</button>
									{:else}
										<button class="btn-icon-delete" on:click={() => deleteConfirm = file.name} title="Delete">
											<i class="bi bi-trash3"></i>
										</button>
									{/if}
								</div>
							</div>
						{/each}
					</div>
				{:else}
					<div class="file-list-view">
						<div class="file-list-header">
							<span class="flh-name">Name</span>
							<span class="flh-size">Size</span>
							<span class="flh-date">Modified</span>
							<span class="flh-actions"></span>
						</div>
						{#each filteredFiles as file, i}
							<div class="file-list-row" in:fly={{ x: -10, delay: i * 20, duration: 200 }}>
								<span class="flr-name">
									<span class="flr-icon">{getFileIcon(file.name)}</span>
									{file.name}
									{#if file.name.endsWith('.sh')}
										<span class="exec-badge-sm">auto-exec</span>
									{/if}
								</span>
								<span class="flr-size">{formatSize(file.size)}</span>
								<span class="flr-date">{formatDate(file.modified)}</span>
								<span class="flr-actions">
									{#if deleteConfirm === file.name}
										<button class="btn btn-danger btn-sm" on:click={() => deleteFile(file.name)}>✓</button>
										<button class="btn btn-outline-secondary btn-sm" on:click={() => deleteConfirm = null}>✕</button>
									{:else}
										<button class="btn-icon-delete" on:click={() => deleteConfirm = file.name}><i class="bi bi-trash3"></i></button>
									{/if}
								</span>
							</div>
						{/each}
					</div>
				{/if}
			{/if}
		</div>
	</div>
</div>

<!-- New File Modal -->
{#if showNewFileModal}
	<div class="modal-overlay" on:click|self={() => showNewFileModal = false} transition:fade={{ duration: 200 }}>
		<div class="modal-box" transition:fly={{ y: 30, duration: 300 }}>
			<h5 class="fw-bold mb-4"><i class="bi bi-file-earmark-plus me-2"></i>Create New File</h5>
			<div class="mb-3">
				<label class="form-label fw-medium" for="newFileName">File name</label>
				<input class="form-control" id="newFileName" type="text" bind:value={newFileName} placeholder="e.g. script.sh, notes.txt">
			</div>
			<div class="mb-3">
				<label class="form-label fw-medium" for="newFileContent">Content (optional)</label>
				<textarea class="form-control font-monospace" id="newFileContent" bind:value={newFileContent} rows="6" placeholder="#!/bin/bash&#10;echo 'Hello World'"></textarea>
			</div>
			<div class="d-flex gap-2 justify-content-end">
				<button class="btn btn-outline-secondary" on:click={() => showNewFileModal = false}>Cancel</button>
				<button class="btn btn-dark" on:click={createNewFile} disabled={!newFileName.trim() || isCreatingFile}>
					{#if isCreatingFile}
						<span class="spinner-border spinner-border-sm me-1"></span>
					{/if}
					Create
				</button>
			</div>
		</div>
	</div>
{/if}

<style>
	/* ========== LAYOUT ========== */
	.fb-container {
		display: flex;
		height: calc(100vh - 76px - 62px); /* navbar + footer */
		background: #f5f5f5;
		overflow: hidden;
	}

	/* ========== SIDEBAR ========== */
	.fb-sidebar {
		width: 220px;
		min-width: 220px;
		background: #fff;
		border-right: 1px solid #e8e8e8;
		display: flex;
		flex-direction: column;
		padding: 0;
	}

	.sidebar-logo {
		display: flex;
		align-items: center;
		gap: 10px;
		padding: 20px 18px;
		border-bottom: 1px solid #eee;
	}

	.logo-icon {
		font-size: 1.5rem;
	}

	.logo-text {
		font-weight: 600;
		font-size: 1rem;
		color: #333;
	}

	.sidebar-nav {
		padding: 12px 8px;
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 2px;
	}

	.sidebar-link {
		display: flex;
		align-items: center;
		gap: 12px;
		padding: 10px 14px;
		border-radius: 8px;
		color: #555;
		text-decoration: none;
		font-size: 0.9rem;
		font-weight: 500;
		background: none;
		border: none;
		width: 100%;
		text-align: left;
		cursor: pointer;
		transition: all 0.15s ease;
	}

	.sidebar-link:hover {
		background: #f0f0f0;
		color: #222;
	}

	.sidebar-link.active {
		background: #e8f0fe;
		color: #1a73e8;
	}

	.sidebar-link i {
		font-size: 1.1rem;
	}

	.sidebar-footer {
		padding: 14px 18px;
		border-top: 1px solid #eee;
	}

	.sidebar-version {
		font-size: 0.75rem;
		color: #aaa;
	}

	/* ========== MAIN ========== */
	.fb-main {
		flex: 1;
		display: flex;
		flex-direction: column;
		overflow: hidden;
	}

	/* ========== TOP BAR ========== */
	.fb-topbar {
		display: flex;
		align-items: center;
		gap: 16px;
		padding: 12px 20px;
		background: #fff;
		border-bottom: 1px solid #e8e8e8;
	}

	.search-box {
		flex: 1;
		display: flex;
		align-items: center;
		gap: 10px;
		background: #f5f5f5;
		border-radius: 24px;
		padding: 8px 16px;
		max-width: 500px;
	}

	.search-box i {
		color: #999;
		font-size: 0.9rem;
	}

	.search-box input {
		border: none;
		background: none;
		outline: none;
		font-size: 0.9rem;
		width: 100%;
		color: #333;
	}

	.topbar-actions {
		display: flex;
		gap: 4px;
	}

	.topbar-btn {
		width: 36px;
		height: 36px;
		border-radius: 50%;
		border: none;
		background: none;
		color: #666;
		display: flex;
		align-items: center;
		justify-content: center;
		cursor: pointer;
		transition: all 0.15s ease;
		font-size: 1rem;
	}

	.topbar-btn:hover {
		background: #f0f0f0;
		color: #222;
	}

	.topbar-btn.active {
		background: #e8f0fe;
		color: #1a73e8;
	}

	/* ========== BREADCRUMB ========== */
	.fb-breadcrumb {
		padding: 10px 20px;
		font-size: 0.85rem;
		color: #777;
		display: flex;
		align-items: center;
		gap: 6px;
	}

	.bc-sep {
		color: #ccc;
	}

	.bc-current {
		color: #333;
		font-weight: 500;
	}

	/* ========== CONTENT ========== */
	.fb-content {
		flex: 1;
		overflow-y: auto;
		padding: 0 20px 20px;
	}

	.section-label {
		font-size: 0.8rem;
		font-weight: 600;
		color: #888;
		text-transform: uppercase;
		letter-spacing: 0.5px;
		padding: 12px 0 8px;
	}

	/* ========== GRID VIEW ========== */
	.file-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
		gap: 12px;
	}

	.file-card {
		background: #fff;
		border: 1px solid #e8e8e8;
		border-radius: 10px;
		padding: 16px;
		position: relative;
		transition: all 0.2s ease;
		cursor: default;
	}

	.file-card:hover {
		border-color: #ccc;
		box-shadow: 0 2px 8px rgba(0,0,0,0.06);
	}

	.file-card-icon {
		font-size: 2.2rem;
		margin-bottom: 10px;
	}

	.file-card-name {
		font-weight: 600;
		font-size: 0.88rem;
		color: #333;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
		margin-bottom: 4px;
	}

	.file-card-meta {
		font-size: 0.75rem;
		color: #999;
	}

	.exec-badge {
		position: absolute;
		top: 10px;
		right: 10px;
		background: #fff3cd;
		color: #856404;
		font-size: 0.65rem;
		font-weight: 600;
		padding: 2px 8px;
		border-radius: 10px;
		border: 1px solid #ffc107;
	}

	.exec-badge-sm {
		background: #fff3cd;
		color: #856404;
		font-size: 0.65rem;
		font-weight: 600;
		padding: 1px 6px;
		border-radius: 8px;
		margin-left: 6px;
	}

	.file-card-actions {
		margin-top: 10px;
		display: flex;
		gap: 6px;
	}

	.btn-icon-delete {
		width: 30px;
		height: 30px;
		border-radius: 6px;
		border: 1px solid #eee;
		background: #fff;
		color: #999;
		display: flex;
		align-items: center;
		justify-content: center;
		cursor: pointer;
		transition: all 0.15s ease;
		font-size: 0.85rem;
	}

	.btn-icon-delete:hover {
		background: #fee2e2;
		color: #dc3545;
		border-color: #dc3545;
	}

	/* ========== LIST VIEW ========== */
	.file-list-view {
		background: #fff;
		border-radius: 10px;
		border: 1px solid #e8e8e8;
		overflow: hidden;
	}

	.file-list-header {
		display: grid;
		grid-template-columns: 1fr 100px 140px 60px;
		padding: 10px 16px;
		font-size: 0.75rem;
		font-weight: 600;
		color: #999;
		text-transform: uppercase;
		letter-spacing: 0.5px;
		border-bottom: 1px solid #eee;
		background: #fafafa;
	}

	.file-list-row {
		display: grid;
		grid-template-columns: 1fr 100px 140px 60px;
		padding: 12px 16px;
		align-items: center;
		border-bottom: 1px solid #f5f5f5;
		transition: background 0.15s ease;
	}

	.file-list-row:last-child {
		border-bottom: none;
	}

	.file-list-row:hover {
		background: #f9f9f9;
	}

	.flr-name {
		font-weight: 500;
		font-size: 0.88rem;
		display: flex;
		align-items: center;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	.flr-icon {
		margin-right: 10px;
		font-size: 1.2rem;
	}

	.flr-size, .flr-date {
		font-size: 0.8rem;
		color: #888;
	}

	.flr-actions {
		text-align: right;
		display: flex;
		gap: 4px;
		justify-content: flex-end;
	}

	/* ========== EMPTY STATE ========== */
	.empty-state {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		padding: 80px 20px;
	}

	/* ========== TERMINAL ========== */
	.terminal-container {
		border-radius: 8px;
		overflow: hidden;
		border: 1px solid #333;
		box-shadow: 0 4px 12px rgba(0,0,0,0.15);
	}

	.terminal-header {
		background-color: #2b2b2b;
		border-bottom: 1px solid #1a1a1a;
	}

	.terminal-body {
		background: #1a1a2e;
		color: #00ff41;
		font-size: 0.82rem;
	}

	.circle {
		width: 10px;
		height: 10px;
	}

	/* ========== MODAL ========== */
	.modal-overlay {
		position: fixed;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		background: rgba(0,0,0,0.4);
		backdrop-filter: blur(4px);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 2000;
	}

	.modal-box {
		background: #fff;
		border-radius: 14px;
		padding: 28px;
		width: 90%;
		max-width: 480px;
		box-shadow: 0 20px 60px rgba(0,0,0,0.2);
	}

	/* ========== RESPONSIVE ========== */
	@media (max-width: 768px) {
		.fb-sidebar {
			display: none;
		}

		.file-grid {
			grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
		}

		.file-list-header, .file-list-row {
			grid-template-columns: 1fr 80px 60px;
		}

		.flr-date, .flh-date {
			display: none;
		}
	}
</style>
