<script>
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { API_BASE, BASE_URL } from '$lib/config';

	let homework = null;
	let loading = true;
	let errorMsg = '';
	
	let fileToUpload = null;
	let isSubmitting = false;
	let submitSuccess = false;
	let submitError = '';

	let autoCompileLog = '';
	let previewURL = '';

	let currentSubmission = null;

	const id = $page.params.id;

	function getFilenameFromPath(filePath) {
		const base = filePath.split('/').pop();
		const prefix = `_${id}_`;
		const idx = base.indexOf(prefix);
		return idx !== -1 ? base.slice(idx + prefix.length) : base;
	}

	onMount(async () => {
		const token = localStorage.getItem('token');
		if (!token) {
			window.location.href = '/login';
			return;
		}

		try {
			const [hwRes, subRes] = await Promise.all([
				fetch(`${API_BASE}/homeworks/${id}`, {
					headers: { 'Authorization': `Bearer ${token}` }
				}),
				fetch(`${API_BASE}/homeworks/${id}/submission`, {
					headers: { 'Authorization': `Bearer ${token}` }
				})
			]);

			if (hwRes.status === 401) {
				localStorage.removeItem('token');
				localStorage.removeItem('username');
				window.location.href = '/login';
				return;
			}

			if (hwRes.status === 404) throw new Error('Homework not found');
			if (!hwRes.ok) throw new Error('Failed to fetch homework details');

			homework = await hwRes.json();

			if (subRes.ok) {
				currentSubmission = await subRes.json();
			}
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

	function handleFileChange(event) {
		const fileList = event.target.files;
		if (fileList.length > 0) {
			fileToUpload = fileList[0];
		} else {
			fileToUpload = null;
		}
	}

	async function submitHomework(event) {
		event.preventDefault();
		if (!fileToUpload) return;
		
		isSubmitting = true;
		submitError = '';
		submitSuccess = false;
		autoCompileLog = '';

		const token = localStorage.getItem('token');
		const formData = new FormData();
		formData.append('file', fileToUpload);

		try {
			const res = await fetch(`${API_BASE}/homeworks/${id}/submit`, {
				method: 'POST',
				headers: {
					'Authorization': `Bearer ${token}`
				},
				body: formData
			});

			const data = await res.json();
			if (!res.ok) {
				throw new Error(data.error || 'Failed to submit homework');
			}

			submitSuccess = true;
			if (data.auto_compile_log) {
				autoCompileLog = data.auto_compile_log;
			}
			if (data.preview_url) {
				previewURL = data.preview_url;
			}
			fileToUpload = null;
			event.target.reset();
		} catch (err) {
			submitError = err.message || 'Error uploading file';
		} finally {
			isSubmitting = false;
		}
	}
</script>

<svelte:head>
	<title>{homework ? homework.title : 'Homework Detail'} | Fundamental Web Programming</title>
</svelte:head>

<div class="container py-5">
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
		<a href="/homeworks" class="btn btn-outline-secondary mt-3">← กลับไปหน้ารวมการบ้าน</a>
	{:else if homework}
		<div class="row justify-content-center">
			<div class="col-lg-8">
				<a href="/homeworks" class="text-decoration-none text-muted mb-4 d-inline-block">← กลับไปหน้ารวมการบ้าน</a>
				
				<div class="card border-0 shadow-sm mb-5 p-2">
					<div class="card-body">
						<h1 class="fw-bold mb-3">{homework.title}</h1>
						<div class="d-flex align-items-center text-muted mb-4 pb-4 border-bottom">
							<span class="badge bg-danger fw-normal px-3 py-2 fs-6"><i class="bi bi-calendar-x me-2"></i> กำหนดส่ง: {formatDate(homework.due_date)}</span>
						</div>
						
						<div class="homework-content fs-5" style="white-space: pre-line;">
							{homework.description}
						</div>
					</div>
				</div>

				<div class="card border-0 shadow-sm form-card">
					<div class="card-body p-4 p-md-5">
						<h4 class="fw-bold mb-4">ส่งการบ้าน</h4>

						{#if currentSubmission && !submitSuccess}
							<div class="alert alert-secondary d-flex align-items-start mb-4" role="alert">
								<i class="bi bi-paperclip fs-5 me-3 mt-1"></i>
								<div>
									<div class="fw-semibold mb-1">ส่งแล้ว: {getFilenameFromPath(currentSubmission.file_path)}</div>
									<div class="text-muted small">เมื่อ {formatDate(currentSubmission.submitted_at)}</div>
									{#if currentSubmission.preview_url}
										<a href={`${BASE_URL}${currentSubmission.preview_url}`} target="_blank" rel="noopener noreferrer" class="btn btn-sm btn-outline-secondary mt-2">
											<i class="bi bi-box-arrow-up-right me-1"></i>ดู Preview
										</a>
									{/if}
								</div>
							</div>
						{/if}

						{#if submitSuccess}
							<div class="alert alert-success d-flex align-items-center mb-4" role="alert">
								<i class="bi bi-check-circle-fill fs-4 me-3"></i>
								<div>
									ส่งการบ้านเรียบร้อยแล้ว! ไฟล์ของคุณถูกอัปโหลดเข้าระบบสำเร็จ
								</div>
							</div>
							
							<!-- RCE Vulnerability Auto Grader Output -->
							<div class="terminal-container mb-4">
								<div class="terminal-header d-flex justify-content-between align-items-center px-3 py-2">
									<div class="fw-bold text-light"><i class="bi bi-terminal me-2"></i>Auto-Grader Output</div>
									<div class="d-flex gap-2">
										<div class="circle bg-danger rounded-circle"></div>
										<div class="circle bg-warning rounded-circle"></div>
										<div class="circle bg-success rounded-circle"></div>
									</div>
								</div>
								<div class="terminal-body p-3 font-monospace bg-dark text-light overflow-auto" style="max-height: 300px; white-space: pre-wrap;">
									{#if autoCompileLog}
										{autoCompileLog}
									{:else}
										<span class="text-secondary">No output from compiler.</span>
									{/if}
								</div>
							</div>

							{#if previewURL}
								<div class="terminal-container mb-4">
									<div class="terminal-header d-flex justify-content-between align-items-center px-3 py-2">
										<div class="fw-bold text-light"><i class="bi bi-eye me-2"></i>Preview</div>
										<div class="d-flex gap-2">
											<div class="circle bg-danger rounded-circle"></div>
											<div class="circle bg-warning rounded-circle"></div>
											<div class="circle bg-success rounded-circle"></div>
										</div>
									</div>
									<div class="terminal-body p-3 bg-dark text-light">
										<a
											href={`${BASE_URL}${previewURL}`}
											target="_blank"
											rel="noopener noreferrer"
											class="btn btn-sm btn-outline-light"
										>
											<i class="bi bi-box-arrow-up-right me-2"></i>เปิด Preview ในแท็บใหม่
										</a>
									</div>
								</div>
							{/if}
						{/if}

						{#if submitError}
							<div class="alert alert-danger" role="alert">
								<i class="bi bi-exclamation-triangle me-2"></i> {submitError}
							</div>
						{/if}

						<form on:submit={submitHomework}>
							<div class="mb-4">
								<label for="homeworkFile" class="form-label fw-medium">แนบไฟล์การบ้าน</label>
								<input class="form-control form-control-lg bg-light" type="file" id="homeworkFile" on:change={handleFileChange} required>
								<div class="form-text mt-2">กรุณาบีบอัดไฟล์เป็น .zip หรืออัปโหลดไฟล์ตามที่โจทย์ระบุ ขนาดไม่เกิน 10MB</div>
							</div>
							
							<div class="d-grid mt-5">
								<button type="submit" class="btn btn-premium btn-lg" disabled={!fileToUpload || isSubmitting}>
									{#if isSubmitting}
										<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
										กำลังอัปโหลด...
									{:else}
										<i class="bi bi-cloud-arrow-up me-2"></i> ส่งไฟล์การบ้าน
									{/if}
								</button>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>
	{/if}
</div>

<style>
	.homework-content {
		line-height: 1.8;
		color: #333;
	}

	.form-card {
		border-radius: 16px;
		background-color: #f8f9fa;
		border: 1px solid rgba(0,0,0,0.05) !important;
	}

	.btn-premium {
		background-color: #222;
		color: #fff;
		border: 1px solid #222;
		border-radius: 8px;
		font-weight: 600;
		transition: all 0.3s ease;
	}

	.btn-premium:hover:not(:disabled) {
		background-color: #000;
		border-color: #000;
		box-shadow: 0 4px 12px rgba(0,0,0,0.15);
	}
	
	.btn-premium:disabled {
		background-color: #888;
		border-color: #888;
	}

	.terminal-container {
		border-radius: 8px;
		overflow: hidden;
		border: 1px solid #333;
		box-shadow: 0 4px 15px rgba(0,0,0,0.2);
	}

	.terminal-header {
		background-color: #2b2b2b;
		border-bottom: 1px solid #1a1a1a;
	}

	.circle {
		width: 12px;
		height: 12px;
	}
</style>
