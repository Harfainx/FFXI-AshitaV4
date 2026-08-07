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

function M.Initialize()
    current_settings = settings.load(default_settings);
    
    -- Sync any missing keys if updating from older version
    if current_settings.window.invTextColor then 
        current_settings.window.inventoryColor = current_settings.window.invTextColor;
        current_settings.window.invTextColor = nil; 
    end
    if current_settings.window.bgColor then 
        current_settings.window.windowColor = current_settings.window.bgColor;
        current_settings.window.bgColor = nil; 
    end
    if current_settings.window.innerBgColor then 
        current_settings.window.innerColor = current_settings.window.innerBgColor;
        current_settings.window.innerBgColor = nil; 
    end

    if current_settings.log.showGil == nil then
        current_settings.log.showGil = true;
    end
    
    return current_settings;
end

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
