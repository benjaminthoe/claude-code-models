const api = typeof browser !== 'undefined' ? browser : chrome;

document.addEventListener('DOMContentLoaded', () => {
  const masterToggle = document.getElementById('masterToggle');
  const statusText = document.getElementById('statusText');
  const blockedEl = document.getElementById('blockedCount');
  const optimizedEl = document.getElementById('optimizedCount');
  const toggleRows = document.querySelectorAll('.toggle-row');

  // Load settings
  api.storage.local.get('settings', (result) => {
    const settings = result.settings || {};

    // Master toggle
    masterToggle.checked = settings.enabled !== false;
    updateStatusText(masterToggle.checked);
    updateRowsDisabled(!masterToggle.checked);

    // Category toggles
    toggleRows.forEach((row) => {
      const key = row.getAttribute('data-setting');
      const checkbox = row.querySelector('input[type="checkbox"]');
      if (key && settings[key] !== undefined) {
        checkbox.checked = settings[key];
      }
    });
  });

  // Load stats
  api.storage.local.get(['blockedCount', 'optimizedCount'], (result) => {
    blockedEl.textContent = formatNumber(result.blockedCount || 0);
    optimizedEl.textContent = formatNumber(result.optimizedCount || 0);
  });

  // Master toggle handler
  masterToggle.addEventListener('change', () => {
    const enabled = masterToggle.checked;
    updateStatusText(enabled);
    updateRowsDisabled(!enabled);

    api.storage.local.get('settings', (result) => {
      const settings = result.settings || {};
      settings.enabled = enabled;
      api.storage.local.set({ settings });

      // Enable/disable declarativeNetRequest ruleset
      if (api.declarativeNetRequest && api.declarativeNetRequest.updateEnabledRulesets) {
        api.declarativeNetRequest.updateEnabledRulesets({
          enableRulesetIds: enabled && settings.blockAdsTrackers ? ['block_rules'] : [],
          disableRulesetIds: enabled && settings.blockAdsTrackers ? [] : ['block_rules']
        });
      }
    });
  });

  // Category toggle handlers
  toggleRows.forEach((row) => {
    const key = row.getAttribute('data-setting');
    const checkbox = row.querySelector('input[type="checkbox"]');

    checkbox.addEventListener('change', () => {
      api.storage.local.get('settings', (result) => {
        const settings = result.settings || {};
        settings[key] = checkbox.checked;
        api.storage.local.set({ settings });

        // Special handling for ad blocker toggle
        if (key === 'blockAdsTrackers' && api.declarativeNetRequest) {
          api.declarativeNetRequest.updateEnabledRulesets({
            enableRulesetIds: checkbox.checked && settings.enabled ? ['block_rules'] : [],
            disableRulesetIds: checkbox.checked && settings.enabled ? [] : ['block_rules']
          });
        }
      });
    });
  });

  function updateStatusText(enabled) {
    statusText.textContent = enabled ? 'Active' : 'Inactive';
    statusText.className = enabled ? '' : 'inactive';
  }

  function updateRowsDisabled(disabled) {
    toggleRows.forEach((row) => {
      row.classList.toggle('disabled', disabled);
    });
  }

  function formatNumber(n) {
    if (n >= 1000) return (n / 1000).toFixed(1) + 'k';
    return n.toString();
  }
});
