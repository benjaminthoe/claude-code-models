/* ═══════════════════════════════════════════════════════
   PPT Studio — App Logic v3 (History + No Video)
   ═══════════════════════════════════════════════════════ */

var API = '';
var currentPresentation = null;
var currentPresentationId = null;
var currentSlideIndex = 0;
var deckHistory = [];

var messagesEl = document.getElementById('chat-messages');
var inputEl = document.getElementById('chat-input');

// Load history from localStorage on startup
try { deckHistory = JSON.parse(localStorage.getItem('ppt_history') || '[]'); } catch(e) { deckHistory = []; }
renderHistory();

inputEl.addEventListener('keydown', function(e) {
  if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); }
});

function sendMessage() {
  var text = inputEl.value.trim();
  if (!text) return;
  addMessage('user', text);
  inputEl.value = '';
  processCommand(text);
}

function addMessage(role, content) {
  var msg = document.createElement('div');
  msg.className = 'msg ' + role;
  msg.innerHTML = '<div class="msg-content">' + content + '</div>';
  messagesEl.appendChild(msg);
  messagesEl.scrollTop = messagesEl.scrollHeight;
  return msg;
}

function updateStatus(text) {
  document.getElementById('status-left').innerHTML = text;
}

// ── History Management ────────────────────────────────
function saveToHistory(title, theme, slideCount, html) {
  var entry = {
    id: Date.now().toString(36) + Math.random().toString(36).substr(2, 4),
    title: title,
    theme: theme,
    slides: slideCount,
    created: new Date().toISOString(),
    html: html
  };
  deckHistory.unshift(entry);
  if (deckHistory.length > 20) deckHistory.pop(); // keep last 20
  localStorage.setItem('ppt_history', JSON.stringify(deckHistory));
  currentPresentationId = entry.id;
  renderHistory();
  return entry;
}

function loadFromHistory(id) {
  var entry = deckHistory.find(function(h) { return h.id === id; });
  if (!entry) return;
  currentPresentation = entry.html;
  currentPresentationId = entry.id;
  document.getElementById('preview-frame').srcdoc = entry.html;
  updateThumbs(entry.slides);
  updateStatus(entry.title + ' — ' + entry.slides + ' slides');
  document.getElementById('theme-select').value = entry.theme;
  // Highlight active in history
  renderHistory();
  addMessage('assistant', 'Loaded <strong>' + escapeHtml(entry.title) + '</strong> from history.');
}

function deleteFromHistory(id) {
  deckHistory = deckHistory.filter(function(h) { return h.id !== id; });
  localStorage.setItem('ppt_history', JSON.stringify(deckHistory));
  renderHistory();
}

function duplicateFromHistory(id) {
  var entry = deckHistory.find(function(h) { return h.id === id; });
  if (!entry) return;
  var copy = JSON.parse(JSON.stringify(entry));
  copy.id = Date.now().toString(36) + Math.random().toString(36).substr(2, 4);
  copy.title = entry.title + ' (Copy)';
  copy.created = new Date().toISOString();
  deckHistory.unshift(copy);
  localStorage.setItem('ppt_history', JSON.stringify(deckHistory));
  renderHistory();
  addMessage('assistant', 'Duplicated <strong>' + escapeHtml(entry.title) + '</strong>.');
}

function renderHistory() {
  var list = document.getElementById('history-list');
  if (!list) return;
  if (deckHistory.length === 0) {
    list.innerHTML = '<div style="padding:16px;text-align:center;color:var(--text3);font-size:12px">No presentations yet.<br>Create one to see it here.</div>';
    return;
  }
  list.innerHTML = '';
  deckHistory.forEach(function(h) {
    var date = new Date(h.created);
    var timeStr = date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], {hour:'2-digit',minute:'2-digit'});
    var themeIcon = h.theme === 'apple' ? '&#63743;' : h.theme === 'xiaomi' ? '&#128241;' : '&#9670;';
    var div = document.createElement('div');
    div.className = 'history-item' + (h.id === currentPresentationId ? ' active' : '');
    div.innerHTML =
      '<div class="hi-icon">' + themeIcon + '</div>' +
      '<div class="hi-info">' +
        '<div class="hi-title">' + escapeHtml(h.title) + '</div>' +
        '<div class="hi-meta">' + h.slides + ' slides &middot; ' + timeStr + '</div>' +
      '</div>' +
      '<div class="hi-actions">' +
        '<button class="hi-btn" title="Duplicate" data-action="dup" data-id="' + h.id + '">&#128203;</button>' +
        '<button class="hi-btn" title="Delete" data-action="del" data-id="' + h.id + '">&#128465;</button>' +
      '</div>';
    div.addEventListener('click', function(e) {
      var btn = e.target.closest('[data-action]');
      if (btn) {
        e.stopPropagation();
        if (btn.dataset.action === 'del') deleteFromHistory(btn.dataset.id);
        else if (btn.dataset.action === 'dup') duplicateFromHistory(btn.dataset.id);
        return;
      }
      loadFromHistory(h.id);
    });
    list.appendChild(div);
  });
}

function toggleHistory() {
  var drawer = document.getElementById('history-drawer');
  var btn = document.getElementById('history-btn');
  drawer.classList.toggle('hidden');
  btn.classList.toggle('active');
}

// ── Command Processor ─────────────────────────────────
function processCommand(text) {
  var lower = text.toLowerCase();
  if (lower.includes('apple') && (lower.includes('keynote') || lower.includes('launch') || lower.includes('style'))) {
    loadTemplate('apple', 'Apple Keynote — ' + text.substring(0, 40), 10);
  } else if (lower.includes('xiaomi') || lower.includes('lei jun')) {
    loadTemplate('xiaomi', 'Xiaomi Keynote — ' + text.substring(0, 40), 10);
  } else {
    addMessage('assistant', '<span class="spinner"></span> Generating...');
    updateStatus('<span class="generating">Generating...</span>');
    var iframe = document.getElementById('preview-frame');
    var placeholderHtml = '<html><body style="background:#08080f;color:white;font-family:Inter,sans-serif;display:flex;align-items:center;justify-content:center;height:100vh;margin:0;text-align:center;padding:40px"><div><h1 style="font-size:48px;font-weight:800;margin-bottom:16px">' + escapeHtml(text) + '</h1><p style="color:rgba(255,255,255,0.5);font-size:18px">For full AI-generated slides, use Claude Code with the /keynote-ppt skill.<br>Or try: "Apple keynote" or "Xiaomi Lei Jun keynote"</p></div></body></html>';
    iframe.srcdoc = placeholderHtml;
    currentPresentation = placeholderHtml;
    saveToHistory(text.substring(0, 60), 'dark', 1, placeholderHtml);
    updateThumbs(1);
    updateStatus('Ready');
    addMessage('assistant', 'Try: <strong>"Create an Apple-style keynote"</strong> or <strong>"Create a Xiaomi Lei Jun keynote"</strong> for full cinematic demos.');
  }
}

// ── Template Loader ───────────────────────────────────
function loadTemplate(name, label, slideCount) {
  addMessage('assistant', '<span class="spinner"></span> Building <strong>' + (name === 'apple' ? 'Apple Keynote' : 'Xiaomi Keynote') + '</strong>...');
  updateStatus('<span class="generating">Crafting slides...</span>');

  fetch('/templates/' + name + '.html')
    .then(function(resp) {
      if (!resp.ok) throw new Error('Template not found');
      return resp.text();
    })
    .then(function(html) {
      var iframe = document.getElementById('preview-frame');
      iframe.srcdoc = html;
      currentPresentation = html;
      updateThumbs(slideCount);
      var shortLabel = name === 'apple' ? 'Apple Keynote' : 'Xiaomi Keynote';
      updateStatus(shortLabel + ' — ' + slideCount + ' slides');
      document.getElementById('theme-select').value = name;
      // Save to history
      saveToHistory(label, name, slideCount, html);
      addMessage('assistant', shortLabel + ' ready! <strong>' + slideCount + ' slides</strong> with cinematic animations. Use arrow keys in the preview to navigate. Click <strong>History</strong> to see saved decks.');
    })
    .catch(function(e) {
      addMessage('assistant', 'Error: ' + e.message);
      updateStatus('Error');
    });
}

// ── Preview ───────────────────────────────────────────
function updateThumbs(count) {
  var thumbs = document.getElementById('slide-thumbs');
  thumbs.innerHTML = '';
  for (var i = 0; i < count; i++) {
    var t = document.createElement('div');
    t.className = 'slide-thumb' + (i === 0 ? ' active' : '');
    t.innerHTML = '<div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:16px;font-weight:700;color:rgba(255,255,255,0.2)">' + (i + 1) + '</div>';
    t.setAttribute('data-idx', String(i));
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
  addMessage('assistant', 'HTML exported! Self-contained — anyone can open it in a browser.');
}

function exportPPTX() {
  if (!currentPresentation) { addMessage('assistant', 'No presentation loaded yet.'); return; }
  // Save HTML to server, then tell user to run export
  fetch('/api/save-presentation', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({filename: 'presentation.html', content: currentPresentation})
  }).then(function() {
    addMessage('assistant', 'Saved. Run in terminal:<br><code>python3 ppt-engine/export_pptx.py data.json output.pptx</code>');
  });
}

// ── Utility ───────────────────────────────────────────
function escapeHtml(s) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
