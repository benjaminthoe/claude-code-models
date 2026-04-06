/* ═══════════════════════════════════════════════════════
   PPT Studio — App Logic (v2: templates loaded from files)
   ═══════════════════════════════════════════════════════ */

const API = '';
let currentPresentation = null;
let currentSlideIndex = 0;

const messagesEl = document.getElementById('chat-messages');
const inputEl = document.getElementById('chat-input');

inputEl.addEventListener('keydown', e => {
  if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); }
});

function sendMessage() {
  const text = inputEl.value.trim();
  if (!text) return;
  addMessage('user', text);
  inputEl.value = '';
  processCommand(text);
}

function addMessage(role, content) {
  const msg = document.createElement('div');
  msg.className = 'msg ' + role;
  msg.innerHTML = '<div class="msg-content">' + content + '</div>';
  messagesEl.appendChild(msg);
  messagesEl.scrollTop = messagesEl.scrollHeight;
  return msg;
}

function updateStatus(text) {
  document.getElementById('status-left').innerHTML = text;
}

// ── Command Processor ─────────────────────────────────
async function processCommand(text) {
  const lower = text.toLowerCase();
  if (lower.includes('apple') && (lower.includes('keynote') || lower.includes('launch') || lower.includes('style'))) {
    await loadTemplate('apple', 'Apple Keynote', 10);
  } else if (lower.includes('xiaomi') || lower.includes('lei jun')) {
    await loadTemplate('xiaomi', 'Xiaomi / Lei Jun', 10);
  } else if (lower.includes('video') || lower.includes('tony')) {
    addMessage('assistant', '<span class="generating">Video Pipeline</span> — Tony video generation is in progress. Check the terminal for status.');
  } else {
    addMessage('assistant', '<span class="spinner"></span> Generating presentation...');
    updateStatus('<span class="generating">Generating...</span>');
    // Default: load a simple placeholder — real generation requires Claude backend
    const iframe = document.getElementById('preview-frame');
    iframe.srcdoc = '<html><body style="background:#08080f;color:white;font-family:Inter,sans-serif;display:flex;align-items:center;justify-content:center;height:100vh;margin:0;text-align:center;padding:40px"><div><h1 style="font-size:48px;font-weight:800;margin-bottom:16px">' + escapeHtml(text) + '</h1><p style="color:rgba(255,255,255,0.5);font-size:18px">Select Apple or Xiaomi theme for a full demo, or use Claude Code with /keynote-ppt skill for custom generation.</p></div></body></html>';
    updateStatus('Ready — select a theme for full demo');
    addMessage('assistant', 'For full AI-generated slides, use <strong>Claude Code</strong> with the <code>/keynote-ppt</code> skill. Or try: "Create an Apple-style keynote" or "Create a Xiaomi Lei Jun keynote".');
  }
}

// ── Template Loader ───────────────────────────────────
async function loadTemplate(name, label, slideCount) {
  addMessage('assistant', '<span class="spinner"></span> Building <strong>' + label + '</strong> presentation...');
  updateStatus('<span class="generating">Crafting ' + label + ' slides...</span>');

  try {
    const resp = await fetch('/templates/' + name + '.html');
    if (!resp.ok) throw new Error('Template not found');
    const html = await resp.text();

    const iframe = document.getElementById('preview-frame');
    iframe.srcdoc = html;
    currentPresentation = html;
    updateThumbs(slideCount);
    updateStatus(label + ' — ' + slideCount + ' slides');
    document.getElementById('theme-select').value = name === 'apple' ? 'apple' : name === 'xiaomi' ? 'xiaomi' : 'dark';
    addMessage('assistant', label + ' ready! <strong>' + slideCount + ' slides</strong> with cinematic animations. Click slides below or use arrow keys in the preview to navigate.');
  } catch (e) {
    addMessage('assistant', 'Error loading template: ' + e.message);
    updateStatus('Error');
  }
}

// ── Preview ───────────────────────────────────────────
function updateThumbs(count) {
  const thumbs = document.getElementById('slide-thumbs');
  thumbs.innerHTML = '';
  for (var i = 0; i < count; i++) {
    var t = document.createElement('div');
    t.className = 'slide-thumb' + (i === 0 ? ' active' : '');
    t.innerHTML = '<div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:16px;font-weight:700;color:rgba(255,255,255,0.2)">' + (i + 1) + '</div>';
    t.setAttribute('data-idx', i);
    t.onclick = function() { navigateSlide(parseInt(this.getAttribute('data-idx'))); };
    thumbs.appendChild(t);
  }
  document.getElementById('status-right').textContent = 'Slide 1 / ' + count;
}

function navigateSlide(index) {
  var iframe = document.getElementById('preview-frame');
  try {
    iframe.contentWindow.Reveal.slide(index);
    currentSlideIndex = index;
    document.querySelectorAll('.slide-thumb').forEach(function(t, i) {
      t.classList.toggle('active', i === index);
    });
    var total = document.querySelectorAll('.slide-thumb').length;
    document.getElementById('status-right').textContent = 'Slide ' + (index + 1) + ' / ' + total;
  } catch (e) {}
}

// ── Export ─────────────────────────────────────────────
function exportHTML() {
  if (!currentPresentation) { addMessage('assistant', 'No presentation loaded yet.'); return; }
  var blob = new Blob([currentPresentation], { type: 'text/html' });
  var a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'presentation.html';
  a.click();
  addMessage('assistant', 'HTML exported! Self-contained file — anyone can open it.');
}

function exportPPTX() {
  addMessage('assistant', 'PPTX export: use <code>python3 ppt-engine/export_pptx.py</code> from terminal.');
}

function exportVideo() {
  addMessage('assistant', 'Video export: screen-record the HTML presentation, or use the Tony video pipeline.');
}

// ── Utility ───────────────────────────────────────────
function escapeHtml(s) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
