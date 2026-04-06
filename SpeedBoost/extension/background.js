const api = typeof browser !== 'undefined' ? browser : chrome;

const DEFAULT_SETTINGS = {
  enabled: true,
  blockAdsTrackers: true,
  lazyLoadImages: true,
  lazyLoadVideos: true,
  removeOverlays: true,
  preconnectCDN: true,
  deferScripts: true,
  blockAutoplay: true,
  cssPerformance: true,
  domContainment: true,
  timerCleanup: true
};

api.runtime.onInstalled.addListener(() => {
  api.storage.local.get('settings', (result) => {
    if (!result.settings) {
      api.storage.local.set({
        settings: DEFAULT_SETTINGS,
        blockedCount: 0,
        optimizedCount: 0
      });
    }
  });
});

// Message hub
api.runtime.onMessage.addListener((message, sender, sendResponse) => {
  switch (message.type) {
    case 'getSettings':
      api.storage.local.get('settings', (result) => {
        sendResponse(result.settings || DEFAULT_SETTINGS);
      });
      return true;

    case 'updateSettings':
      api.storage.local.set({ settings: message.settings }, () => {
        sendResponse({ success: true });
      });
      return true;

    case 'updateBlockedCount':
      api.storage.local.get('blockedCount', (result) => {
        const newCount = (result.blockedCount || 0) + (message.count || 0);
        api.storage.local.set({ blockedCount: newCount });
        sendResponse({ count: newCount });
      });
      return true;

    case 'updateOptimizedCount':
      api.storage.local.get('optimizedCount', (result) => {
        const newCount = (result.optimizedCount || 0) + (message.count || 0);
        api.storage.local.set({ optimizedCount: newCount });
        sendResponse({ count: newCount });
      });
      return true;

    case 'getStats':
      api.storage.local.get(['blockedCount', 'optimizedCount'], (result) => {
        sendResponse({
          blockedCount: result.blockedCount || 0,
          optimizedCount: result.optimizedCount || 0
        });
      });
      return true;

    case 'resetStats':
      api.storage.local.set({ blockedCount: 0, optimizedCount: 0 }, () => {
        sendResponse({ success: true });
      });
      return true;

    default:
      sendResponse({ error: 'Unknown message type' });
      return true;
  }
});
