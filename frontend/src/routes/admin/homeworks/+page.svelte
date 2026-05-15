<script>
	import { API_BASE } from '$lib/config';
	let title = '';
	let description = '';
	let dueDate = '';
	
	let loading = false;
	let errorMsg = '';
	let successMsg = '';

	async function handleSubmit(event) {
		event.preventDefault();
		loading = true;
		errorMsg = '';
		successMsg = '';

		const token = localStorage.getItem('token');
		if (!token) {
			window.location.href = '/login';
			return;
		}

		let processedDate = null;
		if (dueDate) {
			const d = new Date(dueDate);
			processedDate = d.toISOString();
		}

		try {
			const res = await fetch(`${API_BASE}/homeworks`, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
					'Authorization': `Bearer ${token}`
				},
				body: JSON.stringify({
					title,
					description,
					due_date: processedDate || undefined
				})
			});
			
			if (res.status === 401) {
				localStorage.removeItem('token');
				localStorage.removeItem('username');
				window.location.href = '/login';
				return;
			}
			
			if (!res.ok) throw new Error('Failed to create homework');
			
			successMsg = 'สร้างการบ้านสำเร็จ!';
			title = '';
			description = '';
			dueDate = '';
		} catch (err) {
			errorMsg = err.message || 'Server connection error';
		} finally {
			loading = false;
		}
	}
</script>

<svelte:head>
	<title>Create Homework | Admin Dashboard</title>
</svelte:head>

<div class="container py-5">
	<div class="row justify-content-center">
		<div class="col-lg-8">
			<a href="/admin" class="text-decoration-none text-muted mb-4 d-inline-block">← กลับไปหน้าแอดมิน</a>
			
			<div class="card border-0 shadow-sm rounded-4 form-card">
				<div class="card-body p-4 p-md-5">
					<h2 class="fw-bold mb-4">
						<i class="bi bi-file-earmark-plus-fill me-2 text-success"></i>สร้างการบ้านใหม่
					</h2>
					<p class="text-muted mb-5">เพิ่มโจทย์การบ้านใหม่ให้นักศึกษา</p>
					
					{#if successMsg}
						<div class="alert alert-success d-flex align-items-center" role="alert">
							<i class="bi bi-check-circle-fill fs-4 me-3"></i>
							<div>{successMsg}</div>
						</div>
					{/if}

					{#if errorMsg}
						<div class="alert alert-danger" role="alert">
							<i class="bi bi-exclamation-triangle me-2"></i> {errorMsg}
						</div>
					{/if}

					<form on:submit={handleSubmit}>
						<div class="mb-4">
							<label for="title" class="form-label fw-medium">หัวข้อการบ้าน <span class="text-danger">*</span></label>
							<input type="text" class="form-control form-control-lg bg-light" id="title" bind:value={title} placeholder="เช่น การบ้าน 3: สร้าง API พื้นฐาน" required>
						</div>

						<div class="mb-4">
							<label for="description" class="form-label fw-medium">รายละเอียด <span class="text-danger">*</span></label>
							<textarea class="form-control form-control-lg bg-light" id="description" bind:value={description} rows="6" placeholder="คำอธิบายและโจทย์ของการบ้าน รองรับข้อความธรรมดา..." required></textarea>
						</div>

						<div class="mb-4">
							<label for="dueDate" class="form-label fw-medium">กำหนดส่ง <span class="text-muted fs-6 fw-normal">(ถ้ามี)</span></label>
							<input type="datetime-local" class="form-control form-control-lg bg-light" id="dueDate" bind:value={dueDate}>
						</div>
						
						<div class="d-grid mt-5">
							<button type="submit" class="btn btn-success btn-lg fw-bold" disabled={loading}>
								{#if loading}
									<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
									กำลังบันทึก...
								{:else}
									<i class="bi bi-send-plus me-2"></i> บันทึกการบ้าน
								{/if}
							</button>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>

<style>
	.form-card {
		background-color: #fff;
		border: 1px solid rgba(0,0,0,0.05) !important;
	}

	.btn-success {
		background-color: #198754;
		border-color: #198754;
		box-shadow: 0 4px 6px rgba(25,135,84,0.2);
		transition: all 0.3s ease;
	}

	.btn-success:hover:not(:disabled) {
		background-color: #146c43;
		border-color: #13653f;
		box-shadow: 0 6px 12px rgba(25,135,84,0.3);
		transform: translateY(-2px);
	}
</style>
