local settings = require('settings');

local default_settings = {
    window = {
        x = 100,
        y = 100,
        width = 250,
        height = 300,
        showInventory = true,
        showPool = true,
        showDrops = true,
        titleBarColor = { 0.1, 0.4, 0.7, 1.0 },
        accentColor = { 0.2, 0.6, 1.0, 1.0 },
        systemTextColor = { 1.0, 1.0, 1.0, 1.0 },
        inventoryColor = { 1.0, 1.0, 1.0, 1.0 },
        windowColor = { 0.05, 0.05, 0.05, 0.7 },
        innerColor = { 0.1, 0.1, 0.1, 0.5 },
        showInvThresholds = true,
        invYellowThreshold = 80,
        invRedThreshold = 95
    },
    log = {
        maxDrops = 20,
        blockMode121 = false,
        blockMode127 = false,
        showOtherDrops = false,
        showGil = true
    },
    showSettings = false
};

local current_settings = nil;

local M = {};

function M.Normalize(cfg)
    if not cfg then return; end
    if not cfg.window then cfg.window = {}; end
    if not cfg.log then cfg.log = {}; end
    
    -- Sync any missing keys if updating from older version
    if cfg.window.invTextColor then 
        cfg.window.inventoryColor = cfg.window.invTextColor;
        cfg.window.invTextColor = nil; 
    end
    if cfg.window.bgColor then 
        cfg.window.windowColor = cfg.window.bgColor;
        cfg.window.bgColor = nil; 
    end
    if cfg.window.innerBgColor then 
        cfg.window.innerColor = cfg.window.innerBgColor;
        cfg.window.innerBgColor = nil; 
    end

    if cfg.log.showGil == nil then
        cfg.log.showGil = true;
    end
end

function M.Initialize()
    current_settings = settings.load(default_settings);
    M.Normalize(current_settings);
    return current_settings;
end

settings.register('settings', 'settings_update', function(s)
    if s ~= nil then
        current_settings = s;
        M.Normalize(current_settings);
        if M.onSettingsUpdated then
            M.onSettingsUpdated(current_settings);
        end
    end
end);

function M.GetSettings()
    return current_settings;
end

function M.SaveSettings()
    if current_settings then
        settings.save();
    end
end

-- Aliases for backward compatibility
function M.load()
    return M.Initialize();
end

function M.save()
    M.SaveSettings();
end

return M;
