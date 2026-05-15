<script lang="js">

    import { onMount } from 'svelte';
	import { API_BASE } from '$lib/config';

	let token = '';
    let sqlText = '';
    let loading = false;
    let error = '';
    /** @type {any} */
    let result = null;

    /** @type {HTMLInputElement | null} */
    let sqlFileInput = null;
    let sqlFileName = '';
    let fileReadError = '';

    onMount(async () => {
        token = localStorage.getItem('token') || '';
		if (!token) {
			window.location.href = "/login";
			return;
		}
	});

    /**
     * @param {string} path
     * @param {{ method?: string; body?: any; headers?: Record<string, string> }} [options]
     */
    async function apiFetch(path, options = {}) {
        const { method = 'GET', body, headers = {} } = options;
        /** @type {Record<string, string>} */
        const finalHeaders = {
            Accept: 'application/json',
            ...headers
        };
		if (token) finalHeaders.Authorization = `Bearer ${token}`;
		if (body !== undefined && !(body instanceof FormData)) {
			finalHeaders['Content-Type'] = 'application/json';
		}

		const res = await fetch(`${API_BASE}${path}`, {
			method,
			headers: finalHeaders,
			body: body === undefined ? undefined : body instanceof FormData ? body : JSON.stringify(body)
		});

		let data = null;
		const contentType = res.headers.get('content-type') || '';
		if (contentType.includes('application/json')) {
			data = await res.json().catch(() => null);
		} else {
			data = await res.text().catch(() => '');
		}

		if (!res.ok) {
			const msg = (data && typeof data === 'object' && (data.error || data.message)) ? (data.error || data.message) : `Request failed (${res.status})`;
			throw new Error(msg);
		}
		return data;
	}

    async function executeSql() {
        loading = true;
        error = '';
        result = null;
		try {
			if (!sqlText.trim()) throw new Error('กรุณาใส่ SQL ก่อน');
            result = await apiFetch('/db/execute', {
				method: 'POST',
				body: { sql: sqlText }
			});
		} catch (err) {
            error = err instanceof Error ? err.message : String(err || 'Execute failed');
		} finally {
            loading = false;
		}
	}

    /** @param {Event} event */
    async function onPickSqlFile(event) {
        fileReadError = '';
        error = '';
        result = null;
        const input = /** @type {HTMLInputElement | null} */ (event.currentTarget);
        const file = input?.files?.[0];
        sqlFileName = file?.name || '';
        if (!file) return;

        try {
            const text = await file.text();
            sqlText = text;
        } catch (err) {
            fileReadError = err instanceof Error ? err.message : String(err || 'อ่านไฟล์สคริปต์ไม่สำเร็จ');
        }
    }

    function resetForm() {
        sqlText = '';
        sqlFileName = '';
        fileReadError = '';
        error = '';
        result = null;
        if (sqlFileInput) sqlFileInput.value = '';
    }
</script>

<svelte:head>
	<title>Database Tools | Fundamental Web Programming</title>
</svelte:head>

<div class="container py-5">
    <div class="row mb-4">
        <div class="col-12">
            <h2 class="fw-bold mb-1"><i class="bi bi-database me-2"></i>Database Tools</h2>
			<p class="text-muted mb-0">สั่งรันคำสั่ง SQL และอัปโหลด SQL script เพื่อสร้าง/อัปเดตตาราง</p>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-12">
            <div class="card border-0 shadow-sm rounded-4">
                <div class="card-body p-4">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <h5 class="fw-bold mb-0"><i class="bi bi-terminal me-2"></i>Execute SQL / SQL Script</h5>
                        <span class="badge text-bg-light border">POST /api/db/execute</span>
                    </div>

                    <div class="mb-3">
                        <label class="form-label small fw-medium text-secondary" for="sqlScriptFile">SQL script file</label>
                        <input
                            id="sqlScriptFile"
                            class="form-control bg-light border-0"
                            type="file"
                            accept=".sql,.txt,text/plain,application/sql"
                            bind:this={sqlFileInput}
                            on:change={onPickSqlFile}
                        />
                        {#if sqlFileName}
                            <div class="form-text">ไฟล์ที่เลือก: <span class="fw-semibold">{sqlFileName}</span> (นำไปใส่ในช่อง SQL ให้อัตโนมัติ)</div>
                        {/if}
                    </div>

                    {#if fileReadError}
                        <div class="alert alert-danger py-2 px-3 small mb-3"><i class="bi bi-exclamation-triangle me-2"></i>{fileReadError}</div>
                    {/if}

                    <div class="mb-2">
                        <label class="form-label small fw-medium text-secondary" for="sqlTextArea">SQL</label>
                        <textarea id="sqlTextArea" class="form-control bg-light border-0" rows="12" bind:value={sqlText} placeholder="วาง/พิมพ์ SQL ที่นี่ หรือเลือกไฟล์ .sql ด้านบน"></textarea>
                    </div>

                    {#if error}
                        <div class="alert alert-danger py-2 px-3 small mt-3"><i class="bi bi-exclamation-triangle me-2"></i>{error}</div>
                    {/if}
                    {#if result}
                        <div class="alert alert-success py-2 px-3 small mt-3"><i class="bi bi-check-circle me-2"></i>Execute สำเร็จ</div>
                        <pre class="bg-light border rounded-3 p-3 small mb-0" style="max-height: 220px; overflow:auto;">{JSON.stringify(result, null, 2)}</pre>
                    {/if}

                    <div class="d-flex gap-2 mt-3">
                        <button class="btn btn-premium" on:click={executeSql} disabled={loading}>
                            {#if loading}
                                <span class="spinner-border spinner-border-sm me-2" aria-hidden="true"></span>Executing...
                            {:else}
                                <i class="bi bi-play-fill me-1"></i>Execute
                            {/if}
                        </button>
                        <button class="btn btn-outline-premium" on:click={resetForm} disabled={loading}>
                            Clear
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<style>
	textarea.form-control:focus,
	input.form-control:focus,
	select.form-select:focus {
		box-shadow: 0 0 0 0.25rem rgba(0, 0, 0, 0.05);
		background-color: #fff !important;
		border: 1px solid #ddd !important;
	}
</style>