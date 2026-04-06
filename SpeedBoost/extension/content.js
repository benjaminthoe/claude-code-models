// SpeedBoost Content Script — Three-phase page optimizer
const api = typeof browser !== 'undefined' ? browser : chrome;

let settings = null;
let optimizedCount = 0;

const PLACEHOLDER_IMG = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';

// ============================================================
// Phase 1: Runs immediately at document_start
// ============================================================
function phase1_immediate() {
  // Fetch settings, then apply what we can before DOM exists
  api.runtime.sendMessage({ type: 'getSettings' }, (s) => {
    settings = s || {
      enabled: true, blockAdsTrackers: true, lazyLoadImages: true,
      lazyLoadVideos: true, removeOverlays: true, preconnectCDN: true,
      deferScripts: true, blockAutoplay: true, cssPerformance: true,
      domContainment: true, timerCleanup: true
    };

    if (!settings.enabled) return;
    if (settings.preconnectCDN) injectPreconnects();
    if (settings.cssPerformance) injectPerformanceCSS();
    if (settings.blockAutoplay) injectAutoplayBlockCSS();
  });
}

function injectPreconnects() {
  const domains = [
    'https://cdn.jsdelivr.net',
    'https://cdnjs.cloudflare.com',
    'https://fonts.googleapis.com',
    'https://fonts.gstatic.com'
  ];
  const frag = document.createDocumentFragment();
  domains.forEach((href) => {
    const link = document.createElement('link');
    link.rel = 'preconnect';
    link.href = href;
    link.crossOrigin = 'anonymous';
    frag.appendChild(link);
  });
  const target = document.head || document.documentElement;
  if (target) target.appendChild(frag);
  optimizedCount += domains.length;
}

function injectPerformanceCSS() {
  const style = document.createElement('style');
  style.textContent = `
    html { scroll-behavior: smooth; }
    * { scroll-margin-top: 80px; }
    img, video, iframe {
      content-visibility: auto;
      contain-intrinsic-size: 300px 200px;
    }
  `;
  const target = document.head || document.documentElement;
  if (target) target.appendChild(style);
  optimizedCount++;
}

function injectAutoplayBlockCSS() {
  const style = document.createElement('style');
  style.textContent = `
    video[autoplay] { animation-play-state: paused !important; }
  `;
  const target = document.head || document.documentElement;
  if (target) target.appendChild(style);
}

// ============================================================
// Phase 2: Runs at DOMContentLoaded
// ============================================================
function phase2_domReady() {
  if (!settings || !settings.enabled) return;

  if (settings.lazyLoadImages) setupImageLazyLoading();
  if (settings.lazyLoadVideos) setupVideoLazyLoading();
  if (settings.removeOverlays) removeOverlays();
  if (settings.deferScripts) deferNonCriticalScripts();
  if (settings.blockAutoplay) blockAutoplayVideos();
  if (settings.domContainment) setupDOMContainment();
  if (settings.removeOverlays) setupMutationObserver();
}

function setupImageLazyLoading() {
  const images = document.querySelectorAll('img[src]:not([loading="lazy"]):not([data-sb-lazy])');
  if (images.length === 0) return;

  // Batch read phase
  const viewportHeight = window.innerHeight;
  const imagesToLazy = [];

  images.forEach((img) => {
    const rect = img.getBoundingClientRect();
    // Skip images in or near the viewport
    if (rect.bottom < viewportHeight + 200 && rect.top > -200) return;
    imagesToLazy.push(img);
  });

  if (imagesToLazy.length === 0) return;

  // Intersection Observer for restoring images
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        const img = entry.target;
        const realSrc = img.getAttribute('data-sb-src');
        if (realSrc) {
          img.src = realSrc;
          img.removeAttribute('data-sb-src');
        }
        img.removeAttribute('data-sb-lazy');
        observer.unobserve(img);
      }
    });
  }, { rootMargin: '200px 0px', threshold: 0.01 });

  // Batch write phase
  requestAnimationFrame(() => {
    imagesToLazy.forEach((img) => {
      const realSrc = img.src;
      if (realSrc && !realSrc.startsWith('data:')) {
        img.setAttribute('data-sb-src', realSrc);
        img.setAttribute('data-sb-lazy', '');
        img.src = PLACEHOLDER_IMG;
        observer.observe(img);
        optimizedCount++;
      }
    });
  });
}

function setupVideoLazyLoading() {
  const videos = document.querySelectorAll('video:not([data-sb-lazy])');
  if (videos.length === 0) return;

  const viewportHeight = window.innerHeight;

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        const video = entry.target;
        const sourcesJSON = video.getAttribute('data-sb-sources');
        if (sourcesJSON) {
          try {
            const sources = JSON.parse(sourcesJSON);
            sources.forEach((s) => {
              if (s.tagName === 'SOURCE') {
                const source = document.createElement('source');
                source.src = s.src;
                if (s.type) source.type = s.type;
                video.appendChild(source);
              } else {
                video.src = s.src;
              }
            });
          } catch (e) { /* ignore parse errors */ }
          video.removeAttribute('data-sb-sources');
        }
        video.preload = 'metadata';
        observer.unobserve(video);
      }
    });
  }, { rootMargin: '300px 0px', threshold: 0.01 });

  videos.forEach((video) => {
    const rect = video.getBoundingClientRect();
    // Skip videos in or near viewport
    if (rect.bottom < viewportHeight + 300 && rect.top > -300) return;

    // Save sources
    const sources = [];
    const sourceEls = video.querySelectorAll('source');
    sourceEls.forEach((s) => {
      sources.push({ tagName: 'SOURCE', src: s.src, type: s.type });
      s.remove();
    });
    if (video.src && !video.src.startsWith('data:')) {
      sources.push({ tagName: 'VIDEO', src: video.src });
      video.removeAttribute('src');
    }

    if (sources.length > 0) {
      video.setAttribute('data-sb-sources', JSON.stringify(sources));
      video.setAttribute('data-sb-lazy', '');
      video.preload = 'none';
      video.removeAttribute('autoplay');
      observer.observe(video);
      optimizedCount++;
    }
  });
}

function removeOverlays() {
  const selectors = [
    '[class*="modal"]', '[class*="overlay"]', '[class*="popup"]',
    '[class*="interstitial"]', '[class*="cookie"]', '[class*="consent"]',
    '[class*="adblock"]', '[class*="subscribe"]', '[class*="newsletter-popup"]',
    '[id*="modal"]', '[id*="overlay"]', '[id*="popup"]',
    '[id*="interstitial"]', '[id*="cookie"]', '[id*="consent"]',
    '[id*="adblock"]'
  ];

  const candidates = document.querySelectorAll(selectors.join(','));
  const viewportW = window.innerWidth;
  const viewportH = window.innerHeight;

  candidates.forEach((el) => {
    const style = window.getComputedStyle(el);
    const pos = style.position;
    const zIndex = parseInt(style.zIndex, 10);

    if ((pos === 'fixed' || pos === 'absolute') && zIndex > 100) {
      const rect = el.getBoundingClientRect();
      const coversWidth = rect.width > viewportW * 0.3;
      const coversHeight = rect.height > viewportH * 0.3;

      if (coversWidth && coversHeight) {
        el.remove();
        optimizedCount++;
      }
    }
  });

  // Unlock body scroll
  if (document.body) {
    document.body.style.overflow = '';
    document.body.style.position = '';
    document.body.style.height = '';
    document.body.style.width = '';
  }

  // Remove any backdrop overlays
  document.querySelectorAll('[class*="backdrop"]').forEach((el) => {
    const style = window.getComputedStyle(el);
    if (style.position === 'fixed' && parseFloat(style.opacity) < 1) {
      el.remove();
      optimizedCount++;
    }
  });
}

function deferNonCriticalScripts() {
  const nonCriticalPatterns = [
    /social/i, /share/i, /widget/i, /chat/i, /comment/i,
    /recommend/i, /newsletter/i, /subscribe/i, /notification/i,
    /survey/i, /feedback/i, /beacon/i
  ];

  const scripts = document.querySelectorAll('script[src]:not([defer]):not([async])');
  scripts.forEach((script) => {
    const src = script.src;
    const isNonCritical = nonCriticalPatterns.some((p) => p.test(src));
    if (isNonCritical) {
      const clone = document.createElement('script');
      clone.src = src;
      clone.defer = true;
      if (script.type) clone.type = script.type;
      script.parentNode.replaceChild(clone, script);
      optimizedCount++;
    }
  });
}

function blockAutoplayVideos() {
  const videos = document.querySelectorAll('video[autoplay]');
  videos.forEach((video) => {
    video.removeAttribute('autoplay');
    video.pause();
    video.preload = 'metadata';
    optimizedCount++;
  });

  // Also handle iframes with autoplay
  const iframes = document.querySelectorAll('iframe[src*="autoplay=1"], iframe[src*="autoplay=true"]');
  iframes.forEach((iframe) => {
    const src = iframe.src;
    iframe.src = src
      .replace(/autoplay=1/g, 'autoplay=0')
      .replace(/autoplay=true/g, 'autoplay=false');
    optimizedCount++;
  });
}

function setupDOMContainment() {
  const heavyContainers = document.querySelectorAll(
    'main, article, section, .content, .post, .feed, .container, .wrapper, .grid, .list'
  );
  requestAnimationFrame(() => {
    heavyContainers.forEach((el) => {
      el.style.contain = 'layout style paint';
      optimizedCount++;
    });
  });
}

function setupMutationObserver() {
  if (!document.body) return;

  let pendingCheck = false;

  const observer = new MutationObserver((mutations) => {
    if (pendingCheck) return;
    pendingCheck = true;

    requestAnimationFrame(() => {
      pendingCheck = false;

      let hasNewImages = false;
      let hasNewOverlays = false;

      for (const mutation of mutations) {
        for (const node of mutation.addedNodes) {
          if (node.nodeType !== 1) continue;
          if (node.tagName === 'IMG' || node.querySelector?.('img')) {
            hasNewImages = true;
          }
          const cl = (node.className || '').toString().toLowerCase();
          const id = (node.id || '').toLowerCase();
          if (/modal|overlay|popup|interstitial|cookie|consent|adblock/.test(cl + id)) {
            hasNewOverlays = true;
          }
        }
      }

      if (hasNewImages && settings?.lazyLoadImages) setupImageLazyLoading();
      if (hasNewOverlays && settings?.removeOverlays) removeOverlays();
    });
  });

  observer.observe(document.body, { childList: true, subtree: true });
}

// ============================================================
// Phase 3: Runs at window load
// ============================================================
function phase3_loaded() {
  if (!settings || !settings.enabled) return;

  if (settings.timerCleanup) cleanupTimers();
  reportOptimizedCount();
}

function cleanupTimers() {
  const originalSetInterval = window.setInterval;
  window.setInterval = function(fn, delay, ...args) {
    if (delay < 100) {
      optimizedCount++;
      return -1; // Suppress aggressive intervals (analytics heartbeats)
    }
    return originalSetInterval.call(window, fn, delay, ...args);
  };
}

function reportOptimizedCount() {
  if (optimizedCount > 0) {
    api.runtime.sendMessage({
      type: 'updateOptimizedCount',
      count: optimizedCount
    });
  }
}

// ============================================================
// Execution wiring
// ============================================================
phase1_immediate();

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', phase2_domReady);
} else {
  phase2_domReady();
}

window.addEventListener('load', phase3_loaded);
