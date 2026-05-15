<script>
</script>

<svelte:head>
	<title>Admin Dashboard | Fundamental Web Programming</title>
</svelte:head>

<div class="container py-5">
	<div class="row mb-5">
		<div class="col-12 border-bottom pb-4">
			<h2 class="fw-bold text-danger tracking-tight">
				<i class="bi bi-shield-lock-fill me-2"></i>Secret Admin Dashboard
			</h2>
			<p class="text-muted mb-0">Welcome to the restricted area. Only those with role="admin" should be here.</p>
		</div>
	</div>

	<div class="row g-4 mt-2">
		<div class="col-md-6">
			<div class="card border-0 shadow-sm h-100 rounded-4">
				<div class="card-body p-4 text-center">
					<div class="bg-light rounded-circle d-inline-flex justify-content-center align-items-center mb-3" style="width: 60px; height: 60px;">
						<i class="bi bi-journal-text fs-4 text-primary"></i>
					</div>
					<h4 class="fw-bold mb-3">บทเรียน (Lessons)</h4>
					<p class="text-muted mb-4">จัดการเนื้อหาบทเรียน เพิ่ม แก้ไข หรือลบบทเรียนในระบบ</p>
					<a href="/admin/lessons" class="btn btn-outline-primary btn-lg rounded-pill px-4">
						<i class="bi bi-plus-circle me-2"></i> สร้างบทเรียนใหม่
					</a>
				</div>
			</div>
		</div>
		<div class="col-md-6">
			<div class="card border-0 shadow-sm h-100 rounded-4">
				<div class="card-body p-4 text-center">
					<div class="bg-light rounded-circle d-inline-flex justify-content-center align-items-center mb-3" style="width: 60px; height: 60px;">
						<i class="bi bi-file-earmark-check fs-4 text-success"></i>
					</div>
					<h4 class="fw-bold mb-3">การบ้าน (Homeworks)</h4>
					<p class="text-muted mb-4">มอบหมายการบ้านใหม่ ตั้งค่ากำหนดส่ง และรายละเอียดต่างๆ</p>
					<a href="/admin/homeworks" class="btn btn-outline-success btn-lg rounded-pill px-4">
						<i class="bi bi-plus-circle me-2"></i> สร้างการบ้านใหม่
					</a>
				</div>
			</div>
		</div>
	</div>
</div>
