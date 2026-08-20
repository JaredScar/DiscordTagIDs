'use strict';

// ── GTA color definitions ─────────────────────────────────────────────────────
const COLORS = [
    { code: '~r~',   label: 'Red',     css: '#e05555' },
    { code: '~g~',   label: 'Green',   css: '#55cc55' },
    { code: '~b~',   label: 'Blue',    css: '#5599ee' },
    { code: '~y~',   label: 'Yellow',  css: '#eecc44' },
    { code: '~o~',   label: 'Orange',  css: '#ee8833' },
    { code: '~p~',   label: 'Purple',  css: '#bb44ee' },
    { code: '~w~',   label: 'White',   css: '#e8e8f0' },
    { code: '~RGB~', label: 'Rainbow', css: null       },
];

// ── State ─────────────────────────────────────────────────────────────────────
let state = {
    tags:         [],
    slots:        0,
    maxLen:       20,
    editIndex:    null,  // null = new, number = editing existing
    selectedColor: '~w~',
    activeIndex:  null,  // index (1-based) of the currently active custom tag
};

// ── DOM refs ──────────────────────────────────────────────────────────────────
const overlay      = document.getElementById('overlay');
const toast        = document.getElementById('toast');
const tagList      = document.getElementById('tag-list');
const tagListEmpty = document.getElementById('tag-list-empty');
const slotUsed     = document.getElementById('slot-used');
const slotTotal    = document.getElementById('slot-total');
const formSection  = document.getElementById('form-section');
const formTitle    = document.getElementById('form-title');
const inputText    = document.getElementById('input-text');
const charCounter  = document.getElementById('char-counter');
const colorGrid    = document.getElementById('color-grid');
const previewText  = document.getElementById('preview-text');
const btnNewTag    = document.getElementById('btn-new-tag');
const btnFormSave  = document.getElementById('btn-form-save');
const btnFormCancel= document.getElementById('btn-form-cancel');
const btnClose     = document.getElementById('btn-close');

// ── Build color swatches ──────────────────────────────────────────────────────
function buildColorGrid() {
    colorGrid.innerHTML = '';
    COLORS.forEach(c => {
        const sw = document.createElement('div');
        sw.className = 'color-swatch' + (c.code === '~RGB~' ? ' rainbow' : '');
        sw.dataset.code = c.code;
        sw.title = c.label;
        if (c.css) sw.style.background = c.css;
        if (c.code === state.selectedColor) sw.classList.add('selected');
        sw.addEventListener('click', () => selectColor(c.code));
        colorGrid.appendChild(sw);
    });
}

function selectColor(code) {
    state.selectedColor = code;
    document.querySelectorAll('.color-swatch').forEach(sw => {
        sw.classList.toggle('selected', sw.dataset.code === code);
    });
    updatePreview();
}

// ── Preview ───────────────────────────────────────────────────────────────────
function colorToCss(code) {
    const c = COLORS.find(x => x.code === code);
    if (!c) return '#e8e8f0';
    if (code === '~RGB~') return 'transparent'; // handled via class
    return c.css;
}

function updatePreview() {
    const text = inputText.value.trim() || 'Your Tag';
    if (state.selectedColor === '~RGB~') {
        previewText.style.cssText = `
            background: linear-gradient(90deg,
                #ff4e4e, #ff9a3c, #ffe234, #55cc55, #4da8da, #bb44ee, #ff4e4e);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-weight: 700;
        `;
    } else {
        previewText.style.cssText = `color: ${colorToCss(state.selectedColor)}; font-weight: 700;`;
    }
    previewText.textContent = text + ' ';
}

// ── Char counter ──────────────────────────────────────────────────────────────
function updateCharCounter() {
    const len = inputText.value.length;
    const max = state.maxLen;
    charCounter.textContent = `${len} / ${max}`;
    charCounter.className = 'char-counter';
    if (len >= max)        charCounter.classList.add('at-limit');
    else if (len >= max * 0.8) charCounter.classList.add('near-limit');
}

// ── Tag list render ───────────────────────────────────────────────────────────
function renderTagList() {
    slotUsed.textContent  = state.tags.length;
    slotTotal.textContent = state.slots;

    const atLimit = state.tags.length >= state.slots;
    btnNewTag.disabled = atLimit;
    btnNewTag.title    = atLimit ? 'All slots are used' : 'Create a new custom tag';

    tagList.innerHTML = '';

    if (state.tags.length === 0) {
        tagListEmpty.classList.remove('hidden');
        return;
    }
    tagListEmpty.classList.add('hidden');

    state.tags.forEach((tag, i) => {
        const idx = i + 1; // 1-based to match Lua
        const card = document.createElement('div');
        card.className = 'tag-card' + (state.activeIndex === idx ? ' active-tag' : '');
        card.dataset.idx = idx;

        const dot = document.createElement('div');
        dot.className = 'tag-color-dot';
        if (tag.color === '~RGB~') {
            dot.style.background = 'linear-gradient(135deg, #ff4e4e, #ffe234, #55cc55, #4da8da, #bb44ee)';
        } else {
            const c = COLORS.find(x => x.code === tag.color);
            dot.style.background = c ? c.css : '#e8e8f0';
        }

        const info = document.createElement('div');
        info.className = 'tag-info';

        const label = document.createElement('div');
        label.className = 'tag-info-label';
        label.textContent = tag.text;

        const sub = document.createElement('div');
        const c = COLORS.find(x => x.code === tag.color);
        sub.className = 'tag-info-sub';
        sub.textContent = (c ? c.label : tag.color) + ' · Slot ' + idx;

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

// ── Form open/close ───────────────────────────────────────────────────────────
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

// ── Tag actions ───────────────────────────────────────────────────────────────
function saveTag() {
    const text = inputText.value.trim();
    if (!text) { showToast('Tag text cannot be empty.', 'error'); return; }

    fetchNui('save', {
        index: state.editIndex,
        text:  text,
        color: state.selectedColor,
    });
}

function deleteTag(idx) {
    fetchNui('delete', { index: idx });
}

function activateTag(idx) {
    fetchNui('activate', { index: idx });
}

// ── NUI message handler (from Lua) ────────────────────────────────────────────
window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.action) return;

    switch (data.action) {
        case 'open':
            state.tags      = data.tags  || [];
            state.slots     = data.slots || 0;
            state.maxLen    = data.maxLen || 20;
            state.activeIndex = null;
            buildColorGrid();
            renderTagList();
            closeForm();
            hideToast();
            overlay.classList.remove('hidden');
            break;

        case 'close':
            overlay.classList.add('hidden');
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

// Polyfill for non-FiveM environments (browser preview)
function GetParentResourceName() {
    return typeof window.GetParentResourceName === 'function'
        ? window.GetParentResourceName()
        : 'DiscordTagIDs';
}

// ── Wire events ───────────────────────────────────────────────────────────────
btnClose.addEventListener('click', () => {
    fetchNui('close');
});

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

inputText.addEventListener('input', () => {
    updateCharCounter();
    updatePreview();
});

inputText.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') saveTag();
    if (e.key === 'Escape') closeForm();
});

// Build the color swatches on load
buildColorGrid();
