
    const projectId = '{{ project_id }}';
    let project = null;

    async function loadProjectData() {
        if (!isAuthenticated()) { window.location.href = '/'; return; }
        try {
            const response = await apiRequest(`/projects/${projectId}/`);
            if (!response.ok) throw new Error('Failed');
            project = await response.json();
            renderProjectInfo();
            renderWorksAndActivities();
            calculateOverallProgress();
            renderGanttChart();
        } catch (error) { showToast('Gagal memuat data', 'error'); }
    }

    function renderGanttChart() {
        if (!project.works || project.works.length === 0) {
            document.getElementById('gantt-card').classList.add('hidden');
            return;
        }

        // Extract labels and date ranges
        const labels = [];
        const ranges = [];
        let minTime = Infinity;
        let maxTime = -Infinity;

        project.works.forEach(w => {
            if (w.start_date && w.end_date) {
                labels.push(w.name);
                const start = new Date(w.start_date).getTime();
                const end = new Date(w.end_date).getTime();
                ranges.push([start, Math.max(start + 86400000, end)]);
                
                if (start < minTime) minTime = start;
                if (end > maxTime) maxTime = end;
            }
        });

        if (labels.length === 0) {
            document.getElementById('gantt-card').classList.add('hidden');
            return;
        }

        document.getElementById('gantt-card').classList.remove('hidden');

        // Add padding (1 day)
        minTime -= 86400000;
        maxTime += 86400000;

        const ctx = document.getElementById('ganttChart').getContext('2d');
        if (window.ganttChartInstance) {
            window.ganttChartInstance.destroy();
        }

        const gradGantt = ctx.createLinearGradient(0, 0, ctx.canvas.width || 400, 0);
        gradGantt.addColorStop(0, '#b91c1c'); // red-700
        gradGantt.addColorStop(1, '#ef4444'); // red-500

        window.ganttChartInstance = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    data: ranges,
                    backgroundColor: gradGantt,
                    borderRadius: 8,
                    borderSkipped: false,
                    barPercentage: 0.5
                }]
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                onHover: (event, activeElements) => {
                    event.native.target.style.cursor = activeElements.length > 0 ? 'pointer' : 'default';
                },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            title: (items) => items[0].label,
                            label: function(context) {
                                const range = context.raw;
                                const start = new Date(range[0]).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
                                const end = new Date(range[1]).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
                                return ` Jadwal: ${start} s/d ${end}`;
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        type: 'linear',
                        min: minTime,
                        max: maxTime,
                        ticks: {
                            callback: function(value) {
                                return new Date(value).toLocaleDateString('id-ID', { month: 'short', day: 'numeric' });
                            },
                            font: { family: 'Inter', size: 10, weight: 'bold' },
                            color: '#9ca3af'
                        },
                        grid: {
                            color: '#f3f4f6'
                        }
                    },
                    y: {
                        ticks: {
                            font: { family: 'Inter', size: 11, weight: 'bold' },
                            color: '#4b5563'
                        },
                        grid: { display: false }
                    }
                }
            }
        });
    }

    function renderProjectInfo() {
        document.getElementById('header-project-name').textContent = project.name;
        document.getElementById('val-location').textContent = project.location;
        const s = document.getElementById('header-project-status'); s.textContent = project.status;
        let statusClass = 'bg-gray-100 text-gray-800';
        if (project.status === 'Aktif') statusClass = 'bg-green-100 text-green-800';
        else if (project.status === 'Selesai') statusClass = 'bg-blue-100 text-blue-800';
        else if (project.status === 'Tertunda') statusClass = 'bg-yellow-100 text-yellow-800';
        s.className = `status-badge px-2 py-0.5 rounded ${statusClass}`;
        document.getElementById('side-description').textContent = project.description;
        document.getElementById('side-start').textContent = project.start_date;
        document.getElementById('side-end').textContent = project.end_date;
        document.getElementById('side-executor').textContent = project.executor;
        document.getElementById('side-supervisor').textContent = project.supervisor;
    }

    function renderWorksAndActivities() {
        const container = document.getElementById('works-container');
        document.getElementById('work-count').textContent = `${project.works.length} Pekerjaan`;
        if (project.works.length === 0) {
            container.innerHTML = `<div class="text-center py-20 bg-white rounded-2xl border-2 border-dashed border-gray-200"><i data-lucide="briefcase" class="w-8 h-8 text-gray-300 mx-auto mb-4"></i><h3 class="font-bold">Belum ada pekerjaan</h3><button onclick="openAddWorkModal()" class="mt-4 px-6 py-2 bg-red-800 text-white font-bold rounded-lg">Tambah</button></div>`;
            lucide.createIcons(); return;
        }
        container.innerHTML = project.works.map(work => `
            <div class="work-card bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden mb-6">
                <div class="px-6 py-5 border-b border-gray-50 bg-gray-50/30 flex items-center justify-between">
                    <div><h3 class="text-lg font-black mt-1">${work.name}</h3></div>
                    <div class="flex items-center gap-2">
                        <button onclick="openAddActivityModal('${work.id}', '${work.name}')" class="p-2 text-gray-400 hover:text-red-800" title="Tambah Aktivitas"><i data-lucide="plus-circle" class="w-5 h-5"></i></button>
                        <button onclick="handleEditWork('${work.id}')" class="p-2 text-gray-400 hover:text-red-800" title="Edit Pekerjaan"><i data-lucide="edit-3" class="w-5 h-5"></i></button>
                        <button onclick="handleDeleteWork('${work.id}', '${work.name}')" class="p-2 text-gray-400 hover:text-red-600" title="Hapus Pekerjaan"><i data-lucide="trash-2" class="w-5 h-5"></i></button>
                    </div>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-left">
                        <thead><tr class="bg-gray-50 text-[10px] font-black text-gray-400 uppercase tracking-widest"><th class="px-6 py-4">Aktivitas</th><th class="px-6 py-4">Status & Bukti</th><th class="px-6 py-4 text-right">Aksi</th></tr></thead>
                        <tbody>${renderActivitiesRows(work.activities)}</tbody>
                    </table>
                </div>
            </div>`).join('');
        lucide.createIcons();
    }

    function formatBytes(bytes, decimals = 2) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const dm = decimals < 0 ? 0 : decimals;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

    function renderActivitiesRows(activities) {
        if (!activities || activities.length === 0) return `<tr><td colspan="3" class="px-6 py-8 text-center text-gray-400 italic">Belum ada aktivitas</td></tr>`;
        return activities.map(a => {
            const fileList = a.file_urls || [];
            return `
            <tr class="activity-row border-b border-gray-50">
                <td class="px-6 py-4">
                    <p class="font-bold text-gray-900 text-sm">${a.name}</p>
                    <p class="text-[10px] text-gray-500">${a.executor} • ${a.execution_time}</p>
                </td>
                <td class="px-6 py-4">
                    <div class="flex flex-col gap-4">
                        <!-- Status Section -->
                        <div class="flex items-center gap-2">
                            <span class="text-[9px] font-black text-gray-400 uppercase tracking-widest">Status:</span>
                            <button onclick="toggleStatus('${a.id}')" class="px-3 py-1 rounded-full text-[10px] font-black tracking-wider transition-all ${a.done ? 'bg-green-100 text-green-700 hover:bg-green-200' : 'bg-amber-100 text-amber-700 hover:bg-amber-200'}">
                                ${a.done ? 'SELESAI' : 'PROSES'}
                            </button>
                        </div>
                        
                        <!-- Proof Section -->
                        <div class="flex flex-col gap-2">
                            <div class="flex items-center gap-2">
                                <span class="text-[9px] font-black text-gray-400 uppercase tracking-widest">Bukti Terlampir:</span>
                            </div>
                            <div class="flex flex-wrap gap-3">
                                ${fileList.length > 0 ? fileList.map(f => {
                const isImg = /\.(jpg|jpeg|png|gif|webp)$/i.test(f.url);
                const sizeStr = f.size ? formatBytes(f.size) : '';

                if (isImg) return `
                                    <div class="relative group">
                                        <div class="w-16 h-16 rounded-xl overflow-hidden border-2 border-white shadow-sm ring-1 ring-gray-100">
                                            <img src="${f.url}" class="w-full h-full object-cover cursor-pointer" onclick="window.open('${f.url}')">
                                        </div>
                                        <button onclick="handleDeleteFile('${f.id}')" class="absolute -top-2 -right-2 hidden group-hover:flex w-5 h-5 bg-red-600 text-white rounded-full items-center justify-center shadow-lg hover:bg-red-700 transition-all z-10">
                                            <i data-lucide="x" class="w-3 h-3"></i>
                                        </button>
                                        <div class="absolute bottom-0 left-0 right-0 bg-black/60 text-white text-[7px] py-0.5 px-1 text-center truncate rounded-b-xl opacity-0 group-hover:opacity-100 transition-opacity">${f.name}</div>
                                    </div>`;

                const ext = f.name.split('.').pop().toUpperCase();
                const isAudio = /\.(mp3|wav|ogg|m4a)$/i.test(f.url);
                const isVideo = /\.(mp4|webm|mov|avi)$/i.test(f.url);
                const icon = isAudio ? 'volume-2' : (isVideo ? 'video' : 'file-text');

                return `
                                    <div class="flex items-center gap-3 p-2 bg-white rounded-xl border border-gray-100 shadow-sm group relative min-w-[160px] max-w-[220px] hover:border-red-100 transition-colors">
                                        <div class="w-10 h-10 rounded-lg bg-red-50 flex items-center justify-center shrink-0">
                                            <i data-lucide="${icon}" class="w-5 h-5 text-red-800"></i>
                                        </div>
                                        <a href="${f.url}" target="_blank" class="flex-1 min-w-0">
                                            <p class="text-[10px] font-black text-gray-900 truncate" title="${f.name}">${f.name}</p>
                                            <div class="flex items-center gap-2 mt-0.5">
                                                <span class="text-[8px] font-black text-red-800/60 uppercase">${ext}</span>
                                                <span class="text-[8px] text-gray-300 font-medium">${sizeStr}</span>
                                            </div>
                                        </a>
                                        <button onclick="handleDeleteFile('${f.id}')" class="absolute -top-2 -right-2 hidden group-hover:flex w-5 h-5 bg-red-600 text-white rounded-full items-center justify-center shadow-lg hover:bg-red-700 transition-all z-10">
                                            <i data-lucide="x" class="w-3 h-3"></i>
                                        </button>
                                    </div>`;
            }).join('') : '<span class="text-[10px] text-gray-300 italic font-medium">Belum ada bukti yang diunggah</span>'}
                            </div>
                        </div>
                    </div>
                </td>
                <td class="px-6 py-4 text-right flex justify-end gap-2">
                    <button onclick="handleEditActivity('${a.id}')" class="p-2 text-gray-400 hover:text-red-800" title="Edit Aktivitas"><i data-lucide="edit-3" class="w-5 h-5"></i></button>
                    <button onclick="openUploadModal('${a.id}')" class="p-2 ${fileList.length > 0 ? 'text-gray-200' : 'text-gray-400 hover:text-red-800'}" title="${fileList.length > 0 ? 'Bukti sudah ada' : 'Upload File Bukti'}"><i data-lucide="paperclip" class="w-5 h-5"></i></button>
                    <button onclick="handleDeleteActivity('${a.id}', '${a.name}')" class="p-2 text-gray-400 hover:text-red-600" title="Hapus Aktivitas"><i data-lucide="trash-2" class="w-5 h-5"></i></button>
                </td>
            </tr>`}).join('');
    }

    function calculateOverallProgress() {
        let t = 0, c = 0; project.works.forEach(w => w.activities.forEach(a => { t++; if (a.done) c++; }));
        const p = t === 0 ? 0 : Math.round((c / t) * 100);
        document.getElementById('overall-progress').textContent = `${p}%`;
        document.getElementById('completed-count').textContent = `${c}/${t} Selesai`;
        document.getElementById('progress-bar').style.width = `${p}%`;
    }

    async function downloadPdf() {
        try {
            const response = await apiRequest(`/reports/project/${projectId}/pdf/`);
            if (!response.ok) throw new Error('Failed');
            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `Report_${project.name.replace(/\s+/g, '_')}.pdf`;
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            showToast('Laporan PDF berhasil diunduh');
        } catch (error) {
            showToast('Gagal mengunduh laporan PDF', 'error');
        }
    }

    async function downloadExcel() {
        try {
            const response = await apiRequest(`/reports/project/${projectId}/excel/`);
            if (!response.ok) throw new Error('Failed');
            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `Report_${project.name.replace(/\s+/g, '_')}.xlsx`;
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            showToast('Laporan Excel berhasil diunduh');
        } catch (error) {
            showToast('Gagal mengunduh laporan Excel', 'error');
        }
    }

    async function toggleStatus(id) { try { if (await apiRequest(`/activities/${id}/toggle_done/`, { method: 'PATCH' })) { loadProjectData(); } } catch (e) { } }

    function openAddWorkModal() { document.getElementById('add-work-modal').classList.remove('hidden'); }
    function openAddActivityModal(id, name) { document.getElementById('target-work-id').value = id; document.getElementById('add-activity-modal').classList.remove('hidden'); }
    function openUploadModal(id) {
        let activity = null;
        project.works.forEach(w => {
            const found = w.activities.find(a => a.id === id);
            if (found) activity = found;
        });

        if (activity && activity.file_urls && activity.file_urls.length > 0) {
            showToast('BUKTI SUDAH ADA. Hapus bukti lama untuk mengganti.', 'warning');
            return;
        }

        document.getElementById('upload-activity-id').value = id;
        showUploadMethod('selection');
        document.getElementById('upload-file-modal').classList.remove('hidden');
    }

    function closeModal(id) {
        stopMedia();
        document.getElementById(id).classList.add('hidden');
    }

    // --- Upload Methods Logic ---
    let mediaStream = null;
    let mediaRecorder = null;
    let audioChunks = [];
    let recordingTimer = null;
    let recordingSeconds = 0;
    let pendingUpload = null;

    function showUploadMethod(method) {
        // Stop any active media unless switching to/from preview
        if (method !== 'preview' && method !== 'camera') stopMedia();

        const methods = ['selection', 'file', 'camera', 'voice', 'preview'];
        methods.forEach(m => {
            const el = document.getElementById(`method-${m}`) || document.getElementById(`upload-${m}`);
            if (el) el.classList.add('hidden');
        });
        document.getElementById('method-footer').classList.toggle('hidden', method === 'selection' || method === 'preview');

        const target = document.getElementById(`method-${method}`) || document.getElementById(`upload-${method}`);
        if (target) target.classList.remove('hidden');

        if (method === 'camera') startCamera();
        if (method === 'voice') initVoiceUI();

        lucide.createIcons();
    }

    function showPreview(data, name, type) {
        pendingUpload = { data, name, type };
        stopMedia(); // Close hardware streams

        showUploadMethod('preview');

        ['img', 'video', 'audio-container', 'file-info'].forEach(id => {
            document.getElementById(`preview-${id}`).classList.add('hidden');
        });

        if (type === 'image') {
            const el = document.getElementById('preview-img');
            el.src = data; el.classList.remove('hidden');
        } else if (type === 'video') {
            const el = document.getElementById('preview-video');
            el.src = data; el.classList.remove('hidden'); el.load();
        } else if (type === 'audio') {
            const el = document.getElementById('preview-audio');
            el.src = data; document.getElementById('preview-audio-container').classList.remove('hidden'); el.load();
        } else {
            document.getElementById('preview-file-info').classList.remove('hidden');
            document.getElementById('preview-filename').textContent = name;
        }
        lucide.createIcons();
    }

    function cancelPreview() {
        const prevMethod = (pendingUpload.type === 'image' || pendingUpload.type === 'video') ? 'camera' :
            (pendingUpload.type === 'audio' ? 'voice' : 'selection');
        pendingUpload = null;
        showUploadMethod(prevMethod);
    }

    function confirmUpload() {
        if (!pendingUpload) return;
        uploadBase64(pendingUpload.data, pendingUpload.name);
    }

    function handleFileSelect(input) {
        const file = input.files[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = (e) => {
            const type = file.type.startsWith('image/') ? 'image' :
                (file.type.startsWith('video/') ? 'video' :
                    (file.type.startsWith('audio/') ? 'audio' : 'file'));
            showPreview(e.target.result, file.name, type);
        };
        reader.readAsDataURL(file);
    }

    async function startCamera() {
        const video = document.getElementById('camera-preview');
        const loading = document.getElementById('camera-loading');
        loading.classList.remove('hidden');
        try {
            // We request audio too just in case they want to record video
            mediaStream = await navigator.mediaDevices.getUserMedia({
                video: { facingMode: 'environment' },
                audio: true
            });
            video.srcObject = mediaStream;
            loading.classList.add('hidden');
        } catch (err) {
            // If audio fails, try video only
            try {
                mediaStream = await navigator.mediaDevices.getUserMedia({
                    video: { facingMode: 'environment' },
                    audio: false
                });
                video.srcObject = mediaStream;
                loading.classList.add('hidden');
            } catch (err2) {
                showToast('Gagal mengakses kamera. Pastikan izin diberikan.', 'error');
                showUploadMethod('selection');
            }
        }
    }

    function stopMedia() {
        if (mediaStream) {
            mediaStream.getTracks().forEach(track => track.stop());
            mediaStream = null;
        }
        if (mediaRecorder && mediaRecorder.state !== 'inactive') {
            mediaRecorder.stop();
        }
        clearInterval(recordingTimer);
    }

    function capturePhoto() {
        const video = document.getElementById('camera-preview');
        const canvas = document.getElementById('camera-canvas');
        const context = canvas.getContext('2d');

        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        context.drawImage(video, 0, 0, canvas.width, canvas.height);
        const base64 = canvas.toDataURL('image/jpeg', 0.8);
        showPreview(base64, 'photo.jpg', 'image');
    }

    // --- Video Recording Logic ---
    function toggleVideoRecording() {
        if (!mediaRecorder || mediaRecorder.state === 'inactive') {
            startVideoRecording();
        } else {
            stopVideoRecording();
        }
    }

    function startVideoRecording() {
        if (!mediaStream) return;

        audioChunks = [];
        mediaRecorder = new MediaRecorder(mediaStream);

        mediaRecorder.ondataavailable = (e) => {
            if (e.data.size > 0) audioChunks.push(e.data);
        };

        mediaRecorder.onstop = () => {
            const videoBlob = new Blob(audioChunks, { type: 'video/webm' });
            const reader = new FileReader();
            reader.onloadend = () => showPreview(reader.result, 'video.mp4', 'video');
            reader.readAsDataURL(videoBlob);

            // Reset UI
            document.getElementById('video-recording-indicator').classList.add('hidden');
            const btn = document.getElementById('video-record-btn');
            btn.innerHTML = '<i data-lucide="video" class="w-5 h-5"></i> Rekam Video';
            btn.className = 'py-3 bg-gray-900 text-white rounded-xl font-bold flex items-center justify-center gap-2';
            lucide.createIcons();
        };

        mediaRecorder.start();

        // UI Update
        recordingSeconds = 0;
        updateVideoTimer();
        document.getElementById('video-recording-indicator').classList.remove('hidden');

        const btn = document.getElementById('video-record-btn');
        btn.innerHTML = '<i data-lucide="square" class="w-5 h-5"></i> Berhenti';
        btn.className = 'py-3 bg-red-600 text-white rounded-xl font-bold flex items-center justify-center gap-2 animate-pulse';

        recordingTimer = setInterval(() => {
            recordingSeconds++;
            updateVideoTimer();
        }, 1000);

        lucide.createIcons();
    }

    function stopVideoRecording() {
        if (mediaRecorder) mediaRecorder.stop();
        clearInterval(recordingTimer);
    }

    function updateVideoTimer() {
        const mins = Math.floor(recordingSeconds / 60).toString().padStart(2, '0');
        const secs = (recordingSeconds % 60).toString().padStart(2, '0');
        document.getElementById('video-timer').textContent = `${mins}:${secs}`;
    }

    function initVoiceUI() {
        recordingSeconds = 0;
        updateVoiceTimer();
        const btn = document.getElementById('voice-action-btn');
        btn.innerHTML = '<i data-lucide="play" class="w-5 h-5"></i> Mulai Rekam';
        btn.className = 'flex-1 py-3 bg-red-800 text-white rounded-xl font-bold flex items-center justify-center gap-2';
        document.getElementById('voice-status').textContent = 'Siap Merekam';
        document.getElementById('voice-animation').className = 'w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mb-4 transition-all duration-300';
        lucide.createIcons();
    }

    async function toggleVoiceRecording() {
        if (!mediaRecorder || mediaRecorder.state === 'inactive') {
            startVoiceRecording();
        } else {
            stopVoiceRecording();
        }
    }

    async function startVoiceRecording() {
        try {
            mediaStream = await navigator.mediaDevices.getUserMedia({ audio: true });
            mediaRecorder = new MediaRecorder(mediaStream);
            audioChunks = [];

            mediaRecorder.ondataavailable = (e) => {
                if (e.data.size > 0) audioChunks.push(e.data);
            };

            mediaRecorder.onstop = () => {
                const audioBlob = new Blob(audioChunks, { type: 'audio/webm' });
                const reader = new FileReader();
                reader.onloadend = () => showPreview(reader.result, 'voice.mp3', 'audio');
                reader.readAsDataURL(audioBlob);
            };

            mediaRecorder.start();

            // UI Update
            recordingSeconds = 0;
            recordingTimer = setInterval(() => {
                recordingSeconds++;
                updateVoiceTimer();
                // Pulsing animation
                const anim = document.getElementById('voice-animation');
                anim.classList.toggle('scale-110');
            }, 1000);

            const btn = document.getElementById('voice-action-btn');
            btn.innerHTML = '<i data-lucide="square" class="w-5 h-5"></i> Berhenti';
            btn.className = 'flex-1 py-3 bg-gray-900 text-white rounded-xl font-bold flex items-center justify-center gap-2';
            document.getElementById('voice-status').textContent = 'Sedang Merekam...';
            document.getElementById('voice-animation').classList.add('bg-red-200');
            lucide.createIcons();

        } catch (err) {
            showToast('Gagal mengakses mikrofon.', 'error');
        }
    }

    function stopVoiceRecording() {
        if (mediaRecorder) mediaRecorder.stop();
        stopMedia();
        document.getElementById('voice-status').textContent = 'Memproses...';
    }

    function updateVoiceTimer() {
        const mins = Math.floor(recordingSeconds / 60).toString().padStart(2, '0');
        const secs = (recordingSeconds % 60).toString().padStart(2, '0');
        document.getElementById('voice-timer').textContent = `${mins}:${secs}`;
    }

    async function uploadBase64(base64, filename) {
        const activityId = document.getElementById('upload-activity-id').value;
        const loading = document.getElementById('uploading-state');

        // Hide methods, show loader
        const methods = ['file', 'camera', 'voice', 'selection'];
        methods.forEach(m => {
            const el = document.getElementById(`method-${m}`) || document.getElementById(`upload-${m}`);
            if (el) el.classList.add('hidden');
        });
        document.getElementById('method-footer').classList.add('hidden');
        loading.classList.remove('hidden');

        try {
            const res = await apiRequest(`/activities/${activityId}/`, {
                method: 'PATCH',
                body: JSON.stringify({
                    files: [{
                        name: filename,
                        data: base64
                    }]
                })
            });
            if (res.ok) {
                showToast('Bukti berhasil diupload');
                loadProjectData();
                closeModal('upload-file-modal');
            } else {
                const data = await res.json();
                showToast(data.files || 'Gagal upload', 'error');
                showUploadMethod('selection');
            }
        } catch (err) {
            showToast('Terjadi kesalahan koneksi', 'error');
            showUploadMethod('selection');
        } finally {
            loading.classList.add('hidden');
        }
    }

    async function handleWorkSubmit(e) {
        e.preventDefault();
        const body = { project_id: projectId, name: document.getElementById('new-work-name').value, description: document.getElementById('new-work-description').value, location: document.getElementById('new-work-location').value, start_date: document.getElementById('new-work-start').value, end_date: document.getElementById('new-work-end').value, executor: document.getElementById('new-work-executor').value, supervisor: document.getElementById('new-work-supervisor').value };
        if (await apiRequest('/works/', { method: 'POST', body: JSON.stringify(body) })) { closeModal('add-work-modal'); loadProjectData(); }
    }

    function handleEditWork(id) {
        const work = project.works.find(w => w.id === id);
        if (!work) return;

        document.getElementById('edit-work-id').value = work.id;
        document.getElementById('edit-work-name').value = work.name;
        document.getElementById('edit-work-description').value = work.description;
        document.getElementById('edit-work-location').value = work.location;
        document.getElementById('edit-work-start').value = work.start_date;
        document.getElementById('edit-work-end').value = work.end_date;
        document.getElementById('edit-work-executor').value = work.executor;
        document.getElementById('edit-work-supervisor').value = work.supervisor;

        document.getElementById('edit-work-modal').classList.remove('hidden');
    }

    async function submitEditWork(e) {
        e.preventDefault();
        const id = document.getElementById('edit-work-id').value;
        const body = {
            name: document.getElementById('edit-work-name').value,
            description: document.getElementById('edit-work-description').value,
            location: document.getElementById('edit-work-location').value,
            start_date: document.getElementById('edit-work-start').value,
            end_date: document.getElementById('edit-work-end').value,
            executor: document.getElementById('edit-work-executor').value,
            supervisor: document.getElementById('edit-work-supervisor').value
        };
        try {
            const res = await apiRequest(`/works/${id}/`, {
                method: 'PATCH',
                body: JSON.stringify(body)
            });
            if (res.ok) {
                showToast('Pekerjaan berhasil diperbarui');
                closeModal('edit-work-modal');
                loadProjectData();
            } else {
                const data = await res.json();
                showToast(data.error || 'Gagal memperbarui pekerjaan', 'error');
            }
        } catch (err) {
            showToast('Terjadi kesalahan', 'error');
        }
    }

    async function handleActivitySubmit(e) {
        e.preventDefault();
        const body = { work_id: document.getElementById('target-work-id').value, name: document.getElementById('new-activity-name').value, execution_time: document.getElementById('new-activity-time').value, executor: document.getElementById('new-activity-executor').value };
        const res = await apiRequest('/activities/', { method: 'POST', body: JSON.stringify(body) });
        if (res.ok) {
            closeModal('add-activity-modal');
            loadProjectData();
            showToast('Aktivitas berhasil ditambahkan');
            e.target.reset();
        } else {
            const data = await res.json();
            showToast(data.error || 'Gagal menambahkan aktivitas', 'error');
        }
    }

    function handleFileUpload(input) {
        if (!input.files || !input.files[0]) return;
        const file = input.files[0];

        // Check size (5MB)
        if (file.size > 5 * 1024 * 1024) {
            showToast('Ukuran file maksimal 5MB!', 'error');
            return;
        }

        const reader = new FileReader();
        reader.onload = (e) => uploadBase64(e.target.result, file.name);
        reader.readAsDataURL(input.files[0]);
    }

    function handleEditProject() {
        if (!project) return;
        document.getElementById('edit-project-name').value = project.name;
        document.getElementById('edit-project-description').value = project.description;
        document.getElementById('edit-project-location').value = project.location;
        document.getElementById('edit-project-status').value = project.status;
        document.getElementById('edit-project-closed').checked = project.is_closed;
        document.getElementById('edit-project-start').value = project.start_date;
        document.getElementById('edit-project-end').value = project.end_date;
        document.getElementById('edit-project-executor').value = project.executor;
        document.getElementById('edit-project-supervisor').value = project.supervisor;
        document.getElementById('edit-project-modal').classList.remove('hidden');
    }

    async function submitEditProject(e) {
        e.preventDefault();
        const body = {
            name: document.getElementById('edit-project-name').value,
            description: document.getElementById('edit-project-description').value,
            location: document.getElementById('edit-project-location').value,
            status: document.getElementById('edit-project-status').value,
            is_closed: document.getElementById('edit-project-closed').checked,
            start_date: document.getElementById('edit-project-start').value,
            end_date: document.getElementById('edit-project-end').value,
            executor: document.getElementById('edit-project-executor').value,
            supervisor: document.getElementById('edit-project-supervisor').value
        };
        try {
            const res = await apiRequest(`/projects/${projectId}/`, {
                method: 'PATCH',
                body: JSON.stringify(body)
            });
            if (res.ok) {
                showToast('Proyek berhasil diperbarui');
                closeModal('edit-project-modal');
                loadProjectData();
            } else {
                const data = await res.json();
                showToast(data.error || 'Gagal memperbarui proyek', 'error');
            }
        } catch (err) {
            showToast('Terjadi kesalahan', 'error');
        }
    }

    function handleEditActivity(id) {
        let activity = null;
        project.works.forEach(w => {
            const found = w.activities.find(a => a.id === id);
            if (found) activity = found;
        });
        if (!activity) return;

        document.getElementById('edit-activity-id').value = activity.id;
        document.getElementById('edit-activity-name').value = activity.name;
        document.getElementById('edit-activity-time').value = activity.execution_time;
        document.getElementById('edit-activity-executor').value = activity.executor;
        document.getElementById('edit-activity-evaluation').value = activity.evaluation || '';
        document.getElementById('edit-activity-plan').value = activity.additional_plan || '';
        document.getElementById('edit-activity-modal').classList.remove('hidden');
    }

    async function submitEditActivity(e) {
        e.preventDefault();
        const id = document.getElementById('edit-activity-id').value;
        const body = {
            name: document.getElementById('edit-activity-name').value,
            execution_time: document.getElementById('edit-activity-time').value,
            executor: document.getElementById('edit-activity-executor').value,
            evaluation: document.getElementById('edit-activity-evaluation').value,
            additional_plan: document.getElementById('edit-activity-plan').value
        };
        if (await apiRequest(`/activities/${id}/`, { method: 'PATCH', body: JSON.stringify(body) })) {
            showToast('Aktivitas diperbarui');
            closeModal('edit-activity-modal');
            loadProjectData();
        }
    }

    async function handleDeleteFile(id) {
        if (!confirm('Hapus file ini?')) return;
        try {
            const res = await apiRequest(`/activity-files/${id}/`, { method: 'DELETE' });
            if (res.ok) {
                showToast('File dihapus');
                loadProjectData();
            } else { showToast('Gagal menghapus file', 'error'); }
        } catch (err) { showToast('Terjadi kesalahan', 'error'); }
    }

    async function handleDeleteProject() {
        if (!project) return;
        if (!confirm(`Apakah Anda yakin ingin menghapus proyek "${project.name}"? Semua data terkait akan hilang permanen.`)) return;
        try {
            const res = await apiRequest(`/projects/${projectId}/`, { method: 'DELETE' });
            if (res.ok) {
                showToast('Proyek berhasil dihapus');
                window.location.href = '/projects';
            } else {
                showToast('Gagal menghapus proyek', 'error');
            }
        } catch (err) { showToast('Terjadi kesalahan', 'error'); }
    }

    async function handleDeleteWork(id, name) {
        if (!confirm(`Hapus pekerjaan "${name}"? Semua aktivitas di dalamnya juga akan terhapus.`)) return;
        try {
            const res = await apiRequest(`/works/${id}/`, { method: 'DELETE' });
            if (res.ok) {
                showToast('Pekerjaan berhasil dihapus');
                loadProjectData();
            } else { showToast('Gagal menghapus pekerjaan', 'error'); }
        } catch (err) { showToast('Terjadi kesalahan', 'error'); }
    }

    async function handleDeleteActivity(id, name) {
        if (!confirm(`Hapus aktivitas "${name}"?`)) return;
        try {
            const res = await apiRequest(`/activities/${id}/`, { method: 'DELETE' });
            if (res.ok) {
                showToast('Aktivitas berhasil dihapus');
                loadProjectData();
            } else { showToast('Gagal menghapus aktivitas', 'error'); }
        } catch (err) { showToast('Terjadi kesalahan', 'error'); }
    }

    document.addEventListener('DOMContentLoaded', loadProjectData);
