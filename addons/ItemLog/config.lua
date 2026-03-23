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
        showOtherDrops = false
    },
    showSettings = false
};

local M = {};

function M.load()
    local s = settings.load(default_settings);
    
    -- Sync any missing keys if updating from older version
    if s.window.invTextColor then 
        s.window.inventoryColor = s.window.invTextColor;
        s.window.invTextColor = nil; 
    end
    if s.window.bgColor then 
        s.window.windowColor = s.window.bgColor;
        s.window.bgColor = nil; 
    end
    if s.window.innerBgColor then 
        s.window.innerColor = s.window.innerBgColor;
        s.window.innerBgColor = nil; 
    end
    
    return s;
end

function M.save()
    settings.save();
end

return M;
