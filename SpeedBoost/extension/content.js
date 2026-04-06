// SpeedBoost Content Script — Three-phase page optimizer
const api = typeof browser !== 'undefined' ? browser : chrome;

let settings = null;
let optimizedCount = 0;

const PLACEHOLDER_IMG = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';

// Detect if this is a video-focused page (YouTube, video players, etc.)
function isVideoPage() {
  const host = location.hostname;
  const path = location.pathname;
  // Known video sites
  if (/youtube\.com|youtu\.be|vimeo\.com|dailymotion\.com|twitch\.tv|netflix\.com|hulu\.com|disneyplus\.com|hbomax\.com|peacock|primevideo|crunchyroll|missav/i.test(host)) {
    return true;
  }
  // Pages with /watch, /video, /play, /embed in URL
  if (/\/(watch|video|play|embed|player|stream)/i.test(path)) {
    return true;
  }
  return false;
}

// Check if an element is or is inside a video player
function isPartOfVideoPlayer(el) {
  let node = el;
  for (let i = 0; i < 10 && node; i++) {
    if (!node || node === document.body || node === document.documentElement) break;
    const tag = (node.tagName || '').toLowerCase();
    const cl = (node.className || '').toString().toLowerCase();
    const id = (node.id || '').toLowerCase();
    // Common video player containers
    if (tag === 'video' || tag === 'audio') return true;
    if (/player|video-js|plyr|jwplayer|flowplayer|mediaelement|html5-video|vjs-|mejs/i.test(cl + id)) return true;
    if (node.querySelector && node.querySelector('video, .video-js, .plyr, [class*="player"]')) return true;
    node = node.parentElement;
  }
  return false;
}

// ============================================================
// Phase 1: Runs immediately at document_start
// ============================================================
function phase1_immediate() {
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
  // Only apply content-visibility to images far down the page, NEVER to video/iframe
  style.textContent = `
    html { scroll-behavior: smooth; }
  `;
  const target = document.head || document.documentElement;
  if (target) target.appendChild(style);
  optimizedCount++;
}

// ============================================================
// Phase 2: Runs at DOMContentLoaded
// ============================================================
function phase2_domReady() {
  if (!settings || !settings.enabled) return;

  const videoPage = isVideoPage();

  if (settings.lazyLoadImages) setupImageLazyLoading();
  // Only lazy-load videos on listing/gallery pages, NOT on video playback pages
  if (settings.lazyLoadVideos && !videoPage) setupVideoLazyLoading();
  if (settings.removeOverlays) removeOverlays();
  if (settings.deferScripts) deferNonCriticalScripts();
  // Only block autoplay on non-video pages (don't break the main player)
  if (settings.blockAutoplay && !videoPage) blockAutoplayVideos();
  if (settings.removeOverlays) setupMutationObserver();
}

function setupImageLazyLoading() {
  const images = document.querySelectorAll('img[src]:not([loading="lazy"]):not([data-sb-lazy])');
  if (images.length === 0) return;

  const viewportHeight = window.innerHeight;
  const imagesToLazy = [];

  images.forEach((img) => {
    // Never touch images inside video players (posters, thumbnails)
    if (isPartOfVideoPlayer(img)) return;
    const rect = img.getBoundingClientRect();
    // Skip images in or near the viewport (generous 500px margin)
    if (rect.bottom < viewportHeight + 500 && rect.top > -500) return;
    // Skip small images (likely icons, UI elements)
    if (rect.width < 50 || rect.height < 50) return;
    imagesToLazy.push(img);
  });

  if (imagesToLazy.length === 0) return;

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
  }, { rootMargin: '300px 0px', threshold: 0.01 });

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
  // Only lazy-load videos on pages with MANY videos (listings/feeds)
  const videos = document.querySelectorAll('video:not([data-sb-lazy])');
  if (videos.length < 3) return; // If few videos, don't touch them

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
          } catch (e) { /* ignore */ }
          video.removeAttribute('data-sb-sources');
        }
        video.preload = 'metadata';
        observer.unobserve(video);
      }
    });
  }, { rootMargin: '500px 0px', threshold: 0.01 });

  videos.forEach((video) => {
    // Never touch the main/primary video player
    if (isPartOfVideoPlayer(video)) return;
    const rect = video.getBoundingClientRect();
    // Very generous viewport check — skip anything remotely near viewport
    if (rect.bottom < viewportHeight + 500 && rect.top > -500) return;

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
  // Only target obvious ad/cookie overlays, NOT video player UI
  const selectors = [
    '[class*="cookie-banner"]', '[class*="cookie-consent"]',
    '[class*="consent-banner"]', '[class*="consent-modal"]',
    '[class*="interstitial"]', '[class*="adblock-notice"]',
    '[class*="newsletter-popup"]', '[class*="subscribe-popup"]',
    '[id*="cookie-banner"]', '[id*="cookie-consent"]',
    '[id*="consent-banner"]', '[id*="interstitial"]',
    '[id*="adblock-notice"]'
  ];

  const candidates = document.querySelectorAll(selectors.join(','));
  const viewportW = window.innerWidth;
  const viewportH = window.innerHeight;

  candidates.forEach((el) => {
    // Never remove anything that contains a video player
    if (el.querySelector('video, iframe[src*="youtube"], iframe[src*="vimeo"], iframe[src*="player"]')) return;
    if (isPartOfVideoPlayer(el)) return;

    const style = window.getComputedStyle(el);
    const pos = style.position;
    const zIndex = parseInt(style.zIndex, 10);

    if ((pos === 'fixed' || pos === 'absolute') && zIndex > 500) {
      const rect = el.getBoundingClientRect();
      const coversWidth = rect.width > viewportW * 0.5;
      const coversHeight = rect.height > viewportH * 0.5;

      if (coversWidth && coversHeight) {
        el.remove();
        optimizedCount++;
      }
    }
  });

  // Unlock body scroll if locked by overlays
  if (document.body) {
    const bodyStyle = window.getComputedStyle(document.body);
    if (bodyStyle.overflow === 'hidden' && !document.querySelector('[class*="cookie"], [class*="consent"]')) {
      // Only unlock if there are no remaining overlays — avoid breaking modals the user opened
    } else if (document.querySelectorAll('[class*="cookie-banner"], [class*="consent-modal"]').length === 0) {
      document.body.style.overflow = '';
    }
  }
}

function deferNonCriticalScripts() {
  // Very conservative — only defer obvious non-critical scripts
  const nonCriticalPatterns = [
    /social-share/i, /share-button/i, /newsletter-widget/i,
    /survey-monkey/i, /feedback-widget/i, /beacon\.min/i
  ];

  // Never defer scripts from the current domain or known player/framework scripts
  const safePatterns = [
    /jquery/i, /react/i, /vue/i, /angular/i, /player/i, /video/i,
    /hls/i, /dash/i, /shaka/i, /plyr/i, /jwplayer/i, /flowplayer/i
  ];

  const scripts = document.querySelectorAll('script[src]:not([defer]):not([async])');
  scripts.forEach((script) => {
    const src = script.src;
    // Don't touch same-origin scripts
    try {
      if (new URL(src).hostname === location.hostname) return;
    } catch (e) { return; }
    // Don't touch player/framework scripts
    if (safePatterns.some((p) => p.test(src))) return;
    // Only defer known non-critical
    if (nonCriticalPatterns.some((p) => p.test(src))) {
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
  // Only block autoplay on small/thumbnail videos, never the main player
  const videos = document.querySelectorAll('video[autoplay]');
  videos.forEach((video) => {
    // Skip if this looks like a main player (large, or inside player container)
    if (isPartOfVideoPlayer(video)) return;
    const rect = video.getBoundingClientRect();
    if (rect.width > 400 || rect.height > 300) return; // Likely main player
    video.removeAttribute('autoplay');
    video.pause();
    video.preload = 'metadata';
    optimizedCount++;
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
          if (/cookie-banner|cookie-consent|consent-banner|interstitial|adblock-notice/.test(cl + id)) {
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
  // Timer cleanup removed — too aggressive, breaks video players
  reportOptimizedCount();
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
