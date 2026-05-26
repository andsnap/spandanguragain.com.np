/**
 * FormEngine
 * Shared runtime for serverless Typst-based forms.
 * Handles:
 * - Typst WASM compiler & renderer initialization
 * - Client-side live compilation of SVG previews
 * - PDF generation and download
 * - Form state serialization and LocalStorage persistence
 * - Debouncing & event listeners
 * - Document actions dock injection
 */
window.FormEngine = (function () {
  let config = {};
  let mainTypContent = "";
  let previewEnabled = true;
  let typstReady = false;

  // Cache of the most recently generated data object
  let lastData = {};

  /**
   * Helper function to show compilation or status message inside the preview container
   */
  function showStatus(state, message) {
    const container = document.getElementById('previewContainer');
    if (!container) return;

    if (!previewEnabled) {
      container.innerHTML = `
        <div class="preview-status-card disabled">
          <div class="preview-status-title">document preview is disabled</div>
        </div>
      `;
      return;
    }

    if (state === 'compiling') {
      container.innerHTML = `
        <div class="preview-status-card loading">
          <div class="preview-status-title">${message ? message.toLowerCase() : 'compiling...'}</div>
        </div>
      `;
    } else if (state === 'error') {
      container.innerHTML = `
        <div class="preview-status-card error">
          <div class="preview-status-title">compiling error</div>
          <div class="preview-status-desc" style="white-space: pre-wrap; text-align: left; font-family: var(--mono-font); font-size: 0.8rem; margin-top: 1rem; width: 100%; border: 1px solid var(--status-error-text); padding: 0.75rem; border-radius: 2px; overflow-x: auto; max-height: 250px;">${message}</div>
        </div>
      `;
    } else if (state === 'success') {
      // Success state clears compilation banners/cards (SVG is now showing)
    }
  }

  /**
   * Dynamically inject the floating doc actions dock (Preview / Download buttons)
   */
  function injectDocActions() {
    if (document.getElementById('docActions')) return;
    const docActions = document.createElement('div');
    docActions.id = 'docActions';
    docActions.innerHTML = `
      <button type="button" id="previewToggleBtn" class="doc-action-btn active" onclick="FormEngine.togglePreview()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
          stroke-linecap="round" stroke-linejoin="round">
          <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
          <circle cx="12" cy="12" r="3" />
        </svg>
        Preview
      </button>

      <button type="button" id="downloadBtn" class="doc-action-btn" onclick="FormEngine.compilePDF()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
          stroke-linecap="round" stroke-linejoin="round">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
          <polyline points="7 10 12 15 17 10" />
          <line x1="12" y1="15" x2="12" y2="3" />
        </svg>
        Download
      </button>
    `;
    document.body.appendChild(docActions);
  }

  /**
   * Apply Preview Active/Inactive state to the dock button and toggle rendering
   */
  function applyPreviewState() {
    const btn = document.getElementById('previewToggleBtn');
    if (!btn) return;

    if (previewEnabled) {
      btn.classList.add('active');
      btn.innerHTML = `
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
          <circle cx="12" cy="12" r="3"/>
        </svg>
        Preview
      `;
      if (typstReady) {
        compilePreview();
      }
    } else {
      btn.classList.remove('active');
      btn.innerHTML = `
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>
          <line x1="1" y1="1" x2="23" y2="23"/>
        </svg>
        Preview
      `;
      showStatus('disabled');
    }
  }

  /**
   * Toggle preview active state and save preference to LocalStorage
   */
  function togglePreview() {
    previewEnabled = !previewEnabled;
    try {
      localStorage.setItem(`${config.formId}_preview`, previewEnabled ? '1' : '0');
    } catch (e) {
      console.warn("Could not save preview state preference:", e);
    }
    applyPreviewState();
  }

  /**
   * Helper utility for debouncing form changes to avoid lag
   */
  function debounce(func, wait) {
    let timeout;
    return function (...args) {
      clearTimeout(timeout);
      timeout = setTimeout(() => func.apply(this, args), wait);
    };
  }

  /**
   * Serialize main static form fields into an object
   */
  function serializeForm() {
    const data = {};
    const form = document.getElementById(config.formElementId || 'mainForm');
    if (!form) return data;

    const inputs = form.querySelectorAll('input, select, textarea');
    inputs.forEach(input => {
      // Skip inputs inside dynamic row layouts as they are handled by config.collectFormData
      if (input.closest('.dynamic-row') || input.closest('.dynamic-resp-row') || input.closest('.card-row')) {
        return;
      }

      const name = input.name || input.id;
      if (!name) return;

      if (input.type === 'checkbox') {
        data[name] = input.checked;
      } else if (input.type === 'radio') {
        if (input.checked) {
          data[name] = input.value;
        }
      } else {
        data[name] = input.value.trim();
      }
    });

    return data;
  }

  /**
   * Restore main static form fields from an object
   */
  function deserializeForm(data) {
    if (!data) return;
    const form = document.getElementById(config.formElementId || 'mainForm');
    if (!form) return;

    const inputs = form.querySelectorAll('input, select, textarea');
    inputs.forEach(input => {
      if (input.closest('.dynamic-row') || input.closest('.dynamic-resp-row') || input.closest('.card-row')) {
        return;
      }

      const name = input.name || input.id;
      if (!name || data[name] === undefined) return;

      if (input.type === 'checkbox') {
        input.checked = !!data[name];
      } else if (input.type === 'radio') {
        input.checked = (input.value === data[name]);
      } else {
        input.value = data[name];
      }
    });
  }

  /**
   * Assemble form data using serializeForm + form-specific overrides
   */
  function collectFormData() {
    let data = serializeForm();
    if (config.collectFormData) {
      data = config.collectFormData(data);
    }
    lastData = data;
    return data;
  }

  /**
   * Core Preview Compilation
   */
  async function compilePreview() {
    if (!previewEnabled || !typstReady) {
      if (typstReady) showStatus('success');
      return;
    }
    showStatus('compiling', 'Compiling preview...');

    try {
      const data = collectFormData();

      // Persist full form state in LocalStorage
      try {
        localStorage.setItem(`${config.formId}_form_data`, JSON.stringify(data));
      } catch (storageErr) {
        console.warn("Could not save form state to local storage:", storageErr);
      }

      const compiledContent = config.prepareTypstContent(data, mainTypContent);

      // Render preview SVG from Typst markup
      const svg = await $typst.svg({ mainContent: compiledContent });

      const previewContainer = document.getElementById('previewContainer');
      if (previewContainer) {
        previewContainer.innerHTML = svg;

        const svgElem = previewContainer.firstElementChild;
        if (svgElem) {
          svgElem.removeAttribute('width');
          svgElem.removeAttribute('height');
          svgElem.style.width = '100%';
          svgElem.style.height = 'auto';

          // Inject professional page sheet borders & backgrounds to mimic a real page preview
          const pages = svgElem.querySelectorAll('.typst-page');
          pages.forEach((page) => {
            const width = parseFloat(page.getAttribute('data-page-width')) || 596;
            const height = parseFloat(page.getAttribute('data-page-height')) || 842;

            const rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
            rect.setAttribute('x', '0');
            rect.setAttribute('y', '0');
            rect.setAttribute('width', width);
            rect.setAttribute('height', height);
            rect.setAttribute('fill', '#ffffff');
            rect.setAttribute('stroke', '#cbd5e0');
            rect.setAttribute('stroke-width', '1.5');

            // Prepend the rect so that it sits behind page content text
            page.insertBefore(rect, page.firstChild);
          });
        }
      }

      showStatus('success');
    } catch (err) {
      console.error("Preview compilation failed:", err);
      showStatus('error', err.message);
    }
  }

  /**
   * PDF Export via WASM
   */
  async function compilePDF() {
    if (!typstReady) return;
    const btn = document.getElementById("downloadBtn");
    if (btn) btn.disabled = true;
    showStatus('compiling', 'Generating PDF...');

    try {
      const data = collectFormData();
      const compiledContent = config.prepareTypstContent(data, mainTypContent);

      // Generate client-side PDF document
      const pdfData = await $typst.pdf({ mainContent: compiledContent });
      const pdfBlob = new Blob([pdfData], { type: 'application/pdf' });

      const url = URL.createObjectURL(pdfBlob);
      const a = document.createElement("a");
      a.href = url;
      a.download = config.pdfFilename || `${config.formId}.pdf`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);

      showStatus('success');
    } catch (err) {
      console.error("PDF generation failed:", err);
      showStatus('error', err.message);
    } finally {
      if (btn) btn.disabled = false;
    }
  }

  /**
   * Load stored LocalStorage form values and preference states
   */
  function loadFormState() {
    try {
      // 1. Load active preview enabled preference or set default for screen size
      const v = localStorage.getItem(`${config.formId}_preview`);
      if (v !== null) {
        previewEnabled = (v === '1');
      } else {
        const isMobile = window.matchMedia("(max-width: 768px)").matches ||
          /Android|iPhone|iPod|Opera Mini|IEMobile|WPDesktop/i.test(navigator.userAgent);
        previewEnabled = !isMobile;
      }
      applyPreviewState();

      // 2. Load form data from LocalStorage
      const storedStr = localStorage.getItem(`${config.formId}_form_data`);
      if (storedStr) {
        const data = JSON.parse(storedStr);
        if (data) {
          deserializeForm(data);
          if (config.restoreFormData) {
            config.restoreFormData(data);
          }
          return;
        }
      }

      // 3. If no state loaded, call restoreFormData with null/empty to build default UI rows
      if (config.restoreFormData) {
        config.restoreFormData(null);
      }
    } catch (e) {
      console.error("Error loading cached form data:", e);
    }
  }

  /**
   * Hook up event listeners to inputs to fire debounced previews
   */
  function initFormListeners() {
    const form = document.getElementById(config.formElementId || 'mainForm');
    if (!form) return;

    const debouncedPreview = debounce(compilePreview, 400);
    form.addEventListener('input', debouncedPreview);
    form.addEventListener('change', debouncedPreview);

    if (config.onFormInitListeners) {
      config.onFormInitListeners(debouncedPreview);
    }
  }

  /**
   * Load WebAssembly modules, templates and register fonts
   */
  async function initTypst() {
    showStatus('compiling', 'Initializing...');

    try {
      $typst.setCompilerInitOptions({
        getModule: () =>
          'https://cdn.jsdelivr.net/npm/@myriaddreamin/typst-ts-web-compiler/pkg/typst_ts_web_compiler_bg.wasm',
      });
      $typst.setRendererInitOptions({
        getModule: () =>
          'https://cdn.jsdelivr.net/npm/@myriaddreamin/typst-ts-renderer/pkg/typst_ts_renderer_bg.wasm',
      });

      // Load typst file template
      const res = await fetch('main.typ?t=' + Date.now());
      mainTypContent = await res.text();

      // Preload font files (standard Times Roman serif + CDN Noto Serif Devanagari)
      const fontFiles = config.fontFiles || [
        '../shared/fonts/Times New Roman.ttf',
        '../shared/fonts/Times New Roman Bold.ttf',
        '../shared/fonts/Times New Roman Italic.ttf',
        'https://cdn.jsdelivr.net/gh/notofonts/notofonts.github.io/fonts/NotoSerifDevanagari/hinted/ttf/NotoSerifDevanagari-Regular.ttf',
        'https://cdn.jsdelivr.net/gh/notofonts/notofonts.github.io/fonts/NotoSerifDevanagari/hinted/ttf/NotoSerifDevanagari-Bold.ttf',
        'https://cdn.jsdelivr.net/gh/notofonts/notofonts.github.io/fonts/NotoSerifDevanagari/hinted/ttf/NotoSerifDevanagari-Medium.ttf'
      ];

      const buffers = [];
      for (const file of fontFiles) {
        try {
          const fontRes = await fetch(file);
          if (fontRes.ok) {
            const arrayBuffer = await fontRes.arrayBuffer();
            buffers.push(new Uint8Array(arrayBuffer));
          } else {
            console.warn("Failed to fetch font:", file);
          }
        } catch (fontErr) {
          console.warn("Error fetching font file:", file, fontErr);
        }
      }

      if (buffers.length > 0) {
        $typst.use(window.TypstSnippet.preloadFonts(buffers));
      }

      typstReady = true;
      await compilePreview();
    } catch (err) {
      console.error("Failed to initialize WASM engine:", err);
      showStatus('error', 'Initialization failed: ' + err.message);
    }
  }

  /**
   * Ensure that the global $typst object is fully loaded before executing callbacks
   */
  function ensureTypstReady(callback) {
    let called = false;
    const runOnce = () => {
      if (called) return;
      called = true;
      callback();
    };

    if (window.$typst) {
      runOnce();
      return;
    }

    const typstScript = document.getElementById('typst');
    if (typstScript) {
      typstScript.addEventListener('load', runOnce);
    }
    
    // Fallback polling to handle cached modules and execution deferment
    const interval = setInterval(() => {
      if (window.$typst) {
        clearInterval(interval);
        runOnce();
      }
    }, 50);
  }

  /**
   * Main setup invocation
   */
  function init(formConfig) {
    config = formConfig;
    
    // Inject doc actions dock
    injectDocActions();

    // Restore cached inputs
    loadFormState();

    // Init form dynamic listener events
    initFormListeners();

    // Init Typst WASM and font preloading only when the global script is ready
    ensureTypstReady(() => {
      initTypst();
    });

    if (config.onFormLoaded) {
      config.onFormLoaded();
    }
  }

  // Exposed API
  return {
    init,
    togglePreview,
    compilePreview,
    compilePDF,
    debounce,
    showStatus,
    removeDynamicRow: function (btn) {
      // Export utility to remove a dynamic row
      const row = btn.closest('tr') || btn.closest('.dynamic-row') || btn.closest('.card-row');
      if (row) {
        const parent = row.parentNode;
        row.remove();
        if (config.onRowRemoved) {
          config.onRowRemoved(parent);
        }
        compilePreview();
      }
    }
  };
})();
