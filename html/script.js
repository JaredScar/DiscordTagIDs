'use strict';

// ── GTA base colors ───────────────────────────────────────────────────────────
const BASE_COLORS = [
    { code: '~r~', label: 'Red',    css: '#e05555' },
    { code: '~g~', label: 'Green',  css: '#55cc55' },
    { code: '~b~', label: 'Blue',   css: '#5599ee' },
    { code: '~y~', label: 'Yellow', css: '#eecc44' },
    { code: '~o~', label: 'Orange', css: '#ee8833' },
    { code: '~p~', label: 'Purple', css: '#bb44ee' },
    { code: '~w~', label: 'White',  css: '#e8e8f0' },
];

// ── Pattern definitions (visual metadata for the NUI) ────────────────────────
// These match Config.ColorPatterns on the server.
const PATTERN_META = {
    '~RGB~':       { label: 'Rainbow',   colors: ['#e05555','#eecc44','#55cc55','#5599ee','#bb44ee','#ee8833'] },
    '~CHRISTMAS~': { label: 'Christmas', colors: ['#e05555','#55cc55'] },
    '~AMERICA~':   { label: 'America',   colors: ['#e05555','#e8e8f0','#5599ee'] },
    '~HALLOWEEN~': { label: 'Halloween', colors: ['#ee8833','#e8e8f0'] },
    '~DEVIL~':     { label: 'Devil',     colors: ['#e05555','#888899','#444455'] },
};

// ── State ─────────────────────────────────────────────────────────────────────
let state = {
    tags:            [],
    slots:           0,
    maxLen:          20,
    allowedPatterns: [],   // array of pattern code strings the player has unlocked
    editIndex:       null,
    selectedColor:   '~w~',
    activeIndex:     null,
};

// Pattern animation — each pattern token cycles its colors independently
const patternAnimState = {};  // { [code]: { idx, timer, intervalId } }

// ── DOM refs ──────────────────────────────────────────────────────────────────
const overlay       = document.getElementById('overlay');
const toast         = document.getElementById('toast');
const tagList       = document.getElementById('tag-list');
const tagListEmpty  = document.getElementById('tag-list-empty');
const slotUsed      = document.getElementById('slot-used');
const slotTotal     = document.getElementById('slot-total');
const formSection   = document.getElementById('form-section');
const formTitle     = document.getElementById('form-title');
const inputText     = document.getElementById('input-text');
const charCounter   = document.getElementById('char-counter');
const colorGrid     = document.getElementById('color-grid');
const previewText   = document.getElementById('preview-text');
const btnNewTag     = document.getElementById('btn-new-tag');
const btnFormSave   = document.getElementById('btn-form-save');
const btnFormCancel = document.getElementById('btn-form-cancel');
const btnClose      = document.getElementById('btn-close');

// ── Pattern animation helpers ─────────────────────────────────────────────────
function startPatternAnimations() {
    // Clear existing intervals first
    Object.values(patternAnimState).forEach(s => clearInterval(s.intervalId));

    state.allowedPatterns.forEach(code => {
        const meta = PATTERN_META[code];
        if (!meta) return;
        patternAnimState[code] = { idx: 0 };
        patternAnimState[code].intervalId = setInterval(() => {
            patternAnimState[code].idx = (patternAnimState[code].idx + 1) % meta.colors.length;
            // Update any rendered swatch for this pattern
            const sw = colorGrid.querySelector(`[data-code="${CSS.escape(code)}"]`);
            if (sw) applyPatternSwatchStyle(sw, code);
            // Update preview if this pattern is currently selected
            if (state.selectedColor === code) updatePreview();
        }, 500);
    });
}

function stopPatternAnimations() {
    Object.values(patternAnimState).forEach(s => clearInterval(s.intervalId));
}

function applyPatternSwatchStyle(el, code) {
    const meta = PATTERN_META[code];
    if (!meta) return;
    const colors = meta.colors;
    if (colors.length === 1) {
        el.style.background = colors[0];
    } else {
        // Build a cycling gradient that shifts with the current animation index
        const idx   = patternAnimState[code] ? patternAnimState[code].idx : 0;
        const steps = colors.length;
        // Rotate gradient stops so the "current" color is on the left
        const rotated = [...colors.slice(idx), ...colors.slice(0, idx)];
        const pct     = 100 / rotated.length;
        const stops   = rotated.map((c, i) => `${c} ${i * pct}%, ${c} ${(i + 1) * pct}%`).join(', ');
        el.style.background = `linear-gradient(135deg, ${stops})`;
    }
}

// ── Color grid ────────────────────────────────────────────────────────────────
function buildColorGrid() {
    colorGrid.innerHTML = '';

    // ── Section: Base Colors ──
    const baseLabel = document.createElement('div');
    baseLabel.className = 'color-section-label';
    baseLabel.textContent = 'Base Colors';
    colorGrid.appendChild(baseLabel);

    const baseRow = document.createElement('div');
    baseRow.className = 'color-row';
    BASE_COLORS.forEach(c => {
        baseRow.appendChild(makeSwatch(c.code, c.label, c.css, false));
    });
    colorGrid.appendChild(baseRow);

    // ── Section: Patterns (only if player has any) ──
    if (state.allowedPatterns.length > 0) {
        const patLabel = document.createElement('div');
        patLabel.className = 'color-section-label pattern-label';
        patLabel.textContent = 'Color Patterns';

        const lockIcon = document.createElement('span');
        lockIcon.className = 'pattern-label-badge';
        lockIcon.textContent = '✦ Unlocked';
        patLabel.appendChild(lockIcon);
        colorGrid.appendChild(patLabel);

        const patRow = document.createElement('div');
        patRow.className = 'color-row';
        state.allowedPatterns.forEach(code => {
            const meta = PATTERN_META[code] || { label: code, colors: ['#e8e8f0'] };
            patRow.appendChild(makeSwatch(code, meta.label, null, true));
        });
        colorGrid.appendChild(patRow);
    }

    // Re-apply selection state
    document.querySelectorAll('.color-swatch').forEach(sw => {
        sw.classList.toggle('selected', sw.dataset.code === state.selectedColor);
    });
}

function makeSwatch(code, label, cssColor, isPattern) {
    const sw = document.createElement('div');
    sw.className = 'color-swatch' + (isPattern ? ' pattern-swatch' : '');
    sw.dataset.code = code;
    sw.title = label;

    if (isPattern) {
        applyPatternSwatchStyle(sw, code);
        const tag = document.createElement('span');
        tag.className = 'swatch-label';
        tag.textContent = label;
        sw.appendChild(tag);
    } else {
        sw.style.background = cssColor;
    }

    sw.addEventListener('click', () => selectColor(code));
    return sw;
}

function selectColor(code) {
    state.selectedColor = code;
    document.querySelectorAll('.color-swatch').forEach(sw => {
        sw.classList.toggle('selected', sw.dataset.code === code);
    });
    updatePreview();
}

// ── Preview ───────────────────────────────────────────────────────────────────
function applyColorToEl(el, code) {
    const base = BASE_COLORS.find(x => x.code === code);
    if (base) {
        el.style.cssText = `color: ${base.css}; font-weight: 700; background: none; -webkit-text-fill-color: unset;`;
        return;
    }
    const meta = PATTERN_META[code];
    if (meta) {
        const idx = patternAnimState[code] ? patternAnimState[code].idx : 0;
        el.style.cssText = `color: ${meta.colors[idx]}; font-weight: 700; background: none; -webkit-text-fill-color: unset;`;
        return;
    }
    el.style.cssText = 'color: #e8e8f0; font-weight: 700;';
}

function updatePreview() {
    const text = inputText.value.trim() || 'Your Tag';
    applyColorToEl(previewText, state.selectedColor);
    previewText.textContent = text + ' ';
}

// ── Char counter ──────────────────────────────────────────────────────────────
function updateCharCounter() {
    const len = inputText.value.length;
    const max = state.maxLen;
    charCounter.textContent = `${len} / ${max}`;
    charCounter.className = 'char-counter';
    if (len >= max)            charCounter.classList.add('at-limit');
    else if (len >= max * 0.8) charCounter.classList.add('near-limit');
}

// ── Tag list ──────────────────────────────────────────────────────────────────
function getColorDotStyle(code) {
    const base = BASE_COLORS.find(x => x.code === code);
    if (base) return `background: ${base.css}`;
    const meta = PATTERN_META[code];
    if (meta) {
        const stops = meta.colors.map((c, i) => `${c} ${i * (100/meta.colors.length)}%`).join(', ');
        return `background: linear-gradient(135deg, ${stops})`;
    }
    return 'background: #e8e8f0';
}

function renderTagList() {
    slotUsed.textContent  = state.tags.length;
    slotTotal.textContent = state.slots;

    const atLimit = state.tags.length >= state.slots;
    btnNewTag.disabled = atLimit;
    btnNewTag.title = atLimit ? 'All slots are used' : 'Create a new custom tag';

    tagList.innerHTML = '';
    if (state.tags.length === 0) {
        tagListEmpty.classList.remove('hidden');
        return;
    }
    tagListEmpty.classList.add('hidden');

    state.tags.forEach((tag, i) => {
        const idx  = i + 1;
        const card = document.createElement('div');
        card.className = 'tag-card' + (state.activeIndex === idx ? ' active-tag' : '');

        const dot = document.createElement('div');
        dot.className = 'tag-color-dot';
        dot.style.cssText = getColorDotStyle(tag.color);

        const info = document.createElement('div');
        info.className = 'tag-info';

        const label = document.createElement('div');
        label.className = 'tag-info-label';
        label.textContent = tag.text;

        const colorMeta = BASE_COLORS.find(x => x.code === tag.color)
            || (PATTERN_META[tag.color] ? { label: PATTERN_META[tag.color].label } : { label: tag.color });
        const sub = document.createElement('div');
        sub.className = 'tag-info-sub';
        sub.textContent = colorMeta.label + ' · Slot ' + idx;

        info.appendChild(label);
        info.appendChild(sub);

        if (state.activeIndex === idx) {
            const badge = document.createElement('span');
            badge.className = 'tag-active-badge';
            badge.textContent = 'Active';
            info.appendChild(badge);
        }

        const actions = document.createElement('div');
        actions.className = 'tag-actions';

        if (state.activeIndex !== idx) {
            const btnAct = document.createElement('button');
            btnAct.className = 'btn-activate';
            btnAct.textContent = '▶ Activate';
            btnAct.addEventListener('click', () => activateTag(idx));
            actions.appendChild(btnAct);
        }

        const btnEdit = document.createElement('button');
        btnEdit.className = 'btn-edit';
        btnEdit.textContent = '✎ Edit';
        btnEdit.addEventListener('click', () => openEditForm(idx));
        actions.appendChild(btnEdit);

        const btnDel = document.createElement('button');
        btnDel.className = 'btn-delete';
        btnDel.textContent = '✕';
        btnDel.title = 'Delete this tag';
        btnDel.addEventListener('click', () => deleteTag(idx));
        actions.appendChild(btnDel);

        card.appendChild(dot);
        card.appendChild(info);
        card.appendChild(actions);
        tagList.appendChild(card);
    });
}

// ── Form ──────────────────────────────────────────────────────────────────────
function openNewForm() {
    state.editIndex = null;
    formTitle.textContent = 'New Tag';
    inputText.value = '';
    selectColor('~w~');
    updateCharCounter();
    updatePreview();
    inputText.setAttribute('maxlength', state.maxLen);
    formSection.classList.remove('hidden');
    inputText.focus();
}

function openEditForm(idx) {
    const tag = state.tags[idx - 1];
    if (!tag) return;
    state.editIndex = idx;
    formTitle.textContent = 'Edit Tag · Slot ' + idx;
    inputText.value = tag.text;
    inputText.setAttribute('maxlength', state.maxLen);
    selectColor(tag.color);
    updateCharCounter();
    updatePreview();
    formSection.classList.remove('hidden');
    inputText.focus();
}

function closeForm() {
    formSection.classList.add('hidden');
    state.editIndex = null;
}

// ── Actions ───────────────────────────────────────────────────────────────────
function saveTag() {
    const text = inputText.value.trim();
    if (!text) { showToast('Tag text cannot be empty.', 'error'); return; }
    fetchNui('save', { index: state.editIndex, text, color: state.selectedColor });
}

function deleteTag(idx) {
    fetchNui('delete', { index: idx });
}

function activateTag(idx) {
    fetchNui('activate', { index: idx });
}

// ── NUI message handler ───────────────────────────────────────────────────────
window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.action) return;

    switch (data.action) {
        case 'open':
            state.tags            = data.tags     || [];
            state.slots           = data.slots    || 0;
            state.maxLen          = data.maxLen   || 20;
            state.allowedPatterns = data.patterns || [];
            state.activeIndex     = null;
            stopPatternAnimations();
            buildColorGrid();
            startPatternAnimations();
            renderTagList();
            closeForm();
            hideToast();
            overlay.classList.remove('hidden');
            break;

        case 'close':
            overlay.classList.add('hidden');
            stopPatternAnimations();
            closeForm();
            hideToast();
            break;

        case 'refresh':
            state.tags  = data.tags  || [];
            state.slots = data.slots || 0;
            renderTagList();
            closeForm();
            hideToast();
            break;

        case 'activated':
            state.activeIndex = data.index;
            renderTagList();
            showToast('Tag activated! Closing…', 'success');
            break;

        case 'error':
            showToast(data.message || 'An error occurred.', 'error');
            break;
    }
});

// ── Toast ─────────────────────────────────────────────────────────────────────
let toastTimer = null;
function showToast(msg, type = 'error') {
    clearTimeout(toastTimer);
    toast.textContent = msg;
    toast.className = type;
    toastTimer = setTimeout(hideToast, 4000);
}
function hideToast() {
    clearTimeout(toastTimer);
    toast.className = 'hidden';
}

// ── NUI fetch helper ──────────────────────────────────────────────────────────
function fetchNui(endpoint, data = {}) {
    return fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify(data),
    }).catch(() => {});
}

function GetParentResourceName() {
    return typeof window.GetParentResourceName === 'function'
        ? window.GetParentResourceName()
        : 'DiscordTagIDs';
}

// ── Wire events ───────────────────────────────────────────────────────────────
btnClose.addEventListener('click', () => fetchNui('close'));

btnNewTag.addEventListener('click', () => {
    if (btnNewTag.disabled) return;
    if (!formSection.classList.contains('hidden') && state.editIndex === null) {
        closeForm();
    } else {
        openNewForm();
    }
});

btnFormSave.addEventListener('click', saveTag);
btnFormCancel.addEventListener('click', closeForm);

inputText.addEventListener('input', () => { updateCharCounter(); updatePreview(); });
inputText.addEventListener('keydown', (e) => {
    if (e.key === 'Enter')  saveTag();
    if (e.key === 'Escape') closeForm();
});

// Initial color grid (no patterns yet; will be rebuilt on 'open' message)
buildColorGrid();
